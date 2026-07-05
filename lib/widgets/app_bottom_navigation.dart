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
    _NavData(Icons.calendar_today_rounded, 'اليوم'),
    _NavData(Icons.add_rounded, 'التسجيل'),
    _NavData(Icons.child_care_rounded, 'طفلي'),
    _NavData(Icons.auto_awesome_rounded, 'اسألي نُمُوّ'),
    _NavData(Icons.grid_view_rounded, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final night = numuwNightMode();
    final surface = numuwSurfaceColor();
    final border = numuwBorderColor();
    final accent = numuwAccentColor();
    final inactive = numuwNightMode()
        ? AppColors.nightMutedText
        : AppColors.mutedText;

    return Material(
      color: surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Container(
          height: 78,
          padding: const EdgeInsetsDirectional.fromSTEB(6, 8, 6, 10),
          decoration: BoxDecoration(
            color: surface,
            border: Border(top: BorderSide(color: border)),
            boxShadow: night
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              if (index == 1) {
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: item.label,
                    child: InkResponse(
                      onTap: () => onChanged(index),
                      radius: 38,
                      child: Transform.translate(
                        offset: const Offset(0, -15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: NumuwMotion.fast,
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: surface,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: .32),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 32,
                                color: night
                                    ? AppColors.nightBackground
                                    : AppColors.surface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              maxLines: 1,
                              style: TextStyle(
                                color: accent,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: item.label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onChanged(index),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: NumuwMotion.fast,
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? (night
                                        ? accent.withValues(alpha: .14)
                                        : AppColors.mintLight)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              item.icon,
                              size: 21,
                              color: selected ? accent : inactive,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.label,
                              maxLines: 1,
                              style: TextStyle(
                                color: selected ? accent : inactive,
                                fontSize: 10,
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
