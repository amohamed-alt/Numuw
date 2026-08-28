import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../icons/numuw_icon.dart';
import '../numuw_classy_components.dart';
import '../numuw_motion_widgets.dart';
import 'classy_home_view.dart';

/// Production home composition locked to the approved Numuw reference board.
/// Business data still comes from [ClassyHomeViewData]; only presentation lives
/// here so Preview and Production can share the same visual source of truth.
class NumuwReferenceHomeView extends StatelessWidget {
  const NumuwReferenceHomeView({
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
    this.onTemperature,
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
  final VoidCallback? onTemperature;

  bool _dark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  Color _text(BuildContext context) => _dark(context) ? AppColors.nightText : AppColors.text;
  Color _secondary(BuildContext context) => _dark(context) ? AppColors.nightSecondaryText : AppColors.secondaryText;
  Color _border(BuildContext context) => _dark(context) ? AppColors.nightBorder : AppColors.border;
  Color _raised(BuildContext context) => _dark(context) ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised;

  @override
  Widget build(BuildContext context) {
    final metrics = data.resolvedMetrics.take(4).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReferenceTopBar(
          onRefresh: onRefresh,
          onChildTap: onChildTap,
          foreground: _text(context),
        ),
        const SizedBox(height: 2),
        NumuwFadeSlideIn(
          child: _ReferenceChildHero(
            name: data.childName,
            age: data.childAge,
            imageProvider: data.childImageProvider,
            onTap: onChildTap,
          ),
        ),
        const SizedBox(height: 15),
        NumuwClassySurface(
          radius: 21,
          padding: const EdgeInsetsDirectional.fromSTEB(12, 14, 12, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'نظرة سريعة لليوم',
                textAlign: TextAlign.center,
                style: TextStyle(color: _text(context), fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: _secondary(context), fontSize: 10, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    Expanded(
                      child: _ReferenceMetric(
                        metric: metrics[i],
                        asset: _metricAsset(metrics[i], i),
                        onTap: switch (i) {
                          0 => onFeeding,
                          1 => onDiaper,
                          2 => onSleep,
                          _ => onVaccinationTap,
                        },
                      ),
                    ),
                    if (i != metrics.length - 1) const SizedBox(width: 7),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text('تسجيل سريع', style: TextStyle(color: _text(context), fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: _ReferenceQuickAction(label: 'رضاعة', asset: NumuwIcons.feeding, tint: AppColors.roseMist, accent: AppColors.plum, onTap: onFeeding)),
                  Expanded(child: _ReferenceQuickAction(label: 'شفط', asset: NumuwIcons.pumping, tint: AppColors.lavenderSoft, accent: const Color(0xFF8D7399), onTap: onPumping)),
                  Expanded(child: _ReferenceQuickAction(label: 'طعام', asset: NumuwIcons.food, tint: AppColors.champagneSoft, accent: AppColors.warning, onTap: onFood)),
                  Expanded(child: _ReferenceQuickAction(label: 'دواء', asset: NumuwIcons.medicine, tint: AppColors.powderSoft, accent: AppColors.info, onTap: onMedicine)),
                  Expanded(child: _ReferenceQuickAction(label: 'حرارة', asset: NumuwIcons.temperature, tint: AppColors.blushSoft, accent: AppColors.danger, onTap: onTemperature ?? onMedicine)),
                  Expanded(child: _ReferenceQuickAction(label: 'المزيد', asset: NumuwIcons.more, tint: _raised(context), accent: _secondary(context), onTap: onViewAll)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        NumuwClassySurface(
          radius: 20,
          padding: const EdgeInsetsDirectional.fromSTEB(15, 14, 15, 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('آخر الأنشطة', style: TextStyle(color: _text(context), fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (data.timeline.isEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 18),
                  child: Column(
                    children: [
                      NumuwIcon(NumuwIcons.logoMark, size: 27, color: _secondary(context)),
                      const SizedBox(height: 8),
                      Text('أول تسجيل اليوم هيظهر هنا', style: TextStyle(color: _secondary(context), fontSize: 11, fontWeight: FontWeight.w600)),
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
              Divider(height: 1, color: _border(context).withValues(alpha: .68)),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: _dark(context) ? AppColors.nightPrimaryStrong : AppColors.plum,
                  textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
                child: const Text('عرض كل الأنشطة'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  String _metricAsset(ClassyHomeMetric metric, int index) {
    final label = metric.label;
    if (label.contains('دواء') || label.contains('أدوية')) return NumuwIcons.temperature;
    if (label.contains('تطعيم')) return NumuwIcons.vaccination;
    return switch (index) {
      0 => NumuwIcons.feeding,
      1 => NumuwIcons.diaper,
      2 => NumuwIcons.sleep,
      _ => NumuwIcons.vaccination,
    };
  }
}

class _ReferenceTopBar extends StatelessWidget {
  const _ReferenceTopBar({required this.onRefresh, required this.onChildTap, required this.foreground});
  final VoidCallback? onRefresh;
  final VoidCallback? onChildTap;
  final Color foreground;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _ReferenceUtility(asset: NumuwIcons.bell, color: foreground),
            _ReferenceUtility(asset: NumuwIcons.calendar, color: foreground),
          ],
        ),
        Row(
          children: [
            _ReferenceUtility(asset: NumuwIcons.profile, color: foreground, onTap: onChildTap),
            _ReferenceUtility(asset: NumuwIcons.history, color: foreground, onTap: onRefresh),
          ],
        ),
      ],
    ),
  );
}

class _ReferenceUtility extends StatelessWidget {
  const _ReferenceUtility({required this.asset, required this.color, this.onTap});
  final String asset;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: SizedBox(
      width: 39,
      height: 39,
      child: Center(child: NumuwIcon(asset, size: 19, color: color)),
    ),
  );
}

class _ReferenceChildHero extends StatelessWidget {
  const _ReferenceChildHero({required this.name, required this.age, required this.imageProvider, required this.onTap});
  final String name;
  final String age;
  final ImageProvider? imageProvider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(58),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? AppColors.nightSurfaceRaised : AppColors.surface,
              boxShadow: dark ? const [] : const [BoxShadow(color: Color(0x14442A34), blurRadius: 22, offset: Offset(0, 8))],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? AppColors.nightPrimarySoft : AppColors.blushSoft,
                image: imageProvider == null ? null : DecorationImage(image: imageProvider!, fit: BoxFit.cover),
              ),
              alignment: Alignment.center,
              child: imageProvider == null
                  ? NumuwIcon(NumuwIcons.logoMark, size: 47, color: dark ? AppColors.nightPrimary : AppColors.plum)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 16.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(age, textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 11.3, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ReferenceMetric extends StatelessWidget {
  const _ReferenceMetric({required this.metric, required this.asset, required this.onTap});
  final ClassyHomeMetric metric;
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 88,
        padding: const EdgeInsetsDirectional.fromSTEB(5, 9, 5, 7),
        decoration: BoxDecoration(
          color: dark ? AppColors.nightSurfaceSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: border.withValues(alpha: .74)),
          boxShadow: dark ? const [] : const [BoxShadow(color: Color(0x0A442A34), blurRadius: 14, offset: Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumuwIcon(asset, size: 22, color: dark ? AppColors.nightPrimary : metric.accent),
            const SizedBox(height: 4),
            Text(metric.value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800, height: 1.05)),
            const SizedBox(height: 3),
            Text(metric.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 9.6, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ReferenceQuickAction extends StatelessWidget {
  const _ReferenceQuickAction({required this.label, required this.asset, required this.tint, required this.accent, required this.onTap});
  final String label;
  final String asset;
  final Color tint;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? accent.withValues(alpha: .13) : tint,
            ),
            alignment: Alignment.center,
            child: NumuwIcon(asset, size: 20, color: dark ? AppColors.nightPrimary : accent),
          ),
          const SizedBox(height: 6),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 9.4, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
