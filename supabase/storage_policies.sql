-- Barakah Time: Storage RLS for profile pictures, using Firebase Auth as a
-- Supabase third-party auth provider.
--
-- Objects live in bucket `images` at `profile_pics/<firebase uid>/<file>`, so
-- storage.foldername(name) = {'profile_pics', '<uid>'} and index [2] is the
-- uid. The Firebase uid is the `sub` claim of the Firebase ID token.
--
-- Run in Supabase -> SQL editor. Safe to re-run.

-- The bucket must exist and be public (public URLs are stored in Firestore).
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do update set public = true;

drop policy if exists "barakah images public read" on storage.objects;
drop policy if exists "barakah profile pics insert own" on storage.objects;
drop policy if exists "barakah profile pics update own" on storage.objects;
drop policy if exists "barakah profile pics delete own" on storage.objects;

-- Anyone can read (public bucket; also needed for list() by the owner).
create policy "barakah images public read"
on storage.objects for select
to public
using (bucket_id = 'images');

create policy "barakah profile pics insert own"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'profile_pics'
  and (storage.foldername(name))[2] = (auth.jwt() ->> 'sub')
);

create policy "barakah profile pics update own"
on storage.objects for update
to authenticated
using (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'profile_pics'
  and (storage.foldername(name))[2] = (auth.jwt() ->> 'sub')
)
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'profile_pics'
  and (storage.foldername(name))[2] = (auth.jwt() ->> 'sub')
);

create policy "barakah profile pics delete own"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'profile_pics'
  and (storage.foldername(name))[2] = (auth.jwt() ->> 'sub')
);

-- Remove any older, broader policies on this bucket (e.g. "allow anon
-- uploads") from the dashboard: Storage -> Policies.
