import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/repositories/qaza_repository.dart';
import '../../domain/entities/qaza_state.dart';
import '../../injection_container.dart';
import '../widgets/widgets.dart';

/// Tracks missed (qaza) prayers: estimate how many are owed, then count
/// them down one by one. Saved locally and synced to the user's account.
class QazaTrackerPage extends StatefulWidget {
  const QazaTrackerPage({super.key, this.repository});

  /// Injected in tests; defaults to the registered [QazaRepository].
  final QazaRepository? repository;

  @override
  State<QazaTrackerPage> createState() => _QazaTrackerPageState();
}

class _QazaTrackerPageState extends State<QazaTrackerPage> {
  late final QazaRepository _repo = widget.repository ?? sl<QazaRepository>();
  late QazaState _state = _repo.load();

  /// Show the per-prayer list even when every count is zero (after the user
  /// chose to enter counts manually).
  bool _manual = false;

  @override
  void dispose() {
    _repo.flush();
    super.dispose();
  }

  void _update(QazaState next) {
    setState(() => _state = next);
    _repo.save(next);
  }

  String _num(BuildContext context, int n) => NumberFormat.decimalPattern(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(n);

  void _madeUp(String prayer) {
    final l10n = context.l10n;
    if (_state.remainingOf(prayer) <= 0) return;
    HapticFeedback.lightImpact();
    _update(_state.madeUp(prayer));
    final name = l10n.translate(prayer);
    showAppSnackBar(
      context,
      _state.totalRemaining == 0
          ? l10n.translate('qaza_all_done')
          : l10n.translate('qaza_logged').replaceAll('{prayer}', name),
      type: SnackType.success,
      actionLabel: l10n.profile_undo,
      onAction: () {
        if (mounted) _update(_state.undoMadeUp(prayer));
      },
    );
  }

  Future<void> _edit(String prayer) async {
    final l10n = context.l10n;
    final count = await showDialog<int>(
      context: context,
      builder:
          (_) => _EditCountDialog(
            title: l10n
                .translate('qaza_edit_title')
                .replaceAll('{prayer}', l10n.translate(prayer)),
            initial: _state.remainingOf(prayer),
          ),
    );
    if (count != null && mounted) _update(_state.withRemaining(prayer, count));
  }

  Future<void> _estimate() async {
    final result = await showModalBottomSheet<({int days, bool witr})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _EstimateSheet(),
    );
    if (result == null || !mounted) return;
    _update(_state.addDays(result.days, includeWitr: result.witr));
  }

  Future<void> _reset() async {
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l10n.translate('qaza_reset'),
      message: l10n.translate('qaza_reset_confirm'),
      confirmLabel: l10n.reset,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _manual = false);
    _update(QazaState.empty);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showIntro = _state.isEmpty && !_manual;
    return AppScaffold(
      title: l10n.translate('qaza_tracker'),
      actions: [
        if (!showIntro)
          IconButton(
            tooltip: l10n.translate('qaza_reset'),
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _reset,
          ),
      ],
      body: ListView(
        padding: AppSpacing.page,
        children:
            showIntro
                ? [_intro(context)]
                : [
                  _summary(context),
                  SizedBox(height: AppSpacing.vLg),
                  for (final p in QazaState.prayers) ...[
                    _prayerRow(context, p),
                    SizedBox(height: AppSpacing.vSm),
                  ],
                  SizedBox(height: AppSpacing.vMd),
                  SecondaryButton(
                    label: l10n.translate('qaza_calculate'),
                    icon: Icons.calculate_outlined,
                    onPressed: _estimate,
                  ),
                ],
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        children: [
          SizedBox(height: AppSpacing.vSm),
          Icon(
            Icons.history_rounded,
            size: 48.sp,
            color: AppColors.secondaryGold,
          ),
          SizedBox(height: AppSpacing.vMd),
          Text(
            l10n.translate('qaza_intro_title'),
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vSm),
          Text(
            l10n.translate('qaza_intro_body'),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vXl),
          PrimaryButton(
            label: l10n.translate('qaza_calculate'),
            icon: Icons.calculate_outlined,
            onPressed: _estimate,
          ),
          SizedBox(height: AppSpacing.vSm),
          SecondaryButton(
            label: l10n.translate('qaza_enter_manually'),
            icon: Icons.edit_outlined,
            onPressed: () => setState(() => _manual = true),
          ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final percent = (_state.progress * 100).floor();
    final finished = _state.totalRemaining == 0 && _state.totalDone > 0;
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _num(context, _state.totalRemaining),
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.secondaryGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.translate('qaza_remaining'),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _num(context, _state.totalDone),
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    l10n.translate('qaza_made_up'),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: LinearProgressIndicator(
              value: _state.progress,
              minHeight: 8.h,
              backgroundColor: AppColors.glassFill,
              color: AppColors.secondaryGold,
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          Text(
            finished
                ? l10n.translate('qaza_all_done')
                : l10n
                    .translate('qaza_progress')
                    .replaceAll('{p}', _num(context, percent)),
            style: textTheme.bodySmall?.copyWith(
              color: finished ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _prayerRow(BuildContext context, String prayer) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final remaining = _state.remainingOf(prayer);
    final name = l10n.translate(prayer);
    return AppCard(
      padding: AppSpacing.tile,
      onLongPress: () => _edit(prayer),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.titleMedium),
                Text(
                  '${l10n.translate('qaza_made_up')}: '
                  '${_num(context, _state.doneOf(prayer))}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: '$name, ${l10n.translate('qaza_remaining')}',
            child: Text(
              _num(context, remaining),
              style: textTheme.titleLarge?.copyWith(
                color: remaining == 0 ? AppColors.success : AppColors.textMain,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n
                .translate('qaza_edit_title')
                .replaceAll('{prayer}', name),
            icon: Icon(Icons.edit_outlined, size: 20.sp),
            color: AppColors.textSecondary,
            onPressed: () => _edit(prayer),
          ),
          IconButton.filled(
            tooltip: '${l10n.translate('qaza_pray_one')}: $name',
            icon: const Icon(Icons.check_rounded),
            onPressed: remaining > 0 ? () => _madeUp(prayer) : null,
          ),
        ],
      ),
    );
  }
}

class _EditCountDialog extends StatefulWidget {
  const _EditCountDialog({required this.title, required this.initial});

  final String title;
  final int initial;

  @override
  State<_EditCountDialog> createState() => _EditCountDialogState();
}

class _EditCountDialogState extends State<_EditCountDialog> {
  late final _controller = TextEditingController(text: '${widget.initial}');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_controller.text.trim());
    if (n == null || n < 0 || n > QazaState.maxPerPrayer) {
      setState(() => _error = context.l10n.translate('qaza_invalid'));
      return;
    }
    Navigator.of(context).pop(n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.translate('qaza_remaining'),
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}

class _EstimateSheet extends StatefulWidget {
  const _EstimateSheet();

  @override
  State<_EstimateSheet> createState() => _EstimateSheetState();
}

class _EstimateSheetState extends State<_EstimateSheet> {
  final _years = TextEditingController();
  final _months = TextEditingController();
  final _days = TextEditingController();
  bool _witr = true;

  @override
  void dispose() {
    _years.dispose();
    _months.dispose();
    _days.dispose();
    super.dispose();
  }

  int _read(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  int get _total => QazaState.daysFor(
    years: _read(_years).clamp(0, 150),
    months: _read(_months).clamp(0, 1800),
    days: _read(_days).clamp(0, 60000),
  ).clamp(0, QazaState.maxPerPrayer);

  Widget _field(TextEditingController c, String label) => Expanded(
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final total = _total;
    final fmt = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.translate('qaza_calculate'), style: textTheme.titleLarge),
            SizedBox(height: AppSpacing.vSm),
            Text(
              l10n.translate('qaza_calc_desc'),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.vLg),
            Row(
              children: [
                _field(_years, l10n.translate('qaza_years')),
                SizedBox(width: AppSpacing.md),
                _field(_months, l10n.translate('qaza_months')),
                SizedBox(width: AppSpacing.md),
                _field(_days, l10n.translate('qaza_days')),
              ],
            ),
            SizedBox(height: AppSpacing.vSm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.translate('qaza_include_witr')),
              value: _witr,
              onChanged: (v) => setState(() => _witr = v),
            ),
            Text(
              l10n
                  .translate('qaza_calc_result')
                  .replaceAll('{n}', fmt.format(total)),
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.secondaryGold,
              ),
            ),
            SizedBox(height: AppSpacing.vXs),
            Text(
              l10n.translate('qaza_estimate_note'),
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.vLg),
            PrimaryButton(
              label: l10n.translate('qaza_add'),
              icon: Icons.add_rounded,
              onPressed:
                  total > 0
                      ? () =>
                          Navigator.of(context).pop((days: total, witr: _witr))
                      : null,
            ),
            SizedBox(height: AppSpacing.vLg),
          ],
        ),
      ),
    );
  }
}
