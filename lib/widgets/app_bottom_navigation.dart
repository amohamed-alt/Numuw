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
    _NavData(Icons.add_box_outlined, 'تسجيل'),
    _NavData(Icons.child_care_outlined, 'طفلي'),
    _NavData(Icons.chat_bubble_outline_rounded, 'المساعد'),
    _NavData(Icons.apps_rounded, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final night = numuwNightMode();
    final surface = numuwSurfaceColor();
    final border = numuwBorderColor();
    final accent = night ? AppColors.nightPrimaryStrong : AppColors.plum;
    final inactive = numuwSecondaryTextColor();

    return SafeArea(
      top: false,
      child: RepaintBoundary(
        child: Container(
          height: 64,
          padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: .995),
            border: Border(top: BorderSide(color: border.withValues(alpha: .8))),
            boxShadow: night
                ? const <BoxShadow>[]
                : const [
                    BoxShadow(
                      color: Color(0x0A442A34),
                      blurRadius: 14,
                      offset: Offset(0, -3),
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
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          duration: NumuwMotionTokens.chip,
                          curve: NumuwMotionTokens.standard,
                          scale: selected ? 1.07 : 1,
                          child: Icon(
                            item.icon,
                            size: selected ? 20 : 19,
                            color: selected ? accent : inactive,
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
                              fontSize: 9.2,
                              height: 1,
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
