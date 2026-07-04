import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

type Mode = "daily_summary" | "doctor_summary" | "parse_care_event";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const allowedModes = new Set<Mode>([
  "daily_summary",
  "doctor_summary",
  "parse_care_event",
]);

const emergencyKeywords = [
  "مش بيتنفس",
  "لا يتنفس",
  "صعوبة تنفس",
  "ازرقاق",
  "شفايفه زرقاء",
  "شفايفها زرقاء",
  "تشنج",
  "فاقد الوعي",
  "مش بيستجيب",
  "نزيف شديد",
];

const minuteLimit = 6;
const dailyLimit = 50;
const requestLimitBytes = 12000;
const parseTextLimit = 500;
const geminiTimeoutMs = 30000;

serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);
  if (req.method !== "POST") {
    return jsonResponse({ message: "Method not allowed." }, 405);
  }

  const rawBody = await req.text();
  if (rawBody.length > requestLimitBytes) {
    return jsonResponse({ message: "الطلب أكبر من الحد المسموح." }, 400);
  }

  let body: unknown;
  try {
    body = JSON.parse(rawBody);
  } catch {
    return jsonResponse({ message: "الطلب غير صالح." }, 400);
  }

  const parsed = body as {
    mode?: string;
    child_id?: string;
    payload?: Record<string, unknown>;
  };
  const mode = parsed.mode as Mode | undefined;
  const childId = parsed.child_id?.trim() ?? "";
  const payload = parsed.payload ?? {};

  if (!mode || !allowedModes.has(mode)) {
    return jsonResponse({ message: "وضع المساعد غير مدعوم." }, 400);
  }
  if (!isUuid(childId)) {
    return jsonResponse({ message: "معرف الطفل غير صالح." }, 400);
  }
  if (typeof payload !== "object" || Array.isArray(payload)) {
    return jsonResponse({ message: "البيانات المرسلة غير صالحة." }, 400);
  }

  const requestText = mode === "parse_care_event"
    ? String((payload as Record<string, unknown>).text ?? "")
    : "";
  if (mode === "parse_care_event" && requestText.trim().length > parseTextLimit) {
    return jsonResponse({ message: "النص طويل جدًا." }, 400);
  }
  if (mode === "parse_care_event" && containsEmergencyKeyword(requestText)) {
    return jsonResponse({
      message: "هذه حالة طارئة. اتصلي بالطوارئ أو بالطبيب فورًا.",
      requires_confirmation: false,
      actions: [],
      disclaimer: "هذا ليس ردًا طبيًا.",
    }, 200);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  const geminiModel = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.5-flash";

  if (!supabaseUrl || !anonKey) {
    return jsonResponse({ message: "تعذر تهيئة الاتصال." }, 500);
  }
  if (!geminiKey) {
    return jsonResponse({ message: "المساعد غير متاح الآن." }, 503);
  }

  const authorization = req.headers.get("authorization") ?? "";
  const accessToken = authorization.replace(/^Bearer\s+/i, "").trim();
  if (!accessToken) {
    return jsonResponse({ message: "انتهت الجلسة. سجّلي الدخول مرة أخرى." }, 401);
  }

  const authClient = createClient(supabaseUrl, anonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  const { data: userData, error: userError } = await authClient.auth.getUser(accessToken);
  if (userError || !userData.user) {
    return jsonResponse({ message: "انتهت الجلسة. سجّلي الدخول مرة أخرى." }, 401);
  }

  const user = userData.user;
  const userId = user.id;
  const usage = {
    mode,
    request_chars: rawBody.length,
    succeeded: false,
  };

  try {
    await assertRateLimit(authClient, userId);
    const child = await loadChild(authClient, childId);
    if (!child) {
      return jsonResponse({
        message: "ليس لديكِ صلاحية للوصول إلى بيانات هذا الطفل.",
      }, 403);
    }

    const queryData = await loadModeData(authClient, mode, childId);
    const context = sanitizePayload(payload, mode);
    const geminiBody = buildGeminiRequest({
      mode,
      child,
      context,
      queryData,
      requestText,
      model: geminiModel,
    });
    const geminiResponse = await callGemini(geminiKey, geminiModel, geminiBody);
    const validated = validateGeminiResponse(mode, geminiResponse);
    usage.succeeded = true;
    return jsonResponse(validated, 200);
  } catch (error) {
    const mapped = mapError(error);
    return jsonResponse(mapped.body, mapped.status);
  } finally {
    await recordUsage(authClient, usage);
  }
});

async function assertRateLimit(client: any, userId: string) {
  const now = new Date();
  const oneMinuteAgo = new Date(now.getTime() - 60_000);
  const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60_000);

  const minuteCount = await countUsage(client, userId, oneMinuteAgo);
  if (minuteCount >= minuteLimit) {
    throw new RateLimitError("حاولي مرة أخرى بعد دقيقة.");
  }

  const dailyCount = await countUsage(client, userId, oneDayAgo);
  if (dailyCount >= dailyLimit) {
    throw new RateLimitError("وصلتِ للحد اليومي للمساعد. حاولي غدًا.");
  }
}

async function countUsage(
  client: any,
  userId: string,
  since: Date,
) {
  const { count, error } = await client
    .from("ai_usage_events")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .gte("created_at", since.toISOString());
  if (error) throw error;
  return count ?? 0;
}

async function loadChild(client: any, childId: string) {
  const { data, error } = await client
    .from("children")
    .select("id, stage, birth_date, feeding_type")
    .eq("id", childId)
    .maybeSingle();
  if (error) throw error;
  return data;
}

async function loadModeData(
  client: any,
  mode: Mode,
  childId: string,
) {
  const now = new Date();
  if (mode === "daily_summary") {
    const start = new Date(now.getTime() - 24 * 60 * 60_000);
    const [events] = await Promise.all([fetchCareEvents(client, childId, start, now)]);
    return { events: summarizeDailyEvents(events, now) };
  }

  const start = new Date(now.getTime() - 7 * 24 * 60 * 60_000);
  const [events, questions, vaccinations, growth] = await Promise.all([
    fetchCareEvents(client, childId, start, now),
    fetchQuestions(client, childId),
    fetchVaccinations(client, childId),
    fetchGrowth(client, childId, start),
  ]);
  return {
    events: summarizeWeeklyEvents(events, now),
    questions: summarizeQuestions(questions),
    vaccinations: summarizeVaccinations(vaccinations),
    growth: summarizeGrowth(growth),
  };
}

async function fetchCareEvents(
  client: any,
  childId: string,
  start: Date,
  end: Date,
) {
  const { data, error } = await client
    .from("care_events")
    .select(
      "id,child_id,created_by,event_type,started_at,ended_at,side,feeding_method,amount_ml,diaper_wet,diaper_dirty,temperature_c,medicine_name,medicine_dose,burped,vomited,notes,metadata,created_at,updated_at",
    )
    .eq("child_id", childId)
    .gte("started_at", start.toISOString())
    .lt("started_at", end.toISOString())
    .order("started_at", { ascending: false });
  if (error) throw error;
  return data ?? [];
}

async function fetchQuestions(client: any, childId: string) {
  const { data, error } = await client
    .from("doctor_questions")
    .select("id,child_id,created_by,question,answered_at,created_at")
    .eq("child_id", childId)
    .order("created_at", { ascending: false })
    .limit(12);
  if (error) throw error;
  return data ?? [];
}

async function fetchVaccinations(client: any, childId: string) {
  const { data, error } = await client
    .from("vaccinations")
    .select(
      "id,child_id,created_by,name,dose_label,scheduled_date,administered_date,provider,status,card_image_path,source_name,source_url,created_at,updated_at",
    )
    .eq("child_id", childId)
    .order("scheduled_date", { ascending: true })
    .limit(16);
  if (error) throw error;
  return data ?? [];
}

async function fetchGrowth(
  client: any,
  childId: string,
  start: Date,
) {
  const { data, error } = await client
    .from("growth_measurements")
    .select(
      "id,child_id,created_by,measured_at,weight_kg,height_cm,head_circumference_cm,source,notes,created_at",
    )
    .eq("child_id", childId)
    .gte("measured_at", start.toISOString())
    .order("measured_at", { ascending: false })
    .limit(8);
  if (error) throw error;
  return data ?? [];
}

function buildGeminiRequest({
  mode,
  child,
  context,
  queryData,
  requestText,
  model,
}: {
  mode: Mode;
  child: Record<string, unknown>;
  context: Record<string, unknown>;
  queryData: Record<string, unknown>;
  requestText: string;
  model: string;
}) {
  const systemInstruction = [
    "أنت مساعد أمومة عربي منظم للسجلات فقط.",
    "لا تقدم تشخيصًا طبيًا.",
    "لا توصي بتغيير أدوية أو جرعات.",
    "لا تخترع حقائق أو كميات أو تواريخ.",
    "لا تكتب في قاعدة البيانات مباشرة.",
    "كل حدث مستخرج يحتاج مراجعة الأم قبل الحفظ.",
    "إذا كانت هناك إشارة طوارئ، أرجع رسالة طوارئ قصيرة وواضحة فقط.",
    "أجب بصيغة JSON فقط.",
  ].join(" ");

  const prompt = mode === "parse_care_event"
    ? {
      mode,
      child: safeChildContext(child),
      client_context: context,
      input_text: requestText,
      server_data: queryData,
      instructions: [
        "استخرج حتى 5 أحداث فقط.",
        "استخدم event_type من: feeding, sleep, diaper, food, medicine, temperature, note, pumping.",
        "ضع needs_review = true لكل حدث.",
        "إذا كان الوقت غامضًا، اجعل time_needs_review = true أو date_needs_review = true.",
        "إذا ذُكر التجشؤ أو القيء مع الرضاعة فاحفظ burped و vomited.",
        "لا تخترع اسم دواء أو جرعة أو كمية مفقودة.",
        "إذا كانت الكمية منقسمة بين اليمين واليسار فافصل left_amount_ml و right_amount_ml واحسب amount_ml الإجمالي.",
      ],
    }
    : mode === "daily_summary"
    ? {
      mode,
      child: safeChildContext(child),
      client_context: context,
      server_data: queryData,
      instructions: [
        "أعد ملخصًا عربيًا دافئًا ومختصرًا ليوم الطفل.",
        "اعتمد على الأرقام المحسوبة فقط ولا تخترع تشخيصًا.",
        "اجعل sections تحتوي على ملخصات قصيرة وعناوين عربية.",
      ],
    }
    : {
      mode,
      child: safeChildContext(child),
      client_context: context,
      server_data: queryData,
      instructions: [
        "أعد تقريرًا عربيًا منظمًا خلال سبعة أيام.",
        "قسّم المعلومات إلى أقسام: البيانات المسجلة، الرضاعة، الشفط، النوم، الحفاضات، درجات الحرارة، الأدوية المسجلة، النمو، التطعيمات، ملاحظات الأم، أسئلة للطبيب.",
        "افصل بين الرضاعة والشفط ولا تدمج الكميات.",
        "لا تقدّم جرعات أو تشخيصًا.",
      ],
    };

  return {
    model,
    contents: [{ role: "user", parts: [{ text: JSON.stringify(prompt) }] }],
    systemInstruction: { parts: [{ text: systemInstruction }] },
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: mode === "parse_care_event" ? 1400 : 1800,
      responseMimeType: "application/json",
      responseSchema: responseSchema(mode),
    },
  };
}

function safeChildContext(child: Record<string, unknown>) {
  const birthDate = dateValue(child.birth_date);
  const now = new Date();
  return {
    id: stringValue(child.id),
    stage: stringValue(child.stage),
    feeding_type: stringValue(child.feeding_type),
    birth_date: stringValue(child.birth_date),
    age_in_days: birthDate ? Math.max(0, Math.floor((now.getTime() - birthDate.getTime()) / 86400000)) : null,
  };
}

function responseSchema(mode: Mode) {
  const common = {
    type: "object",
    properties: {
      message: { type: "string" },
      requires_confirmation: { type: "boolean" },
      disclaimer: { type: "string" },
    },
    required: ["message"],
  };
  if (mode === "parse_care_event") {
    return {
      ...common,
      properties: {
        ...common.properties,
        actions: {
          type: "array",
          items: {
            type: "object",
            properties: {
              event_type: { type: "string" },
              started_at: { type: ["string", "null"] },
              ended_at: { type: ["string", "null"] },
              feeding_methods: { type: "array", items: { type: "string" } },
              side: { type: ["string", "null"] },
              amount_ml: { type: ["number", "null"] },
              diaper_wet: { type: ["boolean", "null"] },
              diaper_dirty: { type: ["boolean", "null"] },
              temperature_c: { type: ["number", "null"] },
              medicine_name: { type: ["string", "null"] },
              medicine_dose: { type: ["string", "null"] },
              food_name: { type: ["string", "null"] },
              left_amount_ml: { type: ["number", "null"] },
              right_amount_ml: { type: ["number", "null"] },
              burped: { type: ["boolean", "null"] },
              vomited: { type: ["boolean", "null"] },
              notes: { type: ["string", "null"] },
              confidence: { type: ["number", "null"] },
              needs_review: { type: "boolean" },
              time_needs_review: { type: "boolean" },
              date_needs_review: { type: "boolean" },
            },
          },
        },
      },
      required: ["message", "requires_confirmation", "actions"],
    };
  }

  return {
    ...common,
    properties: {
      ...common.properties,
      sections: {
        type: "array",
        items: {
          type: "object",
          properties: {
            title: { type: "string" },
            items: { type: "array", items: { type: "string" } },
          },
        },
      },
    },
    required: ["message", "requires_confirmation", "sections"],
  };
}

async function callGemini(apiKey: string, model: string, body: unknown) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort("timeout"), geminiTimeoutMs);
  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": apiKey,
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      },
    );
    if (!response.ok) {
      throw new GeminiHttpError(response.status, await safeText(response));
    }
    const json = await response.json();
    const text = extractGeminiText(json);
    if (!text) throw new GeminiEmptyResponseError();
    return JSON.parse(text);
  } finally {
    clearTimeout(timer);
  }
}

function extractGeminiText(payload: any): string | null {
  const candidates = payload?.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;
  const parts = candidates[0]?.content?.parts;
  if (!Array.isArray(parts)) return null;
  const text = parts
    .map((part: any) => (typeof part?.text === "string" ? part.text : ""))
    .join("")
    .trim();
  return text.length > 0 ? text : null;
}

function validateGeminiResponse(mode: Mode, response: unknown) {
  if (typeof response !== "object" || response === null || Array.isArray(response)) {
    throw new InvalidAiResponseError();
  }
  const json = response as Record<string, unknown>;
  const message = stringValue(json.message) ?? "";
  if (!message) throw new InvalidAiResponseError();
  const requiresConfirmation = booleanValue(
    json.requires_confirmation ?? json.requiresConfirmation,
  ) ?? (mode === "parse_care_event");
  const disclaimer = stringValue(json.disclaimer) ??
    (mode === "daily_summary"
      ? "هذا ملخص للسجلات وليس تقييمًا طبيًا."
      : mode === "doctor_summary"
      ? "هذا التقرير مبني على سجلات الأسرة ولا يمثل تشخيصًا طبيًا."
      : undefined);

  if (mode === "parse_care_event") {
    const actions = Array.isArray(json.actions) ? json.actions : [];
    const normalized = actions.slice(0, 5).map(normalizeAction);
    return {
      message,
      requires_confirmation: normalized.length > 0 ? requiresConfirmation : false,
      actions: normalized,
      disclaimer: disclaimer ?? (normalized.length > 0
        ? "هذا ليس تشخيصًا طبيًا."
        : "لم أتمكن من فهم التسجيل بالكامل."),
    };
  }

  const sections = Array.isArray(json.sections) ? json.sections : [];
  if (sections.length === 0) throw new InvalidAiResponseError();
  return {
    message,
    requires_confirmation: requiresConfirmation,
    sections: sections.map(normalizeSection).filter(Boolean),
    disclaimer: disclaimer ?? (mode === "daily_summary"
      ? "هذا ملخص للسجلات وليس تقييمًا طبيًا."
      : "هذا التقرير مبني على سجلات الأسرة ولا يمثل تشخيصًا طبيًا."),
  };
}

function normalizeAction(action: unknown) {
  if (typeof action !== "object" || action === null || Array.isArray(action)) {
    throw new InvalidAiResponseError();
  }
  const json = action as Record<string, unknown>;
  const eventType = canonicalEventType(stringValue(json.event_type));
  if (!eventType) throw new InvalidAiResponseError();
  return {
    event_type: eventType,
    started_at: stringValue(json.started_at),
    ended_at: stringValue(json.ended_at),
    feeding_methods: normalizeStringArray(json.feeding_methods),
    side: canonicalSide(stringValue(json.side)),
    amount_ml: numberValue(json.amount_ml),
    diaper_wet: booleanValue(json.diaper_wet),
    diaper_dirty: booleanValue(json.diaper_dirty),
    temperature_c: numberValue(json.temperature_c),
    medicine_name: stringValue(json.medicine_name),
    medicine_dose: stringValue(json.medicine_dose),
    food_name: stringValue(json.food_name),
    left_amount_ml: numberValue(json.left_amount_ml),
    right_amount_ml: numberValue(json.right_amount_ml),
    burped: booleanValue(json.burped),
    vomited: booleanValue(json.vomited),
    notes: stringValue(json.notes),
    confidence: numberValue(json.confidence),
    needs_review: booleanValue(json.needs_review) ?? true,
    time_needs_review: booleanValue(json.time_needs_review) ?? false,
    date_needs_review: booleanValue(json.date_needs_review) ?? false,
  };
}

function normalizeSection(section: unknown) {
  if (typeof section !== "object" || section === null || Array.isArray(section)) {
    throw new InvalidAiResponseError();
  }
  const json = section as Record<string, unknown>;
  const title = stringValue(json.title) ?? "";
  const items = normalizeStringArray(json.items);
  if (!title && items.length === 0) throw new InvalidAiResponseError();
  return { title, items };
}

function canonicalEventType(value?: string | null) {
  if (!value) return null;
  const normalized = value.toLowerCase().trim();
  const map: Record<string, string> = {
    feeding: "feeding",
    feed: "feeding",
    sleep: "sleep",
    diaper: "diaper",
    food: "food",
    medicine: "medicine",
    temperature: "temperature",
    note: "note",
    pumping: "pumping",
  };
  return map[normalized] ?? null;
}

function canonicalSide(value?: string | null) {
  if (!value) return null;
  const normalized = value.toLowerCase().trim();
  const map: Record<string, string> = {
    left: "left",
    right: "right",
    both: "both",
  };
  return map[normalized] ?? null;
}

function normalizeStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => stringValue(item))
    .filter((item): item is string => Boolean(item));
}

function stringValue(value: unknown) {
  if (typeof value !== "string") return null;
  const text = value.trim();
  return text.length > 0 ? text : null;
}

function numberValue(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string") {
    const parsed = Number(value.replace(",", "."));
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function dateValue(value: unknown) {
  const text = stringValue(value);
  if (!text) return null;
  const parsed = new Date(text);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function booleanValue(value: unknown) {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  if (typeof value === "string") {
    const normalized = value.toLowerCase().trim();
    if (["true", "yes", "1", "نعم"].includes(normalized)) return true;
    if (["false", "no", "0", "لا"].includes(normalized)) return false;
  }
  return null;
}

function containsEmergencyKeyword(text: string) {
  const normalized = text.toLowerCase();
  return emergencyKeywords.some((keyword) => normalized.includes(keyword.toLowerCase()));
}

async function recordUsage(
  client: any,
  usage: {
    mode: Mode;
    request_chars: number;
    succeeded: boolean;
  },
) {
  try {
    await client.from("ai_usage_events").insert(usage);
  } catch {
    // Usage tracking should not break the user-facing response.
  }
}

function mapError(error: unknown) {
  if (error instanceof RateLimitError) {
    return { status: 429, code: "rate_limit", body: { message: error.message } };
  }
  if (error instanceof GeminiHttpError) {
    if (error.status === 401) {
      return { status: 503, code: "gemini_unavailable", body: { message: "تعذر الحصول على رد من المساعد الآن." } };
    }
    return {
      status: 503,
      code: "gemini_unavailable",
      body: { message: "تعذر الحصول على رد من المساعد الآن." },
    };
  }
  if (error instanceof GeminiEmptyResponseError || error instanceof InvalidAiResponseError) {
    return {
      status: 502,
      code: "invalid_ai_response",
      body: { message: "تعذر فهم رد المساعد الآن." },
    };
  }
  const text = String(error).toLowerCase();
  if (text.includes("timeout")) {
    return { status: 504, code: "timeout", body: { message: "استغرق المساعد وقتًا أطول من المتوقع." } };
  }
  if (text.includes("forbidden")) {
    return { status: 403, code: "forbidden", body: { message: "ليس لديكِ صلاحية للوصول إلى بيانات هذا الطفل." } };
  }
  if (text.includes("unauthorized")) {
    return { status: 401, code: "unauthorized", body: { message: "انتهت الجلسة. سجّلي الدخول مرة أخرى." } };
  }
  return {
    status: 503,
    code: "ai_unavailable",
    body: { message: "تعذر الحصول على رد من المساعد الآن." },
  };
}

function sanitizePayload(payload: Record<string, unknown>, mode: Mode) {
  if (mode !== "parse_care_event") return {};
  const text = typeof payload.text === "string" ? payload.text.trim() : "";
  return {
    text: text.slice(0, parseTextLimit),
  };
}

function summarizeDailyEvents(events: Record<string, unknown>[], now: Date) {
  const filtered = events.slice(0, 24);
  const feeding = filtered.filter((event) => event.event_type === "feeding" && !isPumping(event));
  const pumping = filtered.filter((event) => isPumping(event));
  const sleep = filtered.filter((event) => event.event_type === "sleep");
  const diaper = filtered.filter((event) => event.event_type === "diaper");
  const temps = filtered
    .filter((event) => event.event_type === "temperature" && typeof event.temperature_c === "number")
    .map((event) => event.temperature_c as number);
  const medicine = filtered.filter((event) => event.event_type === "medicine");
  return {
    current_local_datetime: now.toISOString(),
    feeding_count: feeding.length,
    feeding_total_ml: sumAmount(feeding),
    sleep_minutes: sumSleepMinutes(sleep, now),
    sleep_sessions: sleep.length,
    wet_diaper_count: diaper.filter((event) => event.diaper_wet === true).length,
    dirty_diaper_count: diaper.filter((event) => event.diaper_dirty === true).length,
    pumping_sessions: pumping.length,
    pumping_total_ml: sumAmount(pumping),
    temperature_readings: temps.slice(0, 8),
    medicine_count: medicine.length,
    recent_notes: recentNotes(filtered, 5),
  };
}

function summarizeWeeklyEvents(events: Record<string, unknown>[], now: Date) {
  const filtered = events.slice(0, 80);
  return {
    current_local_datetime: now.toISOString(),
    feeding_count: filtered.filter((event) => event.event_type === 'feeding' && !isPumping(event)).length,
    feeding_total_ml: sumAmount(filtered.filter((event) => event.event_type === 'feeding' && !isPumping(event))),
    pumping_sessions: filtered.filter((event) => isPumping(event)).length,
    pumping_total_ml: sumAmount(filtered.filter((event) => isPumping(event))),
    sleep_minutes: sumSleepMinutes(filtered.filter((event) => event.event_type === 'sleep'), now),
    sleep_sessions: filtered.filter((event) => event.event_type === 'sleep').length,
    wet_diaper_count: filtered.filter((event) => event.event_type === 'diaper' && event.diaper_wet === true).length,
    dirty_diaper_count: filtered.filter((event) => event.event_type === 'diaper' && event.diaper_dirty === true).length,
    temperature_readings: filtered
      .filter((event) => event.event_type === 'temperature' && typeof event.temperature_c === 'number')
      .map((event) => event.temperature_c as number)
      .slice(0, 8),
    medicine_count: filtered.filter((event) => event.event_type === 'medicine').length,
    recent_notes: recentNotes(filtered, 8),
  };
}

function summarizeQuestions(questions: Record<string, unknown>[]) {
  return questions.slice(0, 8).map((question) => ({
    question: stringValue(question.question) ?? '',
    answered: question.answered_at != null,
  }));
}

function summarizeVaccinations(vaccinations: Record<string, unknown>[]) {
  return vaccinations.slice(0, 10).map((vaccination) => ({
    name: stringValue(vaccination.name) ?? '',
    dose_label: stringValue(vaccination.dose_label),
    scheduled_date: stringValue(vaccination.scheduled_date),
    administered_date: stringValue(vaccination.administered_date),
    status: stringValue(vaccination.status) ?? 'scheduled',
    provider: stringValue(vaccination.provider),
  }));
}

function summarizeGrowth(growth: Record<string, unknown>[]) {
  return growth.slice(0, 8).map((measurement) => ({
    measured_at: stringValue(measurement.measured_at),
    weight_kg: numberValue(measurement.weight_kg),
    height_cm: numberValue(measurement.height_cm),
    head_circumference_cm: numberValue(measurement.head_circumference_cm),
    notes: stringValue(measurement.notes),
  }));
}

function recentNotes(events: Record<string, unknown>[], limit: number) {
  return events
    .map((event) => stringValue(event.notes))
    .filter((note): note is string => Boolean(note))
    .slice(0, limit);
}

function sumAmount(events: Record<string, unknown>[]) {
  return events.reduce((total, event) => total + (numberValue(event.amount_ml) ?? 0), 0);
}

function sumSleepMinutes(events: Record<string, unknown>[], now: Date) {
  return events.reduce((total, event) => {
    const started = dateValue(event.started_at);
    if (!started) return total;
    const ended = dateValue(event.ended_at) ?? now;
    const diff = ended.getTime() - started.getTime();
    return diff > 0 ? total + Math.round(diff / 60000) : total;
  }, 0);
}

function isPumping(event: Record<string, unknown>) {
  if (event.event_type === 'pumping') return true;
  if (event.event_type !== 'feeding') return false;
  const methods = event.feeding_method;
  if (typeof methods === 'string') return methods === 'pumping';
  if (Array.isArray(methods)) return methods.map(String).includes('pumping');
  const metadata = event.metadata;
  if (metadata && typeof metadata === 'object' && !Array.isArray(metadata)) {
    const feedingMethods = (metadata as Record<string, unknown>).feeding_methods;
    if (Array.isArray(feedingMethods)) {
      return feedingMethods.map(String).includes('pumping');
    }
  }
  return false;
}

function jsonResponse(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...corsHeaders,
    },
  });
}

async function safeText(response: Response) {
  try {
    return await response.text();
  } catch {
    return "";
  }
}

function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}

class RateLimitError extends Error {}
class GeminiHttpError extends Error {
  constructor(public readonly status: number, public readonly details: string) {
    super(`Gemini HTTP ${status}`);
  }
}
class GeminiEmptyResponseError extends Error {}
class InvalidAiResponseError extends Error {}

