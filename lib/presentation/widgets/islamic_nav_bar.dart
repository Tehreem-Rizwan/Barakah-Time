import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// One tab of [IslamicNavBar].
class IslamicNavItem {
  const IslamicNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom navigation in the app's tile style: ivory bar with a brass
/// hairline; the selected tab sits inside a small turquoise mihrab (arch).
class IslamicNavBar extends StatelessWidget {
  const IslamicNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<IslamicNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: const Border(
          top: BorderSide(color: AppColors.brass, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMain.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom, top: 6.h),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _NavTab(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () {
                    if (i != selectedIndex) HapticFeedback.selectionClick();
                    onSelected(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final IslamicNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36.r,
        highlightShape: BoxShape.rectangle,
        child: SizedBox(
          height: 60.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: selected ? 46.r : 40.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: selected ? AppColors.secondaryGold : Colors.transparent,
                  // Mihrab: tall rounded top, small rounded base.
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(23.r),
                    bottom: Radius.circular(6.r),
                  ),
                  border:
                      selected
                          ? Border.all(color: AppColors.brass, width: 1.2)
                          : null,
                ),
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 21.sp,
                  color:
                      selected ? AppColors.ivoryOnTeal : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color:
                      selected ? AppColors.secondaryGold : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
