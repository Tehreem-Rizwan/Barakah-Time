import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'app_buttons.dart';

enum _StateKind { loading, empty, error }

/// Unified loading / empty / error placeholder.
///
/// Fills the available space and centers its content. When placed in a
/// bounded-height parent it is wrapped in an always-scrollable
/// [SingleChildScrollView] so it works as the child of a [RefreshIndicator]
/// (pull-to-refresh still triggers). In an unbounded parent (e.g. inside a
/// `Column` in a scroll view) it simply sizes to its content.
class StateView extends StatelessWidget {
  /// Spinner with an optional message.
  const StateView.loading({super.key, this.message})
    : _kind = _StateKind.loading,
      icon = null,
      actionLabel = null,
      onAction = null,
      secondaryLabel = null,
      onSecondary = null;

  /// Icon + message, with an optional call-to-action.
  const StateView.empty({
    super.key,
    required IconData this.icon,
    required String this.message,
    this.actionLabel,
    this.onAction,
  }) : _kind = _StateKind.empty,
       secondaryLabel = null,
       onSecondary = null;

  /// Error icon + message, with a localized "Retry" button when [onRetry]
  /// is provided and an optional secondary action (e.g. "Open settings").
  const StateView.error({
    super.key,
    required String this.message,
    VoidCallback? onRetry,
    this.secondaryLabel,
    this.onSecondary,
    this.icon = Icons.error_outline_rounded,
  }) : _kind = _StateKind.error,
       actionLabel = null,
       onAction = onRetry;

  final _StateKind _kind;
  final IconData? icon;
  final String? message;
  final String? actionLabel;

  /// Empty: CTA callback. Error: retry callback.
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.vXl,
      ),
      child: _buildContent(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Center(child: content);
        }
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.hasBoundedWidth ? constraints.maxWidth : 0,
            ),
            child: Center(child: content),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final messageText =
        message == null
            ? null
            : Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15.sp,
              ),
            );

    switch (_kind) {
      case _StateKind.loading:
        return Semantics(
          liveRegion: true,
          label: message ?? l10n.loading,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36.r,
                  height: 36.r,
                  child: const CircularProgressIndicator(strokeWidth: 3),
                ),
                if (messageText != null) ...[
                  SizedBox(height: AppSpacing.vLg),
                  messageText,
                ],
              ],
            ),
          ),
        );
      case _StateKind.empty:
      case _StateKind.error:
        final isError = _kind == _StateKind.error;
        final accent = isError ? AppColors.error : AppColors.secondaryGold;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.1),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, color: accent, size: 34.sp),
            ),
            SizedBox(height: AppSpacing.vLg),
            Semantics(liveRegion: isError, child: messageText),
            if (onAction != null) ...[
              SizedBox(height: AppSpacing.vXl),
              if (isError)
                PrimaryButton(
                  label: l10n.retry,
                  icon: Icons.refresh_rounded,
                  onPressed: onAction,
                  expand: false,
                )
              else
                SecondaryButton(
                  label: actionLabel ?? l10n.retry,
                  onPressed: onAction,
                  expand: false,
                ),
            ],
            if (secondaryLabel != null && onSecondary != null) ...[
              SizedBox(height: AppSpacing.vSm),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        );
    }
  }
}
