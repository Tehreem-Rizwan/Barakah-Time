-- Barakah Time: storage setup for profile pictures (Supabase FREE plan).
--
-- Photos live in bucket `images` at `profile_pics/<firebase uid>/<file>`.
-- The app never writes to storage directly: uploads and deletes go through
-- the `profile-photo` Edge Function, which verifies the user's Firebase
-- sign-in and uses the server-only service-role key (that key bypasses these
-- policies). So the anon key in the app must NOT be allowed to write.
--
-- Run in Supabase -> SQL Editor. Safe to re-run.

-- 1. Public bucket so profile photo URLs can be shown in the app.
--    (Public buckets serve files by URL without any SELECT policy.)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'images', 'images', true, 5242880,
  array['image/jpeg','image/png','image/webp','image/gif','image/heic','image/heif']
)
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- 2. Remove every policy that lets the app (anon/authenticated) write to or
--    list this bucket. Policies created by earlier versions of this file:
drop policy if exists "barakah images public read" on storage.objects;
drop policy if exists "barakah profile pics insert own" on storage.objects;
drop policy if exists "barakah profile pics update own" on storage.objects;
drop policy if exists "barakah profile pics delete own" on storage.objects;

-- 3. IMPORTANT: also open Storage -> Policies in the dashboard and delete any
--    other policy on the `images` bucket (for example one named like
--    "Allow anon uploads" or "Give anon users access"). With no INSERT /
--    UPDATE / DELETE policies, only the Edge Function can change files.

-- Check: this should return 0 rows when you're done.
select policyname, cmd, roles
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and (qual ilike '%images%' or with_check ilike '%images%');
