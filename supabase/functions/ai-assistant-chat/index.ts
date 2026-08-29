import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "@supabase/supabase-js";

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
  if (req.method === "OPTIONS") return respond({}, 200);
  if (req.method !== "POST") {
    return respond({ message: "Method not allowed." }, 405);
  }

  const rawBody = await req.text();
  if (rawBody.length > requestLimitBytes) {
    return respond({ message: "الطلب أكبر من الحد المسموح." }, 400);
  }

  let body: unknown;
  try {
    body = JSON.parse(rawBody);
  } catch {
    return respond({ message: "الطلب غير صالح." }, 400);
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
    return respond({ message: "وضع المساعد غير مدعوم." }, 400);
  }
  if (!isUuid(childId)) {
    return respond({ message: "معرف الطفل غير صالح." }, 400);
  }
  if (!question) return respond({ message: "اكتبي سؤالك أولًا." }, 400);
  if (question.length > questionLimit) {
    return respond({ message: "السؤال طويل جدًا. اختصريه وحاولي مرة أخرى." }, 400);
  }
  if (containsEmergencyKeyword(question)) {
    return respond(
      {
        message:
          "هذه حالة طارئة. اتصلي بالطوارئ أو بطبيب الطفل فورًا ولا تنتظري رد التطبيق.",
        requires_confirmation: false,
        sections: [],
        disclaimer: "هذا ليس تشخيصًا طبيًا.",
      },
      200,
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  const geminiModel = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.5-flash";

  if (!supabaseUrl || !anonKey) {
    return respond({ message: "تعذر تهيئة الاتصال." }, 500);
  }
  if (!geminiKey) return respond({ message: "المساعد غير متاح الآن." }, 503);

  const authorization = req.headers.get("authorization") ?? "";
  const accessToken = authorization.replace(/^Bearer\s+/i, "").trim();
  if (!accessToken) {
    return respond({ message: "انتهت الجلسة. سجّلي الدخول مرة أخرى." }, 401);
  }

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${accessToken}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userError } = await client.auth.getUser(
    accessToken,
  );
  if (userError || !userData.user) {
    return respond({ message: "انتهت الجلسة. سجّلي الدخول مرة أخرى." }, 401);
  }

  const userId = userData.user.id;
  let succeeded = false;

  try {
    await assertRateLimit(client, userId);

    const { data: child, error: childError } = await client
      .from("children")
      .select("id,name,stage,birth_date,due_date,feeding_type")
      .eq("id", childId)
      .maybeSingle();
    if (childError) throw childError;
    if (!child) {
      return respond(
        { message: "ليس لديكِ صلاحية للوصول إلى بيانات هذا الطفل." },
        403,
      );
    }

    const since = new Date(Date.now() - 7 * 24 * 60 * 60_000).toISOString();
    const { data: events, error: eventsError } = await client
      .from("care_events")
      .select(
        "event_type,started_at,ended_at,side,feeding_method,amount_ml,diaper_wet,diaper_dirty,temperature_c,medicine_name,medicine_dose,burped,vomited,notes",
      )
      .eq("child_id", childId)
      .gte("started_at", since)
      .order("started_at", { ascending: false })
      .limit(60);
    if (eventsError) throw eventsError;

    const safeContext = { child, recent_events: events ?? [], question };
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), geminiTimeoutMs);

    try {
      const result = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(geminiModel)}:generateContent`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": geminiKey,
          },
          body: JSON.stringify({
            systemInstruction: {
              parts: [
                {
                  text: [
                    "أنت مساعد أمومة عربي داخل تطبيق نُمُوّ.",
                    "استخدم فقط بيانات الطفل التي أرسلها الخادم ولا تخترع أرقامًا أو مواعيد.",
                    "لا تقدم تشخيصًا طبيًا أو تغيير جرعات أو بدائل علاجية.",
                    "إذا لم تكف البيانات فقل ذلك بوضوح.",
                    "عند وجود أعراض مقلقة وجّه الأم للطبيب أو الطوارئ.",
                    "أجب بصيغة JSON فقط.",
                  ].join(" "),
                },
              ],
            },
            contents: [
              {
                role: "user",
                parts: [{ text: JSON.stringify(safeContext) }],
              },
            ],
            generationConfig: {
              temperature: 0.2,
              maxOutputTokens: 1200,
              responseMimeType: "application/json",
              responseSchema: {
                type: "object",
                properties: {
                  message: { type: "string" },
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
                required: ["message"],
              },
            },
          }),
          signal: controller.signal,
        },
      );

      if (!result.ok) {
        return respond({ message: "تعذر الحصول على رد من المساعد الآن." }, 503);
      }

      const gemini = await result.json();
      const parts = gemini?.candidates?.[0]?.content?.parts;
      const text = Array.isArray(parts)
        ? parts
            .map((part: { text?: string }) => part.text ?? "")
            .join("")
            .trim()
        : "";
      if (!text) {
        return respond({ message: "تعذر فهم رد المساعد الآن." }, 502);
      }

      const output = JSON.parse(text) as {
        message?: unknown;
        sections?: unknown;
        disclaimer?: unknown;
      };
      const message =
        typeof output.message === "string" ? output.message.trim() : "";
      if (!message) {
        return respond({ message: "تعذر فهم رد المساعد الآن." }, 502);
      }

      succeeded = true;
      return respond(
        {
          message,
          requires_confirmation: false,
          sections: Array.isArray(output.sections)
            ? output.sections.slice(0, 6)
            : [],
          disclaimer:
            typeof output.disclaimer === "string" && output.disclaimer.trim()
              ? output.disclaimer.trim()
              : "هذا رد مبني على السجلات وليس تقييمًا طبيًا.",
        },
        200,
      );
    } finally {
      clearTimeout(timer);
    }
  } catch (error) {
    const value = String(error).toLowerCase();
    if (value.includes("rate_limit_minute")) {
      return respond({ message: "حاولي مرة أخرى بعد دقيقة." }, 429);
    }
    if (value.includes("rate_limit_day")) {
      return respond({ message: "وصلتِ للحد اليومي للمساعد. حاولي غدًا." }, 429);
    }
    if (value.includes("abort") || value.includes("timeout")) {
      return respond(
        { message: "استغرق المساعد وقتًا أطول من المتوقع." },
        504,
      );
    }
    console.error(error);
    return respond({ message: "تعذر الحصول على رد من المساعد الآن." }, 503);
  } finally {
    try {
      await client.from("ai_usage_events").insert({
        user_id: userId,
        mode: "chat",
        request_chars: rawBody.length,
        succeeded,
      });
    } catch {
      // Usage telemetry must never break a user response.
    }
  }
});

async function assertRateLimit(client: ReturnType<typeof createClient>, userId: string) {
  const now = Date.now();
  const minuteCount = await countUsage(
    client,
    userId,
    new Date(now - 60_000).toISOString(),
  );
  if (minuteCount >= minuteLimit) throw new Error("rate_limit_minute");

  const dayCount = await countUsage(
    client,
    userId,
    new Date(now - 24 * 60 * 60_000).toISOString(),
  );
  if (dayCount >= dailyLimit) throw new Error("rate_limit_day");
}

async function countUsage(
  client: ReturnType<typeof createClient>,
  userId: string,
  since: string,
) {
  const { count, error } = await client
    .from("ai_usage_events")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .gte("created_at", since);
  if (error) throw error;
  return count ?? 0;
}

function containsEmergencyKeyword(text: string) {
  const normalized = text.toLowerCase();
  return emergencyKeywords.some((keyword) =>
    normalized.includes(keyword.toLowerCase())
  );
}

function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    value,
  );
}

function respond(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...corsHeaders,
    },
  });
}
