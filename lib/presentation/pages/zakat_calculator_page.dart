import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/zakat_calculator.dart';
import '../../injection_container.dart';
import '../widgets/widgets.dart';

/// Shown in place of amounts until the user has calculated.
const String kZakatPlaceholder = '—';

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

enum _Field { cash, gold, silver, investments, liabilities, metalPrice }

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage> {
  static const _currencyKey = 'zakat_currency';

  final Map<_Field, TextEditingController> _controllers = {
    for (final f in _Field.values) f: TextEditingController(),
  };
  final TextEditingController _currencyController = TextEditingController();
  final GlobalKey _resultKey = GlobalKey();
  final Set<_Field> _invalid = {};
  NisabStandard _standard = NisabStandard.silver;
  ZakatResult? _result;

  SharedPreferences? get _prefs =>
      sl.isRegistered<SharedPreferences>() ? sl<SharedPreferences>() : null;

  @override
  void initState() {
    super.initState();
    _currencyController.text = _prefs?.getString(_currencyKey) ?? '';
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _currencyController.dispose();
    super.dispose();
  }

  NumberFormat _numberFormat(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    try {
      return NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: 2,
      );
    } catch (_) {
      return NumberFormat.decimalPatternDigits(decimalDigits: 2);
    }
  }

  String get _currency => _currencyController.text.trim().toUpperCase();

  String _money(NumberFormat fmt, double value) {
    final c = _currency;
    return c.isEmpty ? fmt.format(value) : '$c ${fmt.format(value)}';
  }

  void _onCurrencyChanged(String value) {
    _prefs?.setString(_currencyKey, value.trim().toUpperCase());
    setState(() {});
  }

  void _calculateZakat() {
    FocusScope.of(context).unfocus();
    final values = <_Field, double>{};
    final invalid = <_Field>{};
    for (final f in _Field.values) {
      final v = ZakatCalculator.parseAmount(_controllers[f]!.text);
      if (v == null) {
        invalid.add(f);
      } else {
        values[f] = v;
      }
    }
    setState(() {
      _invalid
        ..clear()
        ..addAll(invalid);
      if (invalid.isNotEmpty) {
        _result = null;
        return;
      }
      _result = ZakatCalculator.calculate(
        cash: values[_Field.cash]!,
        gold: values[_Field.gold]!,
        silver: values[_Field.silver]!,
        investments: values[_Field.investments]!,
        liabilities: values[_Field.liabilities]!,
        standard: _standard,
        pricePerGram: values[_Field.metalPrice]!,
      );
    });
    if (invalid.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _resultKey.currentContext;
        if (ctx != null && ctx.mounted) {
          Scrollable.ensureVisible(
            ctx,
            duration: AppDurations.medium,
            curve: AppDurations.curve,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final fmt = _numberFormat(context);
    final result = _result;
    String? statusText;
    var statusOk = false;
    if (result != null) {
      if (result.netWealth <= 0) {
        statusText = l10n.zakat_no_wealth;
      } else if (!result.meetsNisab) {
        statusText = l10n.zakat_below_nisab.replaceAll(
          '{nisab}',
          _money(fmt, result.nisab),
        );
      } else if (!result.nisabKnown) {
        statusText = l10n.zakat_nisab_unknown;
      } else {
        statusOk = true;
        statusText = l10n.zakat_above_nisab.replaceAll(
          '{nisab}',
          _money(fmt, result.nisab),
        );
      }
    }

    return AppScaffold(
      title: l10n.zakat_calculator,
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              key: _resultKey,
              blur: true,
              padding: AppSpacing.all(24),
              child: Semantics(
                liveRegion: true,
                child: Column(
                  children: [
                    Text(
                      l10n.total_zakat_payable,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.vSm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        result == null
                            ? kZakatPlaceholder
                            : _money(fmt, result.zakatDue),
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 32.sp,
                          color: AppColors.secondaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (result != null) ...[
                      SizedBox(height: AppSpacing.vSm),
                      Text(
                        '${l10n.zakat_net_wealth}: ${_money(fmt, result.netWealth)}',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.vXs),
                      Text(
                        statusText!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color:
                              statusOk ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.vXl),
            _buildInputField(l10n.cash_in_hand, _Field.cash),
            _buildInputField(l10n.gold_value, _Field.gold),
            _buildInputField(l10n.silver_value, _Field.silver),
            _buildInputField(l10n.investments_shares, _Field.investments),
            _buildInputField(l10n.zakat_liabilities, _Field.liabilities),
            Text(l10n.zakat_nisab_standard, style: textTheme.titleSmall),
            SizedBox(height: AppSpacing.vSm),
            SegmentedButton<NisabStandard>(
              segments: [
                ButtonSegment(
                  value: NisabStandard.silver,
                  label: Text(l10n.zakat_silver_nisab),
                ),
                ButtonSegment(
                  value: NisabStandard.gold,
                  label: Text(l10n.zakat_gold_nisab),
                ),
              ],
              selected: {_standard},
              onSelectionChanged: (s) {
                setState(() => _standard = s.first);
                if (_result != null) _calculateZakat();
              },
            ),
            SizedBox(height: AppSpacing.vLg),
            _buildInputField(
              _standard == NisabStandard.silver
                  ? l10n.zakat_silver_price
                  : l10n.zakat_gold_price,
              _Field.metalPrice,
            ),
            TextField(
              controller: _currencyController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              maxLength: 5,
              onChanged: _onCurrencyChanged,
              onSubmitted: (_) => _calculateZakat(),
              decoration: InputDecoration(
                labelText: l10n.zakat_currency,
                hintText: l10n.zakat_currency_hint,
                counterText: '',
              ),
            ),
            SizedBox(height: AppSpacing.vXl),
            PrimaryButton(
              label: l10n.calculate_zakat,
              icon: Icons.calculate_outlined,
              onPressed: _calculateZakat,
            ),
            SizedBox(height: AppSpacing.vXl),
            AppCard(
              child: Text(
                l10n.zakat_note,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, _Field field) {
    final l10n = context.l10n;
    final invalid = _invalid.contains(field);
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vLg),
      child: TextField(
        controller: _controllers[field],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        onChanged: (_) {
          if (invalid) setState(() => _invalid.remove(field));
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: l10n.enter_amount,
          errorText: invalid ? l10n.zakat_invalid_amount : null,
        ),
      ),
    );
  }
}
