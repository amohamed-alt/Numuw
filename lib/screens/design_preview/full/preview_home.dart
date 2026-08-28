import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../widgets/numuw_classy_components.dart';
import '../../../widgets/numuw_motion_widgets.dart';
import 'preview_shared.dart';

class PreviewHomeScreen extends StatelessWidget {
  const PreviewHomeScreen({super.key, required this.black});
  final bool black;

  @override
  Widget build(BuildContext context) => PreviewScreenScaffold(
    black: black,
    showBack: true,
    bottom: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
      child: Theme(
        data: Theme.of(context),
        child: const NumuwBottomBarPreview(selectedIndex: 0),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً يا ماما',
                    style: TextStyle(
                      color: previewText(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'الجمعة 28 أغسطس · يوم هادئ مع ليان',
                    style: TextStyle(
                      color: previewSecondary(context),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: previewNoop, icon: const Icon(Icons.notifications_none_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        const NumuwFadeSlideIn(
          child: NumuwChildIdentity(name: 'ليان أحمد', age: '9 أشهر و12 يوم'),
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
          children: const [
            NumuwMetricTile(
              label: 'آخر رضعة',
              value: '12:30',
              icon: Icons.water_drop_outlined,
            ),
            NumuwMetricTile(
              label: 'نوم اليوم',
              value: '2 س 40 د',
              icon: Icons.dark_mode_outlined,
              tint: AppColors.lavenderSoft,
              accent: Color(0xFF8D7399),
            ),
            NumuwMetricTile(
              label: 'آخر حفاضة',
              value: '11:20',
              icon: Icons.baby_changing_station_outlined,
              tint: AppColors.powderSoft,
              accent: AppColors.info,
            ),
            NumuwMetricTile(
              label: 'التطعيم القادم',
              value: 'بعد 4 أيام',
              icon: Icons.vaccines_outlined,
              tint: AppColors.champagneSoft,
              accent: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 23),
        const NumuwSectionLabel(title: 'تسجيل سريع'),
        const SizedBox(height: 11),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              NumuwQuickAction(label: 'رضاعة', icon: Icons.water_drop_outlined, onTap: previewNoop),
              SizedBox(width: 7),
              NumuwQuickAction(label: 'شفط', icon: Icons.opacity_rounded, tint: AppColors.lavenderSoft, accent: Color(0xFF8D7399), onTap: previewNoop),
              SizedBox(width: 7),
              NumuwQuickAction(label: 'حفاضة', icon: Icons.baby_changing_station_outlined, tint: AppColors.powderSoft, accent: AppColors.info, onTap: previewNoop),
              SizedBox(width: 7),
              NumuwQuickAction(label: 'طعام', icon: Icons.restaurant_rounded, tint: AppColors.champagneSoft, accent: AppColors.warning, onTap: previewNoop),
              SizedBox(width: 7),
              NumuwQuickAction(label: 'دواء', icon: Icons.medication_outlined, tint: AppColors.peachLight, accent: AppColors.danger, onTap: previewNoop),
            ],
          ),
        ),
        const SizedBox(height: 23),
        PreviewSectionCard(
          title: 'اليوم مع ليان',
          action: TextButton(onPressed: previewNoop, child: const Text('عرض الكل')),
          child: const Column(
            children: [
              NumuwTimelineRow(title: 'رضاعة طبيعية', subtitle: '15 دقيقة · الجهة اليمنى', time: '12:30'),
              NumuwTimelineRow(title: 'حفاضة', subtitle: 'مبللة', time: '11:20', color: AppColors.info),
              NumuwTimelineRow(title: 'نوم', subtitle: 'ساعة و20 دقيقة', time: '10:10', color: Color(0xFF8D7399), isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: NumuwClassySurface(
                tinted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PreviewIcon(icon: Icons.lightbulb_outline_rounded, size: 40),
                    SizedBox(height: 8),
                    Text('نصيحة اليوم', style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('روتين بسيط قبل النوم يساعد على الانتقال بهدوء.', style: TextStyle(fontSize: 11.5, height: 1.45)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: NumuwClassySurface(
                tinted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PreviewIcon(icon: Icons.star_outline_rounded, color: AppColors.warning, background: AppColors.champagneSoft, size: 40),
                    SizedBox(height: 8),
                    Text('نشاط مناسب', style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('لعبة لمس الأقمشة · 5 دقائق', style: TextStyle(fontSize: 11.5, height: 1.45)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
