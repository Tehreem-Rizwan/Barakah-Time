/// App-wide configuration in one place.
class AppConfig {
  AppConfig._();

  /// Supabase project used only for profile-photo storage (free plan).
  /// The anon key is public by design; writes go through the
  /// `profile-photo` Edge Function, which verifies the Firebase sign-in.
  static const String supabaseUrl = 'https://cvidkztrusooboqorzkj.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2aWRrenRydXNvb2JvcW9yemtqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTg1MzMsImV4cCI6MjA5MTAzNDUzM30.0R1EFZ7QNlCgNjLlG-4UtrKLQD9gQIZELZifcZX_lto';

  /// Edge Function that uploads/deletes profile photos (see
  /// supabase/functions/profile-photo/index.ts).
  static const String profilePhotoFunctionUrl =
      '$supabaseUrl/functions/v1/profile-photo';

  /// Sign in with Apple needs a paid Apple Developer account
  /// ($99/year). Keep this false until that account exists and the
  /// capability is enabled; then set it to true.
  static const bool appleSignInEnabled = false;

  /// Google Play listing, used in share/invite messages.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.tehreem.barakah_time';
}
