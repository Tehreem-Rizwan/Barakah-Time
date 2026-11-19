import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Shows a themed confirmation dialog. Resolves to `true` only when the
/// user taps the confirm button (`false` on cancel / dismiss).
///
/// [confirmLabel] / [cancelLabel] default to the localized `confirm` /
/// `cancel`. With [destructive] the confirm button is red.
/// With [requireTypedText] (e.g. `'DELETE'`) the user must type that exact
/// text before confirm is enabled.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  String? requireTypedText,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder:
        (_) => _ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          destructive: destructive,
          requireTypedText: requireTypedText,
        ),
  );
  return result ?? false;
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
    required this.requireTypedText,
  });

  final String title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool destructive;
  final String? requireTypedText;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canConfirm =>
      widget.requireTypedText == null ||
      _controller.text.trim() == widget.requireTypedText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final required = widget.requireTypedText;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.message != null) Text(widget.message!),
          if (required != null) ...[
            if (widget.message != null) SizedBox(height: AppSpacing.vLg),
            TextField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.typeToConfirm(required),
                hintText: required,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_canConfirm) Navigator.of(context).pop(true);
              },
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: Text(widget.cancelLabel ?? l10n.cancel),
        ),
        FilledButton(
          onPressed: _canConfirm ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            minimumSize: Size(72.w, 40.h),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.r),
            ),
            backgroundColor: widget.destructive ? AppColors.error : null,
            foregroundColor: widget.destructive ? AppColors.onGold : null,
            disabledBackgroundColor:
                widget.destructive
                    ? AppColors.error.withValues(alpha: 0.3)
                    : null,
          ),
          child: Text(widget.confirmLabel ?? l10n.confirm),
        ),
      ],
    );
  }
}
