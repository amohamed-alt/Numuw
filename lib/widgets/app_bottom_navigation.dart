import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const items = [
    _NavData(Icons.home_rounded, 'اليوم'),
    _NavData(Icons.edit_note_rounded, 'التسجيل'),
    _NavData(Icons.child_care_rounded, 'طفلي'),
    _NavData(Icons.chat_bubble_outline_rounded, 'اسألي'),
    _NavData(Icons.menu_rounded, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 12),
        padding: EdgeInsetsDirectional.fromSTEB(
          10,
          10,
          10,
          bottomInset > 0 ? bottomInset : 0,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A4F6242),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final color = selected ? AppColors.mintDark : AppColors.mutedText;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsetsDirectional.symmetric(
                      horizontal: 3,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mintLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      border: selected
                          ? Border.all(color: AppColors.mintSoft)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 23, color: color),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: color,
                              fontSize: 10.5,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  const _NavData(this.icon, this.label);
  final IconData icon;
  final String label;
}
