import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/classy/classy_home_view.dart';
import '../../../widgets/numuw_classy_components.dart';
import 'preview_shared.dart';

class PreviewHomeScreen extends StatelessWidget {
  const PreviewHomeScreen({super.key, required this.black});

  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    showBack: true,
    bottom: const Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
      child: NumuwBottomBarPreview(selectedIndex: 0),
    ),
    child: ClassyHomeView(
      data: const ClassyHomeViewData(
        greeting: 'مرحباً يا ماما',
        subtitle: 'الجمعة 28 أغسطس · يوم هادئ مع ليان',
        childName: 'ليان أحمد',
        childAge: '9 أشهر و12 يوم',
        latestFeeding: '12:30',
        sleepToday: '2 س 40 د',
        latestDiaper: '11:20',
        nextVaccination: 'بعد 4 أيام',
        timeline: [
          ClassyHomeTimelineItem(
            title: 'رضاعة طبيعية',
            subtitle: '15 دقيقة · الجهة اليمنى',
            time: '12:30',
          ),
          ClassyHomeTimelineItem(
            title: 'حفاضة',
            subtitle: 'مبللة',
            time: '11:20',
            color: AppColors.info,
          ),
          ClassyHomeTimelineItem(
            title: 'نوم',
            subtitle: 'ساعة و20 دقيقة',
            time: '10:10',
            color: Color(0xFF8D7399),
          ),
        ],
        tipText: 'روتين بسيط قبل النوم يساعد على الانتقال بهدوء.',
        activityText: 'لعبة لمس الأقمشة · 5 دقائق',
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
