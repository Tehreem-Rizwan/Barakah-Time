# Supabase setup (free plan)

Supabase is used only to store profile photos in the `images` bucket.
Everything here works on the **free plan**. No Firebase Blaze plan or Cloud
Functions are needed.

## How it works

1. The app signs users in with Firebase.
2. To change a photo, the app sends the image plus the user's Firebase ID
   token to the `profile-photo` Edge Function.
3. The function checks the token with Google's public keys, then saves the
   file to `images/profile_pics/<uid>/` using the service-role key. That key
   lives only on Supabase's servers, never in the app.
4. Older photos of that user are deleted, so each user keeps one photo.

Because the app itself can't write to the bucket, nobody can change another
user's photo.

## One-time setup (about 10 minutes)

### 1. Run the SQL

1. Open **Supabase Dashboard → SQL Editor → New query**.
2. Paste the contents of `storage_policies.sql` and click **Run**.
3. Open **Storage → Policies** and delete any remaining policy on the
   `images` bucket. Old "allow anon upload" policies would let anyone write.
4. Run the last `select` in the SQL file again. It should return no rows.

### 2. Create the Edge Function (in the browser, no CLI needed)

1. Open **Edge Functions → Deploy a new function → Via Editor**.
2. Name it exactly `profile-photo`.
3. Replace the sample code with the contents of
   `functions/profile-photo/index.ts` and click **Deploy**.
4. Open the function's **Details / Settings** and turn **OFF**
   "Enforce JWT verification" (also called "Verify JWT"), then save.
   This is required: the app sends a Firebase token, which Supabase's own
   check would reject. The function verifies the Firebase token itself.

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are provided to the function
automatically. You don't need to add secrets. If your Firebase project id
ever changes, add a secret `FIREBASE_PROJECT_ID` (default
`barakahtime-cbfa8`).

**CLI alternative**, if you prefer it:
`supabase functions deploy profile-photo --no-verify-jwt`. The setting is
also in `config.toml`.

### 3. Test it

Sign in to the app, open Profile, and change the photo. The new file appears
under **Storage → images → profile_pics → <your uid>**. If it fails, check
**Edge Functions → profile-photo → Logs**.

## Free plan limits (plenty for this app)

- Edge Functions: 500,000 calls per month.
- Storage: 1 GB.
- Free projects pause after about a week with no activity. Open the
  dashboard and click **Restore** if that happens. Photos are kept.
