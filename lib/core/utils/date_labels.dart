import 'package:intl/intl.dart';

/// Short localized weekday labels for the last [count] calendar days ending
/// with [now]'s day (oldest first) – matches the pulse 7-day chart data.
List<String> lastDaysWeekdayLabels(
  String locale, {
  int count = 7,
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  DateFormat format;
  try {
    format = DateFormat('EEEEE', locale); // narrow weekday, e.g. "M"
  } catch (_) {
    format = DateFormat('EEEEE', 'en');
  }
  return List.generate(count, (i) {
    final day = DateTime(n.year, n.month, n.day - (count - 1 - i));
    try {
      return format.format(day);
    } catch (_) {
      return DateFormat('EEEEE', 'en').format(day);
    }
  });
}
