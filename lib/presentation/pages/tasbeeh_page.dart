import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/repositories/tasbeeh_repository.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../injection_container.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/widgets.dart';

/// Pure counter math for a tasbeeh with a per-round [target].
class TasbeehProgress {
  final int count;
  final int target;

  const TasbeehProgress(this.count, int target)
    : target = target < 1 ? 1 : target;

  /// Count within the current round (1..target; 0 only before the first
  /// tap). Reaching the target shows a full round until the next tap.
  int get inRound => count <= 0 ? 0 : ((count - 1) % target) + 1;

  /// 1-based round number.
  int get round => count <= 0 ? 1 : ((count - 1) ~/ target) + 1;

  int get completedRounds => count <= 0 ? 0 : count ~/ target;

  /// 0.0 – 1.0 progress of the current round.
  double get fraction => inRound / target;

  /// True exactly when [count] completes a round.
  bool get isTargetReached => count > 0 && count % target == 0;
}

class Dhikr {
  final String l10nKey;
  final String arabic;
  final String transliteration;
  const Dhikr(this.l10nKey, this.arabic, this.transliteration);
}

const List<Dhikr> kDhikrs = [
  Dhikr('subhanallah', 'سُبْحَانَ ٱللَّٰهِ', 'SubhanAllah'),
  Dhikr('alhamdulillah', 'ٱلْحَمْدُ لِلَّٰهِ', 'Alhamdulillah'),
  Dhikr('allahu_akbar', 'ٱللَّٰهُ أَكْبَرُ', 'Allahu Akbar'),
  Dhikr('astaghfirullah', 'أَسْتَغْفِرُ ٱللَّٰهَ', 'Astaghfirullah'),
  Dhikr(
    'la_ilaha_illallah',
    'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
    'La ilaha illallah',
  ),
];

const List<int> kTasbeehPresetTargets = [33, 99, 100];

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  static const _targetKey = 'tasbeeh_target';
  static const _dhikrKey = 'tasbeeh_dhikr_index';

  final TasbeehRepository _repo = sl<TasbeehRepository>();
  SharedPreferences? get _prefs =>
      sl.isRegistered<SharedPreferences>() ? sl<SharedPreferences>() : null;
  PulseBloc? _pulseBloc;

  int _counter = 0;

  /// Part of [_counter] that has already been logged to Spiritual Pulse.
  int _loggedCount = 0;
  int _target = 33;
  int _dhikrIndex = 0;

  @override
  void initState() {
    super.initState();
    final saved = _repo.load();
    _counter = saved.count;
    _loggedCount = saved.loggedCount;
    final prefs = _prefs;
    final t = prefs?.getInt(_targetKey);
    if (t != null && t >= 1 && t <= 9999) _target = t;
    final d = prefs?.getInt(_dhikrKey);
    if (d != null && d >= 0 && d < kDhikrs.length) _dhikrIndex = d;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _pulseBloc = context.read<PulseBloc>();
    } catch (_) {
      _pulseBloc = null;
    }
  }

  @override
  void dispose() {
    // Leaving the page: save any dhikr not yet logged, then push to cloud.
    _logPending();
    _repo.flush();
    super.dispose();
  }

  static int _pointsFor(int count) => (count ~/ 33) * 5; // 5 points per 33

  void _increment() {
    setState(() => _counter++);
    _repo.save(_counter, _loggedCount);
    if (TasbeehProgress(_counter, _target).isTargetReached) {
      HapticFeedback.mediumImpact();
      showAppSnackBar(
        context,
        context.l10n.tasbeeh_target_reached,
        type: SnackType.success,
        duration: const Duration(seconds: 2),
      );
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Logs dhikr counted since the last log. Returns the number logged.
  int _logPending() {
    final pending = _counter - _loggedCount;
    if (pending <= 0) return 0;
    final points = _pointsFor(_counter) - _pointsFor(_loggedCount);
    // Under 33 new dhikr earns no points: keep it pending instead of adding
    // an empty "+0" entry (which would also extend the streak).
    if (points <= 0) return 0;
    _pulseBloc?.add(
      LogActivity(
        SpiritualActivity(
          id: 'dhikr_${DateTime.now().microsecondsSinceEpoch}',
          type: 'dhikr',
          subType: 'tasbeeh',
          timestamp: DateTime.now(),
          points: points,
        ),
      ),
    );
    _loggedCount = _counter;
    _repo.save(_counter, _loggedCount);
    return pending;
  }

  Future<void> _confirmReset() async {
    if (_counter == 0) return;
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.reset_counter_title,
      message: l10n.reset_counter_message,
      confirmLabel: l10n.reset,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final total = _logPending();
    setState(() {
      _counter = 0;
      _loggedCount = 0;
    });
    _repo.save(0, 0);
    if (total > 0) {
      showAppSnackBar(
        context,
        '$total ${l10n.tasbeeh_dhikr_logged}',
        type: SnackType.success,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _setTarget(int target) {
    setState(() => _target = target);
    _prefs?.setInt(_targetKey, target);
  }

  void _setDhikr(int index) {
    setState(() => _dhikrIndex = index);
    _prefs?.setInt(_dhikrKey, index);
  }

  Future<void> _pickCustomTarget() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _CustomTargetDialog(initial: _target),
    );
    if (result != null && mounted) _setTarget(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final dhikr = kDhikrs[_dhikrIndex];
    final progress = TasbeehProgress(_counter, _target);
    final isCustom = !kTasbeehPresetTargets.contains(_target);

    return AppScaffold(
      title: l10n.tasbeeh,
      actions: [
        IconButton(
          icon: const Icon(Icons.restart_alt_rounded),
          tooltip: l10n.reset,
          onPressed: _counter == 0 ? null : _confirmReset,
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final circle = math
              .min(constraints.maxWidth * 0.7, constraints.maxHeight * 0.45)
              .clamp(140.0, 300.0);
          return SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < kDhikrs.length; i++)
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: AppSpacing.sm,
                          ),
                          child: ChoiceChip(
                            label: Text(l10n.translate(kDhikrs[i].l10nKey)),
                            selected: i == _dhikrIndex,
                            onSelected: (_) => _setDhikr(i),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.vXl),
                ArabicText(
                  dhikr.arabic,
                  textAlign: TextAlign.center,
                  fontSize: 30.sp,
                  height: 1.6,
                  color: AppColors.secondaryGold,
                ),
                TranslationText(
                  dhikr.transliteration,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: AppSpacing.vXl),
                _CounterButton(
                  size: circle,
                  progress: progress,
                  onTap: _increment,
                ),
                SizedBox(height: AppSpacing.vLg),
                Text(
                  '${l10n.tasbeeh_round.replaceAll('{n}', '${progress.round}')}'
                  '  •  '
                  '${l10n.tasbeeh_total.replaceAll('{n}', '$_counter')}',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.vXl),
                SectionHeader(
                  title: l10n.tasbeeh_target,
                  icon: Icons.flag_outlined,
                ),
                SizedBox(height: AppSpacing.vSm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.vSm,
                  children: [
                    for (final t in kTasbeehPresetTargets)
                      ChoiceChip(
                        label: Text('$t'),
                        selected: _target == t,
                        onSelected: (_) => _setTarget(t),
                      ),
                    ChoiceChip(
                      label: Text(
                        isCustom
                            ? '${l10n.tasbeeh_custom} ($_target)'
                            : l10n.tasbeeh_custom,
                      ),
                      selected: isCustom,
                      onSelected: (_) => _pickCustomTarget(),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.vLg),
                Text(
                  l10n.tasbeeh_tap_hint,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.size,
    required this.progress,
    required this.onTap,
  });

  final double size;
  final TasbeehProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final stroke = math.max(6.0, size * 0.04);
    return Semantics(
      button: true,
      label: l10n.tasbeeh_counter_semantics.replaceAll(
        '{count}',
        '${progress.inRound} / ${progress.target}',
      ),
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress.fraction),
                duration: AppDurations.fast,
                builder:
                    (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: stroke,
                      backgroundColor: AppColors.brass.withValues(alpha: 0.3),
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(stroke * 2),
              child: Material(
                type: MaterialType.transparency,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardDark,
                    border: Border.all(color: AppColors.glassStroke),
                  ),
                  child: InkWell(
                    onTap: onTap,
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(size * 0.12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${progress.inRound}',
                                style: textTheme.displayMedium?.copyWith(
                                  color: AppColors.secondaryGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/ ${progress.target}',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTargetDialog extends StatefulWidget {
  const _CustomTargetDialog({required this.initial});

  final int initial;

  @override
  State<_CustomTargetDialog> createState() => _CustomTargetDialogState();
}

class _CustomTargetDialogState extends State<_CustomTargetDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.initial}',
  );
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 1 || value > 9999) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.tasbeeh_custom_target),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_invalid) setState(() => _invalid = false);
        },
        decoration: InputDecoration(
          labelText: l10n.tasbeeh_target,
          errorText: _invalid ? l10n.tasbeeh_target_invalid : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: dialogActionStyle(),
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
