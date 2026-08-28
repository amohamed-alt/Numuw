import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'app_widgets.dart';

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
    final night = numuwNightMode();
    final surface = numuwSurfaceColor();
    final border = numuwBorderColor();
    final accent = numuwAccentColor();
    final inactive = numuwSecondaryTextColor();
    final activeBackground = night
        ? AppColors.nightGold.withValues(alpha: .16)
        : AppColors.mintLight;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 68,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: .98),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: night
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final color = selected ? accent : inactive;

              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: item.label,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onChanged(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? activeBackground
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: selected
                              ? Border.all(
                                  color: accent.withValues(alpha: .22),
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 180),
                              scale: selected ? 1.06 : 1,
                              child: Icon(item.icon, size: 21, color: color),
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10.5,
                                  height: 1.1,
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
