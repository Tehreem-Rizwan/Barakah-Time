import 'package:adhan/adhan.dart';

void main() {
  try {
    final hijri = HijriDate.fromDate(DateTime.now());
    print('Hijri: ${hijri.day}/${hijri.month}/${hijri.year}');
  } catch (e) {
    print('Error: $e');
  }
}
