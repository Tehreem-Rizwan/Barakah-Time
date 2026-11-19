import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_config.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/memorial_reminder_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/memorial_repository.dart';
import '../../domain/entities/memorial.dart';
import '../../domain/entities/user.dart';
import '../../injection_container.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';
import 'auth/sign_in_page.dart';
import 'hijri_label.dart';

MemorialActor _actor(UserEntity u, AppLocalizations l10n) => (
  uid: u.id,
  name: u.displayNameOr(l10n.translate('default_user_name')),
);

String _errorText(Object e, AppLocalizations l10n) {
  if (e is MemorialException) {
    switch (e.code) {
      case 'not_found':
        return l10n.translate('memorial_error_not_found');
      case 'para_taken':
        return l10n.translate('memorial_error_para_taken');
    }
  }
  return l10n.translate('memorial_error_generic');
}

String _num(BuildContext context, int n) => NumberFormat.decimalPattern(
  Localizations.localeOf(context).toLanguageTag(),
).format(n);

String _date(BuildContext context, DateTime d) {
  final code = Localizations.localeOf(context).languageCode;
  try {
    return DateFormat.yMMMd(code).format(d);
  } catch (_) {
    return DateFormat.yMMMd().format(d);
  }
}

// ---------------------------------------------------------------------------
// List
// ---------------------------------------------------------------------------

/// Esaal-e-Sawab: the user's shared memorial pages.
class MemorialsPage extends StatelessWidget {
  const MemorialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return AppScaffold(
            title: l10n.translate('memorial_title'),
            body: StateView.empty(
              icon: Icons.volunteer_activism_outlined,
              message: l10n.translate('memorial_sign_in'),
              actionLabel: l10n.auth_sign_in,
              onAction:
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const SignInPage()),
                  ),
            ),
          );
        }
        return _MemorialList(user: state.user);
      },
    );
  }
}

class _MemorialList extends StatelessWidget {
  const _MemorialList({required this.user});

  final UserEntity user;

  Future<void> _join(BuildContext context) async {
    final l10n = context.l10n;
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _JoinDialog(),
    );
    if (code == null || !context.mounted) return;
    try {
      final id = await sl<MemorialRepository>().join(_actor(user, l10n), code);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => MemorialDetailPage(id: id)),
      );
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, _errorText(e, l10n), type: SnackType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      title: l10n.translate('memorial_title'),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          AppCard(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  size: 40.sp,
                  color: AppColors.secondaryGold,
                ),
                SizedBox(height: AppSpacing.vSm),
                Text(
                  l10n.translate('memorial_intro'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: AppSpacing.vLg),
                PrimaryButton(
                  label: l10n.translate('memorial_create'),
                  icon: Icons.add_rounded,
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CreateMemorialPage(user: user),
                        ),
                      ),
                ),
                SizedBox(height: AppSpacing.vSm),
                SecondaryButton(
                  label: l10n.translate('memorial_join'),
                  icon: Icons.group_add_outlined,
                  onPressed: () => _join(context),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.vXl),
          StreamBuilder<List<MemorialLink>>(
            stream: sl<MemorialRepository>().watchMine(user.id),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(
                  l10n.translate('memorial_error_generic'),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                );
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data!;
              if (items.isEmpty) {
                return Text(
                  l10n.translate('memorial_none'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              }
              return Column(
                children: [
                  for (final m in items)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: AppSpacing.vSm,
                      ),
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: ActionTile(
                          icon: Icons.local_florist_outlined,
                          title: m.name,
                          subtitle:
                              m.owner
                                  ? l10n.translate('memorial_you_created')
                                  : l10n.translate('memorial_joined'),
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => MemorialDetailPage(id: m.id),
                                ),
                              ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _JoinDialog extends StatefulWidget {
  const _JoinDialog();

  @override
  State<_JoinDialog> createState() => _JoinDialogState();
}

class _JoinDialogState extends State<_JoinDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = MemorialRepository.normalizeCode(_controller.text);
    if (code == null) {
      setState(() => _error = context.l10n.translate('memorial_code_invalid'));
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.translate('memorial_join')),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [LengthLimitingTextInputFormatter(12)],
        decoration: InputDecoration(
          labelText: l10n.translate('memorial_code'),
          hintText: 'ABCD2345',
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.translate('memorial_join_button')),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Create
// ---------------------------------------------------------------------------

class CreateMemorialPage extends StatefulWidget {
  const CreateMemorialPage({super.key, required this.user});

  final UserEntity user;

  @override
  State<CreateMemorialPage> createState() => _CreateMemorialPageState();
}

class _CreateMemorialPageState extends State<CreateMemorialPage> {
  final _name = TextEditingController();
  final _subtitle = TextEditingController();
  final Map<String, TextEditingController> _goals = {
    for (final d in DhikrPreset.all)
      d.id: TextEditingController(text: '${d.defaultGoal}'),
  };
  final Set<String> _selected = {'kareema', 'darood', 'ikhlas'};
  DateTime? _death;
  bool _showDates = true;
  bool _saving = false;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _subtitle.dispose();
    for (final c in _goals.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _death ?? now,
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (d != null) setState(() => _death = d);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.translate('memorial_name_required'));
      return;
    }
    final goals = <String, int>{
      for (final id in _selected)
        id: (int.tryParse(_goals[id]!.text.trim()) ?? 0).clamp(1, 100000000),
    };
    setState(() => _saving = true);
    try {
      final id = await sl<MemorialRepository>().create(
        _actor(widget.user, l10n),
        name: name,
        subtitle: _subtitle.text,
        deathDate: _death,
        showDates: _showDates,
        goals: goals,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MemorialDetailPage(id: id, justCreated: true),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, _errorText(e, l10n), type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      title: l10n.translate('memorial_create'),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          TextField(
            controller: _name,
            maxLength: 100,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.translate('memorial_name'),
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          TextField(
            controller: _subtitle,
            maxLength: 150,
            decoration: InputDecoration(
              labelText: l10n.translate('memorial_subtitle'),
              hintText: l10n.translate('memorial_subtitle_hint'),
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ActionTile(
                  icon: Icons.event_outlined,
                  title: l10n.translate('memorial_death_date'),
                  subtitle:
                      _death == null
                          ? l10n.translate('memorial_optional')
                          : _date(context, _death!),
                  trailing:
                      _death == null
                          ? null
                          : IconButton(
                            tooltip: l10n.cancel,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() => _death = null),
                          ),
                  onTap: _pickDate,
                ),
                if (_death != null)
                  SwitchListTile(
                    title: Text(l10n.translate('memorial_show_dates')),
                    subtitle: Text(
                      l10n.translate('memorial_show_dates_desc'),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _showDates,
                    onChanged: (v) => setState(() => _showDates = v),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.vXl),
          SectionHeader(
            title: l10n.translate('memorial_goals'),
            icon: Icons.blur_circular_rounded,
          ),
          SizedBox(height: AppSpacing.vSm),
          for (final d in DhikrPreset.all)
            AppCard(
              padding: AppSpacing.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Checkbox(
                    value: _selected.contains(d.id),
                    onChanged:
                        (v) => setState(
                          () =>
                              v == true
                                  ? _selected.add(d.id)
                                  : _selected.remove(d.id),
                        ),
                  ),
                  Expanded(child: Text(l10n.translate(d.nameKey))),
                  SizedBox(
                    width: 96.w,
                    child: TextField(
                      controller: _goals[d.id],
                      enabled: _selected.contains(d.id),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: l10n.translate('memorial_goal'),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
              ),
            ),
          SizedBox(height: AppSpacing.vXl),
          PrimaryButton(
            label: l10n.translate('memorial_create'),
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
          SizedBox(height: AppSpacing.vLg),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail
// ---------------------------------------------------------------------------

class MemorialDetailPage extends StatelessWidget {
  const MemorialDetailPage({
    super.key,
    required this.id,
    this.justCreated = false,
  });

  final String id;
  final bool justCreated;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthBloc>().state;
    if (auth is! Authenticated) return const MemorialsPage();
    final me = _actor(auth.user, l10n);
    return StreamBuilder<Memorial?>(
      stream: sl<MemorialRepository>().watch(id),
      builder: (context, snap) {
        if (snap.hasError) {
          return AppScaffold(
            title: l10n.translate('memorial_title'),
            body: StateView.error(
              message: l10n.translate('memorial_error_generic'),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return AppScaffold(
            title: l10n.translate('memorial_title'),
            body: const StateView.loading(),
          );
        }
        final m = snap.data;
        if (m == null) {
          return AppScaffold(
            title: l10n.translate('memorial_title'),
            body: StateView.empty(
              icon: Icons.delete_outline_rounded,
              message: l10n.translate('memorial_deleted'),
              actionLabel: l10n.translate('memorial_remove_from_list'),
              onAction: () async {
                await sl<MemorialRepository>().leave(me, id);
                final reminders = sl<MemorialReminderService>();
                if (reminders.isEnabled(id)) {
                  await reminders.setEnabled(
                    Memorial(id: id, ownerUid: '', name: ''),
                    false,
                  );
                  if (context.mounted) {
                    await reminders.reschedule(
                      sl<NotificationService>(),
                      Localizations.localeOf(context).languageCode,
                    );
                  }
                }
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          );
        }
        return _MemorialView(memorial: m, me: me, justCreated: justCreated);
      },
    );
  }
}

class _MemorialView extends StatefulWidget {
  const _MemorialView({
    required this.memorial,
    required this.me,
    required this.justCreated,
  });

  final Memorial memorial;
  final MemorialActor me;
  final bool justCreated;

  @override
  State<_MemorialView> createState() => _MemorialViewState();
}

class _MemorialViewState extends State<_MemorialView> {
  MemorialRepository get _repo => sl<MemorialRepository>();
  Memorial get m => widget.memorial;
  bool get _isOwner => m.isOwner(widget.me.uid);

  @override
  void initState() {
    super.initState();
    if (widget.justCreated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppSnackBar(
            context,
            context.l10n.translate('memorial_created_hint'),
            type: SnackType.success,
            actionLabel: context.l10n.translate('memorial_share'),
            onAction: _share,
          );
        }
      });
    }
  }

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    final l10n = context.l10n;
    try {
      await action();
      if (mounted && success != null) {
        showAppSnackBar(context, success, type: SnackType.success);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, _errorText(e, l10n), type: SnackType.error);
      }
    }
  }

  void _share() {
    final l10n = context.l10n;
    Share.share(
      l10n
          .translate('memorial_share_text')
          .replaceAll('{name}', m.name)
          .replaceAll('{code}', m.id)
          .replaceAll('{link}', AppConfig.playStoreUrl),
    );
  }

  Future<void> _onPara(int para) async {
    final l10n = context.l10n;
    final claim = m.paras[para];
    final label = l10n.translate('memorial_para').replaceAll('{n}', '$para');
    if (claim == null) {
      final ok = await showConfirmDialog(
        context,
        title: label,
        message: l10n.translate('memorial_take_para_confirm'),
        confirmLabel: l10n.translate('memorial_take_para'),
      );
      if (ok && mounted) {
        await _run(() => _repo.claimPara(widget.me, m.id, para));
      }
      return;
    }
    if (claim.done) {
      showAppSnackBar(
        context,
        l10n
            .translate('memorial_para_read_by')
            .replaceAll('{n}', '$para')
            .replaceAll('{name}', claim.name),
      );
      return;
    }
    final mine = claim.uid == widget.me.uid;
    if (!mine && !_isOwner) {
      showAppSnackBar(
        context,
        l10n
            .translate('memorial_para_taken_by')
            .replaceAll('{n}', '$para')
            .replaceAll('{name}', claim.name),
      );
      return;
    }
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (sheet) => SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(label),
                    subtitle: Text(
                      mine
                          ? l10n.translate('memorial_para_yours')
                          : l10n
                              .translate('memorial_para_taken_by')
                              .replaceAll('{n}', '$para')
                              .replaceAll('{name}', claim.name),
                    ),
                  ),
                  if (mine)
                    ListTile(
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      title: Text(l10n.translate('memorial_mark_read')),
                      onTap: () => Navigator.of(sheet).pop('done'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.undo_rounded),
                    title: Text(l10n.translate('memorial_release_para')),
                    onTap: () => Navigator.of(sheet).pop('release'),
                  ),
                ],
              ),
            ),
          ),
    );
    if (!mounted) return;
    if (action == 'done') {
      try {
        final khatam = await _repo.completePara(widget.me, m.id, para);
        if (mounted) {
          showAppSnackBar(
            context,
            khatam
                ? l10n.translate('memorial_khatam_done')
                : l10n.translate('memorial_para_done'),
            type: SnackType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          showAppSnackBar(context, _errorText(e, l10n), type: SnackType.error);
        }
      }
    } else if (action == 'release') {
      await _run(() => _repo.releasePara(widget.me, m.id, para));
    }
  }

  Future<void> _addDhikr(String dhikrId) async {
    final l10n = context.l10n;
    final n = await showDialog<int>(
      context: context,
      builder:
          (_) => _NumberDialog(
            title: l10n.translate(DhikrPreset.byId(dhikrId)?.nameKey ?? ''),
            label: l10n.translate('memorial_how_many'),
          ),
    );
    if (n == null || n <= 0 || !mounted) return;
    await _run(
      () => _repo.addDhikr(widget.me, m.id, dhikrId, n),
      success: l10n.translate('memorial_added'),
    );
  }

  Future<void> _addDeed() async {
    final l10n = context.l10n;
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _DeedDialog(),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    await _run(
      () => _repo.addDeed(widget.me, m.id, text),
      success: l10n.translate('memorial_added'),
    );
  }

  Future<void> _menu(String value) async {
    final l10n = context.l10n;
    if (value == 'delete') {
      final ok = await showConfirmDialog(
        context,
        title: l10n.translate('memorial_delete'),
        message: l10n.translate('memorial_delete_confirm'),
        confirmLabel: l10n.translate('memorial_delete'),
        destructive: true,
      );
      if (!ok || !mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final error = l10n.translate('memorial_error_generic');
      final memorial = m;
      final me = widget.me;
      final stopping = _stopReminders(memorial);
      // Leave first: deleting makes this page's stream emit "deleted".
      Navigator.of(context).pop();
      await stopping;
      try {
        await _repo.delete(me, memorial.id);
      } catch (_) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      }
    } else if (value == 'leave') {
      await _run(() async {
        await _repo.leave(widget.me, m.id);
        await _stopReminders(m);
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  /// Removes this page's remembrance-day reminders from this device.
  /// Read before any await/pop: the page may be gone afterwards.
  Future<void> _stopReminders(Memorial memorial) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final reminders = sl<MemorialReminderService>();
    if (!reminders.isEnabled(memorial.id)) return;
    await reminders.setEnabled(memorial, false);
    await reminders.reschedule(sl<NotificationService>(), languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: m.name,
      actions: [
        IconButton(
          tooltip: l10n.translate('memorial_share'),
          icon: const Icon(Icons.share_outlined),
          onPressed: _share,
        ),
        PopupMenuButton<String>(
          onSelected: _menu,
          itemBuilder:
              (_) => [
                if (_isOwner)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.translate('memorial_delete')),
                  )
                else
                  PopupMenuItem(
                    value: 'leave',
                    child: Text(l10n.translate('memorial_remove_from_list')),
                  ),
              ],
        ),
      ],
      body: ListView(
        padding: AppSpacing.page,
        children: [
          _header(context),
          SizedBox(height: AppSpacing.vLg),
          _khatam(context),
          if (m.goals.isNotEmpty) ...[
            SizedBox(height: AppSpacing.vLg),
            _dhikr(context),
          ],
          SizedBox(height: AppSpacing.vLg),
          SecondaryButton(
            label: l10n.translate('memorial_add_deed'),
            icon: Icons.favorite_border_rounded,
            onPressed: _addDeed,
          ),
          if (m.deathDate != null && m.showDates) ...[
            SizedBox(height: AppSpacing.vLg),
            _MemorialDatesCard(memorial: m),
          ],
          SizedBox(height: AppSpacing.vXl),
          SectionHeader(
            title: l10n.translate('memorial_activity'),
            icon: Icons.history_rounded,
          ),
          SizedBox(height: AppSpacing.vSm),
          _MemorialFeed(id: m.id),
          SizedBox(height: AppSpacing.vXl),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final death = m.deathDate;
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        children: [
          const ArabicText(
            'إِنَّا لِلّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vMd),
          Text(
            m.name,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.secondaryGold,
            ),
          ),
          if (m.subtitle.isNotEmpty)
            Text(
              m.subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (death != null) ...[
            SizedBox(height: AppSpacing.vXs),
            Text(
              '${_date(context, death)} · ${hijriDateLabel(death, l10n)}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.vMd),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              ActionChip(
                avatar: Icon(Icons.copy_rounded, size: 16.sp),
                label: Text('${l10n.translate('memorial_code')}: ${m.id}'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: m.id));
                  showAppSnackBar(
                    context,
                    l10n.translate('memorial_code_copied'),
                  );
                },
              ),
              FilledButton.icon(
                onPressed: _share,
                icon: Icon(Icons.share_rounded, size: 18.sp),
                label: Text(l10n.translate('memorial_invite')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _khatam(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n
                      .translate('memorial_khatam_n')
                      .replaceAll('{n}', _num(context, m.khatams + 1)),
                  style: textTheme.titleMedium,
                ),
              ),
              Text(
                '${_num(context, m.parasDone)}/30',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.secondaryGold,
                ),
              ),
            ],
          ),
          if (m.khatams > 0)
            Text(
              l10n
                  .translate('memorial_khatams_completed')
                  .replaceAll('{n}', _num(context, m.khatams)),
              style: textTheme.bodySmall?.copyWith(color: AppColors.success),
            ),
          SizedBox(height: AppSpacing.vSm),
          Text(
            l10n.translate('memorial_khatam_hint'),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.vMd),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var p = 1; p <= Memorial.paraCount; p++) _paraCell(p),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.vXs,
            children: [
              _legend(AppColors.glassFill, l10n.translate('memorial_free')),
              _legend(
                AppColors.secondaryGold.withValues(alpha: 0.35),
                l10n.translate('memorial_yours'),
              ),
              _legend(
                AppColors.info.withValues(alpha: 0.3),
                l10n.translate('memorial_taken'),
              ),
              _legend(
                AppColors.success.withValues(alpha: 0.6),
                l10n.translate('memorial_read'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12.r,
        height: 12.r,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3.r),
        ),
      ),
      SizedBox(width: 4.w),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );

  Widget _paraCell(int p) {
    final l10n = context.l10n;
    final c = m.paras[p];
    final mine = c?.uid == widget.me.uid;
    final Color bg;
    if (c == null) {
      bg = AppColors.glassFill;
    } else if (c.done) {
      bg = AppColors.success.withValues(alpha: 0.6);
    } else if (mine) {
      bg = AppColors.secondaryGold.withValues(alpha: 0.35);
    } else {
      bg = AppColors.info.withValues(alpha: 0.3);
    }
    final label = l10n.translate('memorial_para').replaceAll('{n}', '$p');
    return Semantics(
      button: true,
      label:
          c == null
              ? '$label, ${l10n.translate('memorial_free')}'
              : '$label, ${c.name}',
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: () => _onPara(p),
          child: Center(
            child: Text(
              _num(context, p),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: mine ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dhikr(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('memorial_goals'), style: textTheme.titleMedium),
          for (final e in m.goals.entries) ...[
            SizedBox(height: AppSpacing.vMd),
            Builder(
              builder: (context) {
                final preset = DhikrPreset.byId(e.key);
                final count = m.counts[e.key] ?? 0;
                final goal = e.value <= 0 ? 1 : e.value;
                final reached = count >= goal;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.translate(preset?.nameKey ?? e.key),
                            style: textTheme.bodyLarge,
                          ),
                        ),
                        if (reached)
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 18.sp,
                          ),
                        TextButton.icon(
                          onPressed: () => _addDhikr(e.key),
                          icon: Icon(Icons.add_rounded, size: 18.sp),
                          label: Text(l10n.translate('memorial_add_count')),
                        ),
                      ],
                    ),
                    if (preset != null)
                      Text(
                        preset.arabic,
                        textDirection: TextDirection.rtl,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    SizedBox(height: AppSpacing.vXs),
                    ClipRRect(
                      borderRadius: AppRadius.smAll,
                      child: LinearProgressIndicator(
                        value: (count / goal).clamp(0, 1).toDouble(),
                        minHeight: 6,
                        backgroundColor: AppColors.glassFill,
                        color:
                            reached
                                ? AppColors.success
                                : AppColors.secondaryGold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.vXs),
                    Text(
                      '${_num(context, count)} / ${_num(context, goal)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MemorialDatesCard extends StatefulWidget {
  const _MemorialDatesCard({required this.memorial});

  final Memorial memorial;

  @override
  State<_MemorialDatesCard> createState() => _MemorialDatesCardState();
}

class _MemorialDatesCardState extends State<_MemorialDatesCard> {
  MemorialReminderService get _reminders => sl<MemorialReminderService>();

  Future<void> _toggle(bool on) async {
    final l10n = context.l10n;
    final settings = context.read<SettingsBloc>().state;
    if (on && !settings.notificationsEnabled) {
      showAppSnackBar(
        context,
        l10n.translate('reminders_need_notifications'),
        type: SnackType.info,
      );
      return;
    }
    await _reminders.setEnabled(widget.memorial, on);
    // With notifications off everything stays cancelled.
    if (settings.notificationsEnabled) {
      await _reminders.reschedule(
        sl<NotificationService>(),
        settings.languageCode,
      );
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final dates = MemorialDate.forDeath(widget.memorial.deathDate!, today);
    return AppCard(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('memorial_dates'), style: textTheme.titleMedium),
          SizedBox(height: AppSpacing.vSm),
          for (final d in dates)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.translate(d.key),
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            d.date.isBefore(t)
                                ? AppColors.textTertiary
                                : AppColors.textMain,
                      ),
                    ),
                  ),
                  Text(
                    '${_date(context, d.date)}\n${hijriDateLabel(d.date, l10n)}',
                    textAlign: TextAlign.end,
                    style: textTheme.bodySmall?.copyWith(
                      color:
                          d.date.isBefore(t)
                              ? AppColors.textTertiary
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.translate('memorial_remind_me')),
            value: _reminders.isEnabled(widget.memorial.id),
            onChanged: _toggle,
          ),
        ],
      ),
    );
  }
}

class _MemorialFeed extends StatelessWidget {
  const _MemorialFeed({required this.id});

  final String id;

  String _text(BuildContext context, MemorialEntry e) {
    final l10n = context.l10n;
    switch (e.type) {
      case 'para':
        return l10n
            .translate('memorial_feed_para')
            .replaceAll('{name}', e.name)
            .replaceAll('{n}', e.text);
      case 'khatam':
        return l10n.translate('memorial_feed_khatam').replaceAll('{n}', e.text);
      case 'dhikr':
        final preset = DhikrPreset.byId(e.text);
        return l10n
            .translate('memorial_feed_dhikr')
            .replaceAll('{name}', e.name)
            .replaceAll('{dhikr}', l10n.translate(preset?.nameKey ?? e.text))
            .replaceAll('{count}', _num(context, e.count));
      default:
        return '${e.name}: ${e.text}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return StreamBuilder<List<MemorialEntry>>(
      stream: sl<MemorialRepository>().watchEntries(id),
      builder: (context, snap) {
        final items = snap.data ?? const [];
        if (snap.hasError && items.isEmpty) {
          return Text(
            l10n.translate('memorial_error_generic'),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
          );
        }
        if (items.isEmpty) {
          return Text(
            snap.hasData
                ? l10n.translate('memorial_feed_empty')
                : l10n.translate('loading'),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          );
        }
        return Column(
          children: [
            for (final e in items)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      switch (e.type) {
                        'para' => Icons.menu_book_outlined,
                        'khatam' => Icons.auto_awesome,
                        'dhikr' => Icons.blur_circular_outlined,
                        _ => Icons.favorite_border_rounded,
                      },
                      size: 18.sp,
                      color: AppColors.secondaryGold,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _text(context, e),
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    if (e.createdAt != null)
                      Text(
                        _date(context, e.createdAt!),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({required this.title, required this.label});

  final String title;
  final String label;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_controller.text.trim());
    if (n == null || n <= 0) return;
    Navigator.of(context).pop(n.clamp(1, 1000000));
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(7),
        ],
        decoration: InputDecoration(labelText: widget.label),
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

class _DeedDialog extends StatefulWidget {
  const _DeedDialog();

  @override
  State<_DeedDialog> createState() => _DeedDialogState();
}

class _DeedDialogState extends State<_DeedDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.translate('memorial_add_deed')),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 500,
        maxLines: 4,
        minLines: 2,
        decoration: InputDecoration(
          hintText: l10n.translate('memorial_deed_hint'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
