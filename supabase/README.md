# Supabase setup (profile pictures)

Profile pictures are stored in Supabase Storage (bucket `images`,
path `profile_pics/<firebase uid>/<timestamp>.<ext>`). The app signs users in
with **Firebase Auth** and passes the Firebase ID token to Supabase
(`Supabase.initialize(accessToken: ...)` in `lib/main.dart`), so Supabase must
trust Firebase as a third-party auth provider.

## One-time steps

1. **Supabase dashboard → Authentication → Sign In / Providers → Third-party
   auth → Add provider → Firebase**, project ID `barakahtime-cbfa8`.
2. **SQL editor**: run [`storage_policies.sql`](storage_policies.sql). It makes
   the bucket public-read and only lets a user write/delete inside
   `profile_pics/<their uid>/`. Delete any older permissive policies on
   `storage.objects` (Storage → Policies).
3. **Firebase custom claim**: Supabase requires `role: "authenticated"` in the
   Firebase ID token. Deploy the blocking functions in `/functions`:
   ```sh
   # Firebase console: Authentication → Settings → upgrade to
   # "Firebase Authentication with Identity Platform" (required for blocking functions)
   cd functions && npm install && cd ..
   firebase deploy --only functions
   ```
   Then in Firebase console → Authentication → Settings → Blocking functions,
   make sure `addSupabaseRoleOnCreate` (before account creation) and
   `addSupabaseRoleOnSignIn` (before sign in) are selected.
4. **Existing users** get the claim on their next sign-in
   (`beforeUserSignedIn`). Users already signed in on a device will receive it
   when their ID token refreshes after a new sign-in; until then uploads fail
   with a policy error (the app shows "upload failed"). Signing out and in
   again fixes it immediately.

## Firestore rules

Deploy the Firestore rules from the repo root as well:

```sh
firebase deploy --only firestore:rules
```
