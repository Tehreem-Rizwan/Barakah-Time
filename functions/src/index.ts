/**
 * Supabase "third-party auth" with Firebase requires every Firebase ID token
 * to carry the custom claim `role: "authenticated"`; otherwise Supabase treats
 * the request as anonymous and the Storage RLS policies reject uploads.
 *
 * Blocking functions add the claim when an account is created and on every
 * sign-in (which also covers accounts created before this was deployed).
 *
 * Requires Firebase Authentication with Identity Platform (blocking
 * functions are an Identity Platform feature).
 */
import {
  beforeUserCreated,
  beforeUserSignedIn,
} from "firebase-functions/v2/identity";

const SUPABASE_CLAIMS = { role: "authenticated" };

export const addSupabaseRoleOnCreate = beforeUserCreated(() => ({
  customClaims: SUPABASE_CLAIMS,
}));

export const addSupabaseRoleOnSignIn = beforeUserSignedIn((event) => {
  const existing = event.data?.customClaims ?? {};
  return {
    customClaims: { ...existing, ...SUPABASE_CLAIMS },
  };
});
