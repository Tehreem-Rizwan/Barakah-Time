// Barakah Time — profile photo upload/delete (Supabase Edge Function, free tier).
//
// The app signs users in with Firebase, not Supabase. This function verifies
// the caller's Firebase ID token itself, then writes to the `images` bucket
// with the service-role key (which only exists here on the server, never in
// the app). So nobody can touch another user's photos, and no paid Firebase
// Cloud Functions / Blaze plan are needed.
//
// Requests (from lib/core/services/supabase_service.dart):
//   POST   /functions/v1/profile-photo   body: raw image bytes
//          headers: Authorization: Bearer <Firebase ID token>,
//                   apikey: <Supabase anon key>, Content-Type: image/*
//          -> 200 { "url": "<public url>" }   (older photos are removed)
//   DELETE /functions/v1/profile-photo   -> 200 { "deleted": n }
//          (removes all of the user's photos; used for account deletion)
//
// Deploy with "Enforce JWT verification" turned OFF (the token is a Firebase
// token, not a Supabase one) — see supabase/README.md.

import { createClient } from "jsr:@supabase/supabase-js@2";
import { createRemoteJWKSet, jwtVerify } from "jsr:@panva/jose@6";

const FIREBASE_PROJECT_ID =
  Deno.env.get("FIREBASE_PROJECT_ID") ?? "barakahtime-cbfa8";
const BUCKET = "images";
const FOLDER = "profile_pics";
const MAX_BYTES = 5 * 1024 * 1024; // 5 MB
const ALLOWED_TYPES: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/gif": "gif",
  "image/heic": "heic",
  "image/heif": "heif",
};

// Google's public keys for Firebase ID tokens (cached by jose).
const firebaseKeys = createRemoteJWKSet(
  new URL(
    "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
  ),
);

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, DELETE, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** Returns the Firebase uid, or null if the token is missing/invalid. */
async function verifyFirebaseUser(req: Request): Promise<string | null> {
  const header = req.headers.get("Authorization") ?? "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : "";
  if (!token) return null;
  try {
    const { payload } = await jwtVerify(token, firebaseKeys, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
      algorithms: ["RS256"],
    });
    const uid = typeof payload.sub === "string" ? payload.sub : "";
    // Firebase uids are 1–128 chars; refuse anything that could escape the folder.
    if (!uid || uid.length > 128 || !/^[A-Za-z0-9_-]+$/.test(uid)) return null;
    return uid;
  } catch (_) {
    return null;
  }
}

async function listUserFiles(uid: string): Promise<string[]> {
  const folder = `${FOLDER}/${uid}`;
  const { data, error } = await supabase.storage
    .from(BUCKET)
    .list(folder, { limit: 1000 });
  if (error) throw error;
  return (data ?? [])
    .filter((f) => f.name && f.id) // skip placeholder/folder entries
    .map((f) => `${folder}/${f.name}`);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const uid = await verifyFirebaseUser(req);
  if (!uid) return json({ error: "unauthorized" }, 401);

  try {
    if (req.method === "POST") {
      const contentType = (req.headers.get("Content-Type") ?? "")
        .split(";")[0]
        .trim()
        .toLowerCase();
      const ext = ALLOWED_TYPES[contentType];
      if (!ext) return json({ error: "unsupported_type" }, 415);

      const bytes = new Uint8Array(await req.arrayBuffer());
      if (bytes.length === 0) return json({ error: "empty" }, 400);
      if (bytes.length > MAX_BYTES) return json({ error: "too_large" }, 413);

      const previous = await listUserFiles(uid);
      const path = `${FOLDER}/${uid}/${Date.now()}.${ext}`;
      const { error } = await supabase.storage
        .from(BUCKET)
        .upload(path, bytes, { contentType, upsert: false });
      if (error) throw error;

      // Keep only the newest photo for this user.
      if (previous.length > 0) {
        await supabase.storage.from(BUCKET).remove(previous);
      }

      const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);
      return json({ url: data.publicUrl });
    }

    if (req.method === "DELETE") {
      const files = await listUserFiles(uid);
      if (files.length > 0) {
        const { error } = await supabase.storage.from(BUCKET).remove(files);
        if (error) throw error;
      }
      return json({ deleted: files.length });
    }

    return json({ error: "method_not_allowed" }, 405);
  } catch (e) {
    console.error("profile-photo error", e);
    return json({ error: "server_error" }, 500);
  }
});
