import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../blocs/settings_bloc.dart';

/// The Quran font chosen in Settings (rebuilds the caller when it changes).
/// Amiri when no [SettingsBloc] is above [context] (e.g. in some tests).
String quranFontOf(BuildContext context) {
  try {
    return context.select<SettingsBloc, String>((b) => b.state.quranFont);
  } catch (_) {
    return 'amiri';
  }
}

/// Quranic / Arabic text in the chosen Quran font, always right-to-left regardless
/// of the app locale.
///
/// [fontSize] is used as-is (pass an `.sp` value); defaults to `24.sp`.
/// [textAlign] defaults to [TextAlign.start], i.e. right-aligned.
class ArabicText extends StatelessWidget {
  const ArabicText(
    this.text, {
    super.key,
    this.fontSize,
    this.textAlign = TextAlign.start,
    this.color,
    this.fontWeight,
    this.height = 1.9,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final double? fontSize;
  final TextAlign textAlign;

  /// Defaults to [AppColors.textMain].
  final Color? color;
  final FontWeight? fontWeight;

  /// Generous default line height so harakat don't collide.
  final double height;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      locale: const Locale('ar'),
      style: AppFonts.quran(
        quranFontOf(context),
        TextStyle(
          fontSize: fontSize ?? 24.sp,
          color: color ?? AppColors.textMain,
          fontWeight: fontWeight,
          height: height,
        ),
      ),
    );
  }
}

/// Translation / transliteration text. When [isLtr] is true (e.g. an
/// English translation) the direction is forced to LTR so punctuation and
/// alignment stay correct even when the app UI is RTL. Otherwise the
/// ambient direction is used.
class TranslationText extends StatelessWidget {
  const TranslationText(
    this.text, {
    super.key,
    this.isLtr = true,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final bool isLtr;

  /// Merged over the default (bodyLarge, [AppColors.textSecondary], 1.6).
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 15.sp,
      color: AppColors.textSecondary,
      height: 1.6,
    );
    return Text(
      text,
      textDirection: isLtr ? TextDirection.ltr : null,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: base?.merge(style) ?? style,
    );
  }
}
