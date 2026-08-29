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

serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);
  if (req.method !== "POST") {
    return jsonResponse({ message: "Method not allowed." }, 405);
  }

  const authorization = req.headers.get("Authorization") ?? "";
  if (!authorization.toLowerCase().startsWith("bearer ")) {
    return jsonResponse({ message: "يلزم تسجيل الدخول من جديد." }, 401);
  }

  let body: { confirmation?: string } = {};
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ message: "الطلب غير صالح." }, 400);
  }
  if (body.confirmation !== "DELETE_NUMUW_ACCOUNT") {
    return jsonResponse({ message: "تأكيد حذف الحساب غير صالح." }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error("delete-account: missing required Supabase environment variables");
    return jsonResponse({ message: "تعذر تجهيز حذف الحساب حاليًا." }, 500);
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

  try {
    const { data: memberships, error: membershipError } = await admin
      .from("child_members")
      .select("child_id")
      .eq("user_id", user.id);
    if (membershipError) throw membershipError;

    const childIds = [
      ...new Set((memberships ?? []).map((row) => String(row.child_id))),
    ];

    for (const childId of childIds) {
      const { data: child, error: childError } = await admin
        .from("children")
        .select("id,created_by")
        .eq("id", childId)
        .maybeSingle();
      if (childError) throw childError;
      if (!child) continue;

      if (child.created_by === user.id) {
        const { data: candidates, error: candidateError } = await admin
          .from("child_members")
          .select("user_id,role,can_edit,created_at")
          .eq("child_id", childId)
          .neq("user_id", user.id)
          .eq("can_edit", true)
          .order("created_at", { ascending: true });
        if (candidateError) throw candidateError;

        const ranked = [...(candidates ?? [])].sort((a, b) => {
          const rank = (role: string) =>
            role === "owner"
              ? 0
              : role === "parent"
                ? 1
                : role === "caregiver"
                  ? 2
                  : 3;
          const difference = rank(String(a.role)) - rank(String(b.role));
          if (difference !== 0) return difference;
          return String(a.created_at).localeCompare(String(b.created_at));
        });
        const successorId = ranked[0]?.user_id
          ? String(ranked[0].user_id)
          : null;

        if (!successorId) {
          await removeChildStorage(admin, childId);
          const { error: childDeleteError } = await admin
            .from("children")
            .delete()
            .eq("id", childId)
            .eq("created_by", user.id);
          if (childDeleteError) throw childDeleteError;
          continue;
        }

        const { error: promoteError } = await admin
          .from("child_members")
          .update({ role: "owner", can_edit: true })
          .eq("child_id", childId)
          .eq("user_id", successorId);
        if (promoteError) throw promoteError;

        await rehomeChildAuthoredData(admin, childId, user.id, successorId);

        const { error: childTransferError } = await admin
          .from("children")
          .update({ created_by: successorId })
          .eq("id", childId)
          .eq("created_by", user.id);
        if (childTransferError) throw childTransferError;
      } else {
        await rehomeChildAuthoredData(
          admin,
          childId,
          user.id,
          String(child.created_by),
        );
      }
    }

    await cleanupUserReferences(admin, user.id);

    const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
    if (deleteError) {
      console.error("delete-account: auth deletion failed", deleteError);
      return jsonResponse(
        {
          message:
            "تعذر حذف الحساب بالكامل. لم يتم تأكيد الحذف، وحاولي مرة أخرى أو تواصلي مع الدعم.",
        },
        409,
      );
    }

    return jsonResponse({ deleted: true }, 200);
  } catch (error) {
    console.error("delete-account failed", error);
    return jsonResponse(
      { message: "تعذر حذف الحساب حاليًا. لم يتم تأكيد الحذف." },
      500,
    );
  }
});

async function rehomeChildAuthoredData(
  admin: ReturnType<typeof createClient>,
  childId: string,
  departingUserId: string,
  successorId: string,
) {
  const { error: documentError } = await admin
    .from("child_documents")
    .update({ uploaded_by: successorId })
    .eq("child_id", childId)
    .eq("uploaded_by", departingUserId);
  if (documentError) throw documentError;

  for (const table of [
    "care_events",
    "growth_measurements",
    "vaccinations",
    "doctor_questions",
    "family_tasks",
  ]) {
    const { error } = await admin
      .from(table)
      .update({ created_by: successorId })
      .eq("child_id", childId)
      .eq("created_by", departingUserId);
    if (error) throw error;
  }

  const { error: unassignError } = await admin
    .from("family_tasks")
    .update({ assigned_to: null })
    .eq("child_id", childId)
    .eq("assigned_to", departingUserId);
  if (unassignError) throw unassignError;
}

async function cleanupUserReferences(
  admin: ReturnType<typeof createClient>,
  userId: string,
) {
  const { error: acceptedInviteError } = await admin
    .from("family_invites")
    .update({ accepted_by: null })
    .eq("accepted_by", userId);
  if (acceptedInviteError) throw acceptedInviteError;

  const { error: createdInviteError } = await admin
    .from("family_invites")
    .delete()
    .eq("created_by", userId);
  if (createdInviteError) throw createdInviteError;

  const { error: assignedTaskError } = await admin
    .from("family_tasks")
    .update({ assigned_to: null })
    .eq("assigned_to", userId);
  if (assignedTaskError) throw assignedTaskError;

  const { error: membershipsError } = await admin
    .from("child_members")
    .delete()
    .eq("user_id", userId);
  if (membershipsError) throw membershipsError;

  const { error: usageError } = await admin
    .from("ai_usage_events")
    .delete()
    .eq("user_id", userId);
  if (usageError) throw usageError;

  const { error: profileError } = await admin
    .from("profiles")
    .delete()
    .eq("id", userId);
  if (profileError) throw profileError;
}

async function removeChildStorage(
  admin: ReturnType<typeof createClient>,
  childId: string,
) {
  const { data: documents, error } = await admin
    .from("child_documents")
    .select("storage_bucket,storage_path")
    .eq("child_id", childId);
  if (error) throw error;

  const byBucket = new Map<string, string[]>();
  for (const document of documents ?? []) {
    const bucket = String(document.storage_bucket);
    const paths = byBucket.get(bucket) ?? [];
    paths.push(String(document.storage_path));
    byBucket.set(bucket, paths);
  }

  for (const [bucket, paths] of byBucket.entries()) {
    if (paths.length === 0) continue;
    const { error: removeError } = await admin.storage.from(bucket).remove(paths);
    if (removeError) throw removeError;
  }
}
