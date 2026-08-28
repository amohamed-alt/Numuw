import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../numuw_classy_components.dart';
import '../numuw_motion_widgets.dart';

class ClassyHomeTimelineItem {
  const ClassyHomeTimelineItem({
    required this.title,
    required this.subtitle,
    required this.time,
    this.color = AppColors.plum,
  });

  final String title;
  final String subtitle;
  final String time;
  final Color color;
}

class ClassyHomeViewData {
  const ClassyHomeViewData({
    required this.greeting,
    required this.subtitle,
    required this.childName,
    required this.childAge,
    required this.latestFeeding,
    required this.sleepToday,
    required this.latestDiaper,
    required this.nextVaccination,
    required this.timeline,
    this.tipTitle = 'نصيحة اليوم',
    this.tipText = 'روتين بسيط ومتكرر يساعدك تلاحظي نمط يوم طفلك بهدوء.',
    this.activityTitle = 'نشاط مناسب',
    this.activityText = 'اختاري نشاطًا قصيرًا مناسبًا لعمر طفلك وطاقته اليوم.',
  });

  final String greeting;
  final String subtitle;
  final String childName;
  final String childAge;
  final String latestFeeding;
  final String sleepToday;
  final String latestDiaper;
  final String nextVaccination;
  final List<ClassyHomeTimelineItem> timeline;
  final String tipTitle;
  final String tipText;
  final String activityTitle;
  final String activityText;
}

class ClassyHomeView extends StatelessWidget {
  const ClassyHomeView({
    super.key,
    required this.data,
    this.onRefresh,
    this.onChildTap,
    this.onVaccinationTap,
    this.onViewAll,
    this.onFeeding,
    this.onPumping,
    this.onSleep,
    this.onDiaper,
    this.onFood,
    this.onMedicine,
  });

  final ClassyHomeViewData data;
  final VoidCallback? onRefresh;
  final VoidCallback? onChildTap;
  final VoidCallback? onVaccinationTap;
  final VoidCallback? onViewAll;
  final VoidCallback? onFeeding;
  final VoidCallback? onPumping;
  final VoidCallback? onSleep;
  final VoidCallback? onDiaper;
  final VoidCallback? onFood;
  final VoidCallback? onMedicine;

  Color _text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.nightText
      : AppColors.text;

  Color _secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.nightSecondaryText
      : AppColors.secondaryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.greeting,
                    style: TextStyle(
                      color: _text(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      color: _secondary(context),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (onRefresh != null)
              IconButton(
                tooltip: 'تحديث',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
          ],
        ),
        const SizedBox(height: 16),
        NumuwFadeSlideIn(
          child: NumuwChildIdentity(
            name: data.childName,
            age: data.childAge,
            onTap: onChildTap,
          ),
        ),
        const SizedBox(height: 22),
        const NumuwSectionLabel(
          title: 'نظرة سريعة لليوم',
          subtitle: 'الأهم أولاً، بدون تفاصيل تشتتك',
        ),
        const SizedBox(height: 11),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.16,
          children: [
            NumuwMetricTile(
              label: 'آخر رضعة',
              value: data.latestFeeding,
              icon: Icons.water_drop_outlined,
              onTap: onFeeding,
            ),
            NumuwMetricTile(
              label: 'نوم اليوم',
              value: data.sleepToday,
              icon: Icons.dark_mode_outlined,
              tint: AppColors.lavenderSoft,
              accent: const Color(0xFF8D7399),
              onTap: onSleep,
            ),
            NumuwMetricTile(
              label: 'آخر حفاضة',
              value: data.latestDiaper,
              icon: Icons.baby_changing_station_outlined,
              tint: AppColors.powderSoft,
              accent: AppColors.info,
              onTap: onDiaper,
            ),
            NumuwMetricTile(
              label: 'التطعيم القادم',
              value: data.nextVaccination,
              icon: Icons.vaccines_outlined,
              tint: AppColors.champagneSoft,
              accent: AppColors.warning,
              onTap: onVaccinationTap,
            ),
          ],
        ),
        const SizedBox(height: 23),
        const NumuwSectionLabel(title: 'تسجيل سريع'),
        const SizedBox(height: 11),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              NumuwQuickAction(
                label: 'رضاعة',
                icon: Icons.water_drop_outlined,
                onTap: onFeeding,
              ),
              const SizedBox(width: 7),
              NumuwQuickAction(
                label: 'شفط',
                icon: Icons.opacity_rounded,
                tint: AppColors.lavenderSoft,
                accent: const Color(0xFF8D7399),
                onTap: onPumping,
              ),
              const SizedBox(width: 7),
              NumuwQuickAction(
                label: 'نوم',
                icon: Icons.dark_mode_outlined,
                tint: AppColors.lavenderSoft,
                accent: const Color(0xFF8D7399),
                onTap: onSleep,
              ),
              const SizedBox(width: 7),
              NumuwQuickAction(
                label: 'حفاضة',
                icon: Icons.baby_changing_station_outlined,
                tint: AppColors.powderSoft,
                accent: AppColors.info,
                onTap: onDiaper,
              ),
              const SizedBox(width: 7),
              NumuwQuickAction(
                label: 'طعام',
                icon: Icons.restaurant_rounded,
                tint: AppColors.champagneSoft,
                accent: AppColors.warning,
                onTap: onFood,
              ),
              const SizedBox(width: 7),
              NumuwQuickAction(
                label: 'دواء',
                icon: Icons.medication_outlined,
                tint: AppColors.peachLight,
                accent: AppColors.danger,
                onTap: onMedicine,
              ),
            ],
          ),
        ),
        const SizedBox(height: 23),
        NumuwClassySurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumuwSectionLabel(
                title: 'اليوم مع ${data.childName}',
                actionLabel: 'عرض الكل',
                onAction: onViewAll,
              ),
              const SizedBox(height: 14),
              if (data.timeline.isEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 18),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          color: _secondary(context),
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أول تسجيل اليوم هيظهر هنا',
                          style: TextStyle(
                            color: _secondary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (var index = 0; index < data.timeline.length; index++)
                  NumuwTimelineRow(
                    title: data.timeline[index].title,
                    subtitle: data.timeline[index].subtitle,
                    time: data.timeline[index].time,
                    color: data.timeline[index].color,
                    isLast: index == data.timeline.length - 1,
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: NumuwClassySurface(
                tinted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeatureIcon(
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppColors.plum,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.tipTitle,
                      style: TextStyle(
                        color: _text(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.tipText,
                      style: TextStyle(
                        color: _secondary(context),
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NumuwClassySurface(
                tinted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FeatureIcon(
                      icon: Icons.star_outline_rounded,
                      color: AppColors.warning,
                      background: AppColors.champagneSoft,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.activityTitle,
                      style: TextStyle(
                        color: _text(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.activityText,
                      style: TextStyle(
                        color: _secondary(context),
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({
    required this.icon,
    required this.color,
    this.background,
  });

  final IconData icon;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: background ?? color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}
