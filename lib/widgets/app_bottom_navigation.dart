import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../design/numuw_organic_icons.dart';
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
    _NavData(NumuwOrganicIconName.home, 'اليوم'),
    _NavData(NumuwOrganicIconName.add, 'التسجيل'),
    _NavData(NumuwOrganicIconName.newborn, 'طفلي'),
    _NavData(NumuwOrganicIconName.aiAssistant, 'اسألي'),
    _NavData(NumuwOrganicIconName.more, 'المزيد'),
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
      minimum: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 72,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: .98),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: border),
            boxShadow: night
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final labelColor = selected ? accent : inactive;

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
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? activeBackground : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: selected
                              ? Border.all(color: accent.withValues(alpha: .2))
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutBack,
                              scale: selected ? 1.08 : .94,
                              child: NumuwOrganicIcon(
                                item.icon,
                                size: selected ? 25 : 23,
                                semanticLabel: item.label,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 10.5,
                                  height: 1.1,
                                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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

  final NumuwOrganicIconName icon;
  final String label;
}
