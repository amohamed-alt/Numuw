import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json; charset=utf-8" },
  });

const cleanOptional = (value: unknown, maxLength: number) => {
  if (typeof value !== "string") return null;
  const cleaned = value.trim();
  if (!cleaned) return null;
  return cleaned.slice(0, maxLength);
};

serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);
  if (req.method !== "POST") {
    return jsonResponse({ message: "Method not allowed." }, 405);
  }

  const authorization = req.headers.get("Authorization") ?? "";
  if (!authorization.toLowerCase().startsWith("bearer ")) {
    return jsonResponse({ message: "يلزم تسجيل الدخول من جديد." }, 401);
  }

  let body: {
    token?: unknown;
    platform?: unknown;
    timezone?: unknown;
    locale?: unknown;
    appVersion?: unknown;
  };
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ message: "الطلب غير صالح." }, 400);
  }

  const token = typeof body.token === "string" ? body.token.trim() : "";
  const platform = typeof body.platform === "string"
    ? body.platform.trim().toLowerCase()
    : "";
  if (token.length < 20 || token.length > 4096) {
    return jsonResponse({ message: "رمز الإشعارات غير صالح." }, 400);
  }
  if (!new Set(["android", "ios", "web"]).has(platform)) {
    return jsonResponse({ message: "منصة الإشعارات غير مدعومة." }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error("register-push-device: missing required Supabase environment variables");
    return jsonResponse({ message: "تعذر تسجيل الإشعارات حاليًا." }, 500);
  }

  const caller = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userError } = await caller.auth.getUser();
  const user = userData.user;
  if (userError || !user) {
    return jsonResponse(
      { message: "انتهت الجلسة. سجّلي الدخول من جديد ثم حاولي مرة أخرى." },
      401,
    );
  }

  const { error: upsertError } = await admin.from("push_devices").upsert(
    {
      user_id: user.id,
      platform,
      token,
      timezone: cleanOptional(body.timezone, 128),
      locale: cleanOptional(body.locale, 32),
      app_version: cleanOptional(body.appVersion, 64),
      enabled: true,
      last_seen_at: new Date().toISOString(),
    },
    { onConflict: "token" },
  );

  if (upsertError) {
    console.error("register-push-device: ownership claim failed", {
      code: upsertError.code,
      userId: user.id,
    });
    return jsonResponse({ message: "تعذر تسجيل الإشعارات حاليًا." }, 500);
  }

  return jsonResponse({ registered: true }, 200);
});
