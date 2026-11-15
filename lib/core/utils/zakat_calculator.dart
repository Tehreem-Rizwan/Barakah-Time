/// Pure zakat calculation logic (no Flutter dependencies) so it can be
/// unit tested.
enum NisabStandard { silver, gold }

class ZakatCalculator {
  ZakatCalculator._();

  /// Nisab weights in grams.
  static const double silverNisabGrams = 612.36;
  static const double goldNisabGrams = 87.48;
  static const double rate = 0.025;

  /// Parses user input such as "50,000", "Rs 1 200.50", "\$300" or "".
  ///
  /// Returns 0 for empty input, `null` if the input is not a valid
  /// non-negative number.
  static double? parseAmount(String? input) {
    if (input == null) return 0;
    var s = input.trim();
    if (s.isEmpty) return 0;
    // Convert Arabic-Indic / Eastern Arabic-Indic digits to Western.
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      final e = eastern.indexOf(ch);
      final p = persian.indexOf(ch);
      if (e >= 0) {
        buffer.write(e);
      } else if (p >= 0) {
        buffer.write(p);
      } else if (ch == '٫') {
        buffer.write('.');
      } else if (ch == '٬') {
        buffer.write(',');
      } else {
        buffer.write(ch);
      }
    }
    s = buffer.toString();
    if (s.contains('-')) return null; // negatives are not allowed
    // Strip currency symbols/letters, spaces and thousands separators.
    s = s.replaceAll(RegExp(r'[^0-9.]'), '');
    if (s.isEmpty) return null;
    if ('.'.allMatches(s).length > 1) return null;
    final value = double.tryParse(s);
    if (value == null || value.isNaN || value.isInfinite || value < 0) {
      return null;
    }
    return value;
  }

  static double nisabThreshold({
    required NisabStandard standard,
    required double pricePerGram,
  }) {
    final grams =
        standard == NisabStandard.silver ? silverNisabGrams : goldNisabGrams;
    return grams * pricePerGram;
  }

  static ZakatResult calculate({
    required double cash,
    required double gold,
    required double silver,
    required double investments,
    required double liabilities,
    required NisabStandard standard,
    required double pricePerGram,
  }) {
    final totalAssets = cash + gold + silver + investments;
    final netWealth = totalAssets - liabilities;
    final nisab = nisabThreshold(
      standard: standard,
      pricePerGram: pricePerGram,
    );
    final nisabKnown = pricePerGram > 0;
    final meetsNisab = netWealth > 0 && (!nisabKnown || netWealth >= nisab);
    final zakat = meetsNisab ? netWealth * rate : 0.0;
    return ZakatResult(
      totalAssets: totalAssets,
      netWealth: netWealth,
      nisab: nisab,
      nisabKnown: nisabKnown,
      meetsNisab: meetsNisab,
      zakatDue: zakat,
    );
  }
}

class ZakatResult {
  final double totalAssets;
  final double netWealth;
  final double nisab;

  /// False when no metal price was entered, so nisab could not be checked.
  final bool nisabKnown;
  final bool meetsNisab;
  final double zakatDue;

  const ZakatResult({
    required this.totalAssets,
    required this.netWealth,
    required this.nisab,
    required this.nisabKnown,
    required this.meetsNisab,
    required this.zakatDue,
  });
}
