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
    _NavData(Icons.chat_bubble_outline_rounded, 'اسألي المساعد'),
    _NavData(Icons.menu_rounded, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final color = selected ? AppColors.mint : AppColors.mutedText;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(index),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 2,
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
