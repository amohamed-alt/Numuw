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

class ClassyHomeMetric {
  const ClassyHomeMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color accent;
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
    this.metrics,
    this.childImageProvider,
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
  final List<ClassyHomeMetric>? metrics;
  final ImageProvider? childImageProvider;
  final String tipTitle;
  final String tipText;
  final String activityTitle;
  final String activityText;

  List<ClassyHomeMetric> get resolvedMetrics => metrics ?? [
    ClassyHomeMetric(
      label: 'رضاعة',
      value: latestFeeding,
      icon: Icons.water_drop_outlined,
      tint: AppColors.roseMist,
      accent: AppColors.plum,
    ),
    ClassyHomeMetric(
      label: 'حفاضة',
      value: latestDiaper,
      icon: Icons.baby_changing_station_outlined,
      tint: AppColors.powderSoft,
      accent: AppColors.info,
    ),
    ClassyHomeMetric(
      label: 'نوم',
      value: sleepToday,
      icon: Icons.bedtime_outlined,
      tint: AppColors.sageSoft,
      accent: AppColors.success,
    ),
    ClassyHomeMetric(
      label: 'تطعيم',
      value: nextVaccination,
      icon: Icons.vaccines_outlined,
      tint: AppColors.champagneSoft,
      accent: AppColors.warning,
    ),
  ];
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

  bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _text(BuildContext context) =>
      _dark(context) ? AppColors.nightText : AppColors.text;

  Color _secondary(BuildContext context) =>
      _dark(context) ? AppColors.nightSecondaryText : AppColors.secondaryText;

  Color _border(BuildContext context) =>
      _dark(context) ? AppColors.nightBorder : AppColors.border;

  Color _surfaceRaised(BuildContext context) =>
      _dark(context) ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised;

  @override
  Widget build(BuildContext context) {
    final metrics = data.resolvedMetrics.take(4).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopUtilityBar(
          onRefresh: onRefresh,
          onChildTap: onChildTap,
          textColor: _text(context),
          secondaryColor: _secondary(context),
        ),
        const SizedBox(height: 2),
        NumuwFadeSlideIn(
          child: _CenteredChildHero(
            name: data.childName,
            age: data.childAge,
            imageProvider: data.childImageProvider,
            onTap: onChildTap,
          ),
        ),
        const SizedBox(height: 17),
        NumuwClassySurface(
          radius: 22,
          padding: const EdgeInsetsDirectional.fromSTEB(13, 15, 13, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'نظرة سريعة لليوم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _text(context),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _secondary(context),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var index = 0; index < metrics.length; index++) ...[
                    Expanded(
                      child: _CompactMetric(
                        metric: metrics[index],
                        onTap: switch (index) {
                          0 => onFeeding,
                          1 => onDiaper,
                          2 => onSleep,
                          _ => onVaccinationTap,
                        },
                      ),
                    ),
                    if (index != metrics.length - 1)
                      const SizedBox(width: 7),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'تسجيل سريع',
                  style: TextStyle(
                    color: _text(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: _CompactQuickAction(
                      label: 'رضاعة',
                      icon: Icons.water_drop_outlined,
                      tint: AppColors.roseMist,
                      accent: AppColors.plum,
                      onTap: onFeeding,
                    ),
                  ),
                  Expanded(
                    child: _CompactQuickAction(
                      label: 'شفط',
                      icon: Icons.opacity_rounded,
                      tint: AppColors.lavenderSoft,
                      accent: const Color(0xFF8D7399),
                      onTap: onPumping,
                    ),
                  ),
                  Expanded(
                    child: _CompactQuickAction(
                      label: 'نوم',
                      icon: Icons.bedtime_outlined,
                      tint: AppColors.sageSoft,
                      accent: AppColors.success,
                      onTap: onSleep,
                    ),
                  ),
                  Expanded(
                    child: _CompactQuickAction(
                      label: 'طعام',
                      icon: Icons.restaurant_rounded,
                      tint: AppColors.champagneSoft,
                      accent: AppColors.warning,
                      onTap: onFood,
                    ),
                  ),
                  Expanded(
                    child: _CompactQuickAction(
                      label: 'دواء',
                      icon: Icons.medication_outlined,
                      tint: AppColors.powderSoft,
                      accent: AppColors.info,
                      onTap: onMedicine,
                    ),
                  ),
                  Expanded(
                    child: _CompactQuickAction(
                      label: 'المزيد',
                      icon: Icons.more_horiz_rounded,
                      tint: _surfaceRaised(context),
                      accent: _secondary(context),
                      onTap: onViewAll,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        NumuwClassySurface(
          radius: 20,
          padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 15, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'آخر الأنشطة',
                style: TextStyle(
                  color: _text(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 13),
              if (data.timeline.isEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: _secondary(context),
                        size: 25,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'أول تسجيل اليوم هيظهر هنا',
                        style: TextStyle(
                          color: _secondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
              Divider(height: 1, color: _border(context).withValues(alpha: .7)),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: _dark(context)
                      ? AppColors.nightPrimaryStrong
                      : AppColors.plum,
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('عرض كل الأنشطة'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TopUtilityBar extends StatelessWidget {
  const _TopUtilityBar({
    required this.onRefresh,
    required this.onChildTap,
    required this.textColor,
    required this.secondaryColor,
  });

  final VoidCallback? onRefresh;
  final VoidCallback? onChildTap;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UtilityIcon(
              icon: Icons.notifications_none_rounded,
              color: textColor,
            ),
            const SizedBox(width: 2),
            _UtilityIcon(
              icon: Icons.calendar_month_outlined,
              color: textColor,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UtilityIcon(
              icon: Icons.person_outline_rounded,
              color: textColor,
              onTap: onChildTap,
            ),
            const SizedBox(width: 2),
            _UtilityIcon(
              icon: Icons.history_rounded,
              color: secondaryColor,
              onTap: onRefresh,
            ),
          ],
        ),
      ],
    ),
  );
}

class _UtilityIcon extends StatelessWidget {
  const _UtilityIcon({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(
      width: 40,
      height: 40,
      child: Icon(icon, size: 19, color: color),
    ),
  );
}

class _CenteredChildHero extends StatelessWidget {
  const _CenteredChildHero({
    required this.name,
    required this.age,
    required this.imageProvider,
    required this.onTap,
  });

  final String name;
  final String age;
  final ImageProvider? imageProvider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark
        ? AppColors.nightSecondaryText
        : AppColors.secondaryText;

    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(56),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? AppColors.nightSurfaceRaised : AppColors.surface,
              boxShadow: dark
                  ? const <BoxShadow>[]
                  : const [
                      BoxShadow(
                        color: Color(0x16442A34),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? AppColors.nightPrimarySoft : AppColors.blushSoft,
                image: imageProvider == null
                    ? null
                    : DecorationImage(image: imageProvider!, fit: BoxFit.cover),
              ),
              alignment: Alignment.center,
              child: imageProvider == null
                  ? Icon(
                      Icons.child_care_rounded,
                      color: dark ? AppColors.nightPrimary : AppColors.plum,
                      size: 36,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text,
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            age,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.metric, required this.onTap});

  final ClassyHomeMetric metric;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark
        ? AppColors.nightSecondaryText
        : AppColors.secondaryText;

    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 92,
        padding: const EdgeInsetsDirectional.fromSTEB(5, 8, 5, 8),
        decoration: BoxDecoration(
          color: dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark ? AppColors.nightBorder : AppColors.border.withValues(alpha: .62),
          ),
          boxShadow: dark
              ? const <BoxShadow>[]
              : const [
                  BoxShadow(
                    color: Color(0x0A442A34),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark
                    ? metric.accent.withValues(alpha: .14)
                    : metric.tint,
              ),
              child: Icon(
                metric.icon,
                size: 15,
                color: dark ? AppColors.nightPrimary : metric.accent,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 21,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  metric.value,
                  maxLines: 1,
                  style: TextStyle(
                    color: text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              metric.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: secondary,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactQuickAction extends StatelessWidget {
  const _CompactQuickAction({
    required this.label,
    required this.icon,
    required this.tint,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;

    return Column(
      children: [
        NumuwPressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? accent.withValues(alpha: .13) : tint,
            ),
            child: Icon(
              icon,
              size: 19,
              color: dark ? AppColors.nightPrimary : accent,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: text,
            fontSize: 9.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
