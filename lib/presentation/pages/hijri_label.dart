import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';

/// Localized Hijri month name (1–12).
///
/// English and Arabic come from the `hijri` package; Farsi, Urdu and Turkish
/// use the `hijri_month_<n>` l10n keys. The package's global
/// [HijriCalendar.language] is restored afterwards so other screens are not
/// affected.
String hijriMonthName(int month, AppLocalizations l10n) {
  final code = l10n.locale.languageCode;
  if (code == 'fa' || code == 'ur' || code == 'tr') {
    return l10n.translate('hijri_month_$month');
  }
  final previous = HijriCalendar.language;
  try {
    HijriCalendar.language = code == 'ar' ? 'ar' : 'en';
    final h =
        HijriCalendar()
          ..hMonth = month
          ..hYear = 1446
          ..hDay = 1;
    return h.getLongMonthName();
  } finally {
    HijriCalendar.language = previous;
  }
}

/// "14 Jumada al-Ula 1448 AH" (localized) for [date].
String hijriDateLabel(
  DateTime date,
  AppLocalizations l10n, {
  bool withYear = true,
}) {
  final h = HijriCalendar.fromDate(date);
  final month = hijriMonthName(h.hMonth, l10n);
  if (!withYear) return '${h.hDay} $month';
  return '${h.hDay} $month ${h.hYear} ${l10n.hijri_year_suffix}';
}

/// Localized long Gregorian date, e.g. "Sunday, 15 November".
String gregorianDateLabel(DateTime date, String languageCode) {
  try {
    return DateFormat('EEEE, d MMMM', languageCode).format(date);
  } catch (_) {
    return DateFormat('EEEE, d MMMM', 'en').format(date);
  }
}
