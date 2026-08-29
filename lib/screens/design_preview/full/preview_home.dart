import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/app_bottom_navigation.dart';
import '../../../widgets/classy/classy_home_view.dart';
import '../../../widgets/classy/reference_home_view.dart';
import 'preview_shared.dart';

class PreviewHomeScreen extends StatelessWidget {
  const PreviewHomeScreen({super.key, required this.black});

  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    showBack: false,
    padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 18),
    bottom: AppBottomNavigation(
      selectedIndex: 0,
      onChanged: (_) {},
    ),
    child: NumuwReferenceHomeView(
      data: const ClassyHomeViewData(
        greeting: 'مرحباً يا ماما',
        subtitle: 'اليوم، 28 أغسطس',
        childName: 'ليان أحمد',
        childAge: '9 أشهر و12 يوم',
        latestFeeding: '5',
        sleepToday: '2',
        latestDiaper: '3',
        nextVaccination: '1',
        metrics: [
          ClassyHomeMetric(
            label: 'رضعات',
            value: '5',
            icon: Icons.water_drop_outlined,
            tint: AppColors.roseMist,
            accent: AppColors.plum,
          ),
          ClassyHomeMetric(
            label: 'حفاضات',
            value: '3',
            icon: Icons.baby_changing_station_outlined,
            tint: AppColors.powderSoft,
            accent: AppColors.info,
          ),
          ClassyHomeMetric(
            label: 'نوم',
            value: '2',
            icon: Icons.bedtime_outlined,
            tint: AppColors.sageSoft,
            accent: AppColors.success,
          ),
          ClassyHomeMetric(
            label: 'أدوية',
            value: '1',
            icon: Icons.medication_outlined,
            tint: AppColors.blushSoft,
            accent: AppColors.danger,
          ),
        ],
        timeline: [
          ClassyHomeTimelineItem(
            title: 'رضاعة طبيعية',
            subtitle: '15 دقيقة · جهة اليمين',
            time: '12:30',
          ),
          ClassyHomeTimelineItem(
            title: 'نوم',
            subtitle: 'ساعة و20 دقيقة',
            time: '11:20',
            color: AppColors.success,
          ),
          ClassyHomeTimelineItem(
            title: 'حفاضة',
            subtitle: 'مبللة ومتسخة',
            time: '10:30',
            color: AppColors.info,
          ),
        ],
      ),
      onRefresh: previewNoop,
      onChildTap: previewNoop,
      onVaccinationTap: previewNoop,
      onViewAll: previewNoop,
      onFeeding: previewNoop,
      onPumping: previewNoop,
      onSleep: previewNoop,
      onDiaper: previewNoop,
      onFood: previewNoop,
      onMedicine: previewNoop,
    ),
  );
}
