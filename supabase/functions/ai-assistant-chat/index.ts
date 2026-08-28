import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const requestLimitBytes = 12000;
const questionLimit = 700;
const minuteLimit = 6;
const dailyLimit = 50;
const geminiTimeoutMs = 30000;

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
  const childId = parsed.child_id?.trim() ?? "";
  const payload = parsed.payload ?? {};
  const question = String(payload.question ?? "").trim();

  if (parsed.mode !== "chat") {
    return jsonResponse({ message: "وضع المساعد غير مدعوم." }, 400);
  }
  if (!isUuid(childId)) {
    return jsonResponse({ message: "معرف الطفل غير صالح." }, 400);
  }
  if (!question) {
    return jsonResponse({ message: "اكتبي سؤالك أولًا." }, 400);
  }
  if (question.length > questionLimit) {
    return jsonResponse({ message: "السؤال طويل جدًا. اختصريه وحاولي مرة أخرى." }, 400);
  }
  if (containsEmergencyKeyword(question)) {
    return jsonResponse({
      message: "هذه حالة طارئة. اتصلي بالطوارئ أو بالطبيب فورًا.",
      requires_confirmation: false,
      sections: [],
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
    global: { headers: { Authorization: `Bearer ${accessToken}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userError } = await authClient.auth.getUser(accessToken);
  if (userError || !userData.user) {
    return jsonResponse({ message: "انتهت الجلسة. سجّلي الدخول مرة أخرى." }, 401);
  }

  const userId = userData.user.id;
  const usage = {
    mode: "chat",
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

    const events = await fetchRecentCareEvents(authClient, childId);
    const geminiBody = buildGeminiRequest({
      child,
      events: summarizeEvents(events),
      payload: sanitizePayload(payload),
      question,
      model: geminiModel,
    });
    const geminiResponse = await callGemini(geminiKey, geminiModel, geminiBody);
    const validated = validateChatResponse(geminiResponse);
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

async function countUsage(client: any, userId: string, since: Date) {
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
    .select("id, name, stage, birth_date, feeding_type")
    .eq("id", childId)
    .maybeSingle();
  if (error) throw error;
  return data;
}

async function fetchRecentCareEvents(client: any, childId: string) {
  const since = new Date(Date.now() - 7 * 24 * 60 * 60_000).toISOString();
  const { data, error } = await client
    .from("care_events")
    .select("event_type,started_at,ended_at,side,feeding_method,amount_ml,diaper_wet,diaper_dirty,temperature_c,medicine_name,medicine_dose,burped,vomited,notes")
    .eq("child_id", childId)
    .gte("started_at", since)
    .order("started_at", { ascending: false })
    .limit(60);
  if (error) throw error;
  return data ?? [];
}

function buildGeminiRequest({
  child,
  events,
  payload,
  question,
  model,
}: {
  child: Record<string, unknown>;
  events: unknown[];
  payload: Record<string, unknown>;
  question: string;
  model: string;
}) {
  const systemInstruction = [
    "أنت مساعد أمومة عربي داخل تطبيق نُمُوّ.",
    "استخدم سجلات الطفل المرسلة فقط ولا تخترع أرقامًا أو مواعيد.",
    "لا تقدم تشخيصًا طبيًا أو تغيير جرعات أو بدائل علاجية.",
    "عند الشك أو وجود أعراض مقلقة، وجّه الأم للطبيب أو الطوارئ.",
    "أجب بصيغة JSON فقط مطابقة للمخطط.",
  ].join(" ");

  const prompt = {
    mode: "chat",
    child: safeChildContext(child),
    recent_events: events,
    client_context: payload,
    question,
    instructions: [
      "اجعلي الرد عربيًا دافئًا ومختصرًا ومناسبًا لأم مرهقة.",
      "استخدم sections عند الحاجة لتقسيم الرد إلى نقاط عملية.",
      "لا تحفظ أي شيء في قاعدة البيانات ولا تنشئ actions.",
      "ضع disclaimer طبي قصير دائمًا.",
    ],
  };

  return {
    model,
    contents: [{ role: "user", parts: [{ text: JSON.stringify(prompt) }] }],
    systemInstruction: { parts: [{ text: systemInstruction }] },
    generationConfig: {
      temperature: 0.25,
      maxOutputTokens: 1400,
      responseMimeType: "application/json",
      responseSchema: {
        type: "object",
        properties: {
          message: { type: "string" },
          requires_confirmation: { type: "boolean" },
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
          disclaimer: { type: "string" },
        },
        required: ["message", "requires_confirmation", "sections"],
      },
    },
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
    if (!response.ok) throw new GeminiHttpError(response.status, await safeText(response));
    const json = await response.json();
    const text = extractGeminiText(json);
    if (!text) throw new GeminiEmptyResponseError();
    return JSON.parse(text);
  } finally {
    clearTimeout(timer);
  }
}

function validateChatResponse(response: unknown) {
  if (typeof response !== "object" || response === null || Array.isArray(response)) {
    throw new InvalidAiResponseError();
  }
  const json = response as Record<string, unknown>;
  const message = stringValue(json.message) ?? "";
  if (!message) throw new InvalidAiResponseError();
  const sections = Array.isArray(json.sections) ? json.sections.map(normalizeSection).filter(Boolean) : [];
  return {
    message,
    requires_confirmation: false,
    sections,
    disclaimer: stringValue(json.disclaimer) ?? "هذا رد مبني على السجلات وليس تقييمًا طبيًا.",
  };
}

function normalizeSection(section: unknown) {
  if (typeof section !== "object" || section === null || Array.isArray(section)) return null;
  const json = section as Record<string, unknown>;
  const title = stringValue(json.title) ?? "";
  const items = normalizeStringArray(json.items);
  if (!title && items.length === 0) return null;
  return { title, items };
}

function summarizeEvents(events: any[]) {
  return events.map((event) => ({
    event_type: stringValue(event.event_type),
    started_at: stringValue(event.started_at),
    ended_at: stringValue(event.ended_at),
    side: stringValue(event.side),
    feeding_method: stringValue(event.feeding_method),
    amount_ml: numberValue(event.amount_ml),
    diaper_wet: booleanValue(event.diaper_wet),
    diaper_dirty: booleanValue(event.diaper_dirty),
    temperature_c: numberValue(event.temperature_c),
    medicine_name: stringValue(event.medicine_name),
    medicine_dose: stringValue(event.medicine_dose),
    burped: booleanValue(event.burped),
    vomited: booleanValue(event.vomited),
    notes: stringValue(event.notes),
  }));
}

function safeChildContext(child: Record<string, unknown>) {
  const birthDate = dateValue(child.birth_date);
  const now = new Date();
  return {
    id: stringValue(child.id),
    name: stringValue(child.name),
    stage: stringValue(child.stage),
    feeding_type: stringValue(child.feeding_type),
    birth_date: stringValue(child.birth_date),
    age_in_days: birthDate ? Math.max(0, Math.floor((now.getTime() - birthDate.getTime()) / 86400000)) : null,
  };
}

function sanitizePayload(payload: Record<string, unknown>) {
  const clone = { ...payload };
  delete clone.question;
  return clone;
}

function containsEmergencyKeyword(text: string) {
  const normalized = text.toLowerCase();
  return emergencyKeywords.some((keyword) => normalized.includes(keyword));
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

function normalizeStringArray(value: unknown) {
  if (!Array.isArray(value)) return [];
  return value.map(stringValue).filter(Boolean) as string[];
}

function stringValue(value: unknown) {
  if (value === null || value === undefined) return undefined;
  const text = String(value).trim();
  return text.length > 0 ? text : undefined;
}

function numberValue(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function booleanValue(value: unknown) {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const text = stringValue(value)?.toLowerCase();
  if (["true", "1", "yes", "نعم"].includes(text ?? "")) return true;
  if (["false", "0", "no", "لا"].includes(text ?? "")) return false;
  return null;
}

function dateValue(value: unknown) {
  const text = stringValue(value);
  if (!text) return null;
  const date = new Date(text);
  return Number.isNaN(date.getTime()) ? null : date;
}

function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}

async function recordUsage(client: any, usage: Record<string, unknown>) {
  try {
    await client.from("ai_usage_events").insert(usage);
  } catch {
    // Usage logging must never block the parent-facing assistant response.
  }
}

async function safeText(response: Response) {
  try {
    return await response.text();
  } catch {
    return "";
  }
}

function jsonResponse(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

class RateLimitError extends Error {}
class InvalidAiResponseError extends Error {}
class GeminiEmptyResponseError extends Error {}
class GeminiHttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

function mapError(error: unknown) {
  if (error instanceof RateLimitError) {
    return { status: 429, body: { message: error.message } };
  }
  if (error instanceof GeminiHttpError) {
    return {
      status: error.status === 429 ? 429 : 503,
      body: { message: error.status === 429 ? "حاولي مرة أخرى بعد دقيقة." : "المساعد غير متاح الآن." },
    };
  }
  if (error instanceof GeminiEmptyResponseError || error instanceof InvalidAiResponseError) {
    return { status: 502, body: { message: "لم يصلني رد واضح. جرّبي مرة أخرى بعد قليل." } };
  }
  const text = String(error).toLowerCase();
  if (text.includes("timeout") || text.includes("abort")) {
    return { status: 504, body: { message: "استغرق الرد وقتًا طويلًا. حاولي مرة أخرى." } };
  }
  return { status: 503, body: { message: "المساعد غير متاح الآن." } };
}
