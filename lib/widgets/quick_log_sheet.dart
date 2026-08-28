import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'app_widgets.dart';

class QuickLogSheet extends StatelessWidget {
  const QuickLogSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      _Action('feeding', 'رضاعة', Icons.local_drink_outlined, AppColors.mint),
      _Action('sleep', 'نوم', Icons.dark_mode_outlined, AppColors.blue),
      _Action('diaper', 'حفاضة', Icons.opacity_rounded, AppColors.success),
      _Action('medicine', 'دواء', Icons.medication_outlined, AppColors.peach),
      _Action(
        'temperature',
        'حرارة',
        Icons.thermostat_rounded,
        AppColors.danger,
      ),
      _Action('food', 'وجبة', Icons.restaurant_rounded, AppColors.mint),
      _Action('note', 'ملاحظة', Icons.note_alt_outlined, AppColors.blue),
      _Action('pumping', 'شفط', Icons.water_drop_outlined, AppColors.purple),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 6, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsetsDirectional.only(bottom: 16),
                decoration: BoxDecoration(
                  color: numuwBorderColor(),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'ماذا تريدين أن تسجّلي؟',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: actions
                      .map(
                        (action) => SizedBox(
                          width: width,
                          child: Material(
                            color: numuwPageColor(),
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, action.mode),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 70,
                                ),
                                padding: const EdgeInsetsDirectional.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: numuwBorderColor()),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: action.color.withValues(
                                          alpha: .13,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        action.icon,
                                        color: action.color,
                                        size: 21,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        action.label,
                                        style: TextStyle(
                                          color: numuwTextColor(),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Action {
  const _Action(this.mode, this.label, this.icon, this.color);
  final String mode;
  final String label;
  final IconData icon;
  final Color color;
}
