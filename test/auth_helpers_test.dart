import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/firebase_service.dart';
import 'package:barakah_time/core/services/supabase_service.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizations(const Locale('en'));

  group('validators', () {
    test('name', () {
      expect(validateName(l10n, '   '), l10n.name_required);
      expect(validateName(l10n, ' Ali '), isNull);
    });

    test('email', () {
      expect(validateEmail(l10n, ''), l10n.email_required);
      expect(validateEmail(l10n, 'foo'), l10n.invalid_email);
      expect(validateEmail(l10n, 'foo@bar'), l10n.invalid_email);
      expect(validateEmail(l10n, ' a@b.com '), isNull);
    });

    test('password', () {
      expect(validatePassword(l10n, ''), l10n.password_required);
      expect(validatePassword(l10n, '12345'), l10n.password_too_short);
      expect(validatePassword(l10n, '123456'), isNull);
    });
  });

  group('auth messages', () {
    test('known codes map to localized text', () {
      expect(localizedAuthMessage(l10n, 'invalid-credential', 'x'),
          l10n.err_wrong_credentials);
      expect(localizedAuthMessage(l10n, 'wrong-password', 'x'),
          l10n.err_wrong_credentials);
      expect(localizedAuthMessage(l10n, 'network-request-failed', 'x'),
          l10n.err_network);
      expect(localizedAuthMessage(l10n, 'requires-recent-login', 'x'),
          l10n.err_recent_login);
    });

    test('unknown codes fall back to the message', () {
      expect(localizedAuthMessage(l10n, 'something-else', 'Fallback'),
          'Fallback');
    });

    test('cleanErrorMessage strips Exception prefixes', () {
      expect(cleanErrorMessage(Exception('Boom')), 'Boom');
      expect(cleanErrorMessage(const AuthFailure('x', 'Friendly')),
          'Friendly');
    });
  });

  test('formatCompactNumber', () {
    expect(formatCompactNumber(0), '0');
    expect(formatCompactNumber(150), '150');
    expect(formatCompactNumber(999), '999');
    expect(formatCompactNumber(1000), '1k');
    expect(formatCompactNumber(1500), '1.5k');
    expect(formatCompactNumber(2000000), '2M');
  });

  test('storagePathFromPublicUrl', () {
    expect(
      SupabaseService.storagePathFromPublicUrl(
        'https://x.supabase.co/storage/v1/object/public/images/profile_pics/u1/1.jpg',
      ),
      'profile_pics/u1/1.jpg',
    );
    expect(
      SupabaseService.storagePathFromPublicUrl(
        'https://lh3.googleusercontent.com/a/photo',
      ),
      isNull,
    );
    expect(SupabaseService.storagePathFromPublicUrl(null), isNull);
  });
}
