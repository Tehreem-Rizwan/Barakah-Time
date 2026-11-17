import 'package:barakah_time/core/utils/zakat_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAmount', () {
    test('handles thousands separators, spaces and symbols', () {
      expect(ZakatCalculator.parseAmount('50,000'), 50000);
      expect(ZakatCalculator.parseAmount(' 1 200.50 '), 1200.5);
      expect(ZakatCalculator.parseAmount('Rs 3,000'), 3000);
      expect(ZakatCalculator.parseAmount('\$300'), 300);
      expect(ZakatCalculator.parseAmount('٥٠٠'), 500);
    });
    test('empty is zero', () {
      expect(ZakatCalculator.parseAmount(''), 0);
      expect(ZakatCalculator.parseAmount(null), 0);
    });
    test('decimal comma and dot thousands (Turkish/European style)', () {
      expect(ZakatCalculator.parseAmount('1500,75'), 1500.75);
      expect(ZakatCalculator.parseAmount('1.500,75'), 1500.75);
      expect(ZakatCalculator.parseAmount('1.000.000'), 1000000);
      expect(ZakatCalculator.parseAmount('1.500'), 1500);
      expect(ZakatCalculator.parseAmount('1,234,567.89'), 1234567.89);
      expect(ZakatCalculator.parseAmount('12.5'), 12.5);
    });

    test('invalid or negative is null', () {
      expect(ZakatCalculator.parseAmount('-100'), isNull);
      expect(ZakatCalculator.parseAmount('abc'), isNull);
      expect(ZakatCalculator.parseAmount('1.2.3'), isNull);
    });
  });

  group('calculate', () {
    test('2.5% of net wealth above nisab', () {
      final r = ZakatCalculator.calculate(
        cash: 100000,
        gold: 0,
        silver: 0,
        investments: 0,
        liabilities: 20000,
        standard: NisabStandard.silver,
        pricePerGram: 100, // nisab = 61236
      );
      expect(r.netWealth, 80000);
      expect(r.nisab, closeTo(61236, 0.001));
      expect(r.meetsNisab, isTrue);
      expect(r.zakatDue, closeTo(2000, 0.0001));
    });

    test('below nisab means no zakat', () {
      final r = ZakatCalculator.calculate(
        cash: 50000,
        gold: 0,
        silver: 0,
        investments: 0,
        liabilities: 0,
        standard: NisabStandard.gold,
        pricePerGram: 1000, // nisab = 87480
      );
      expect(r.meetsNisab, isFalse);
      expect(r.zakatDue, 0);
    });

    test('debts larger than assets means no zakat', () {
      final r = ZakatCalculator.calculate(
        cash: 1000,
        gold: 0,
        silver: 0,
        investments: 0,
        liabilities: 5000,
        standard: NisabStandard.silver,
        pricePerGram: 0,
      );
      expect(r.netWealth, -4000);
      expect(r.zakatDue, 0);
    });

    test('unknown nisab still computes zakat on positive wealth', () {
      final r = ZakatCalculator.calculate(
        cash: 1000,
        gold: 0,
        silver: 0,
        investments: 0,
        liabilities: 0,
        standard: NisabStandard.silver,
        pricePerGram: 0,
      );
      expect(r.nisabKnown, isFalse);
      expect(r.zakatDue, 25);
    });
  });
}
