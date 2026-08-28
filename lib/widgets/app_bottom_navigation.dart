import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/theme/numuw_motion.dart';
import 'app_widgets.dart';
import 'numuw_motion_widgets.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const items = <_NavData>[
    _NavData(Icons.home_rounded, 'الرئيسية'),
    _NavData(Icons.add_circle_outline_rounded, 'تسجيل'),
    _NavData(Icons.child_care_rounded, 'طفلي'),
    _NavData(Icons.auto_awesome_outlined, 'المساعد'),
    _NavData(Icons.grid_view_rounded, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final night = numuwNightMode();
    final surface = numuwSurfaceColor();
    final border = numuwBorderColor();
    final accent = night ? AppColors.nightPrimaryStrong : AppColors.plum;
    final inactive = numuwSecondaryTextColor();
    final activeBackground = night
        ? AppColors.nightPrimarySoft
        : AppColors.roseMist;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: RepaintBoundary(
        child: Container(
          height: 72,
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 7),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: .985),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
            boxShadow: night
                ? const <BoxShadow>[]
                : const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x12442A34),
                      blurRadius: 26,
                      offset: Offset(0, 10),
                    ),
                  ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: item.label,
                  child: NumuwPressable(
                    onTap: selected ? null : () => onChanged(index),
                    scale: .97,
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 2,
                        vertical: 1,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: NumuwMotionTokens.chip,
                            curve: NumuwMotionTokens.standard,
                            width: selected ? 40 : 36,
                            height: 32,
                            decoration: BoxDecoration(
                              color: selected
                                  ? activeBackground
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(13),
                              border: selected
                                  ? Border.all(
                                      color: accent.withValues(alpha: .16),
                                    )
                                  : null,
                            ),
                            child: AnimatedScale(
                              duration: NumuwMotionTokens.chip,
                              curve: NumuwMotionTokens.standard,
                              scale: selected ? 1.04 : 1,
                              child: Icon(
                                item.icon,
                                size: 19,
                                color: selected ? accent : inactive,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedDefaultTextStyle(
                              duration: NumuwMotionTokens.chip,
                              curve: NumuwMotionTokens.standard,
                              style: TextStyle(
                                color: selected ? accent : inactive,
                                fontSize: 9.5,
                                height: 1.1,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                textAlign: TextAlign.center,
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
