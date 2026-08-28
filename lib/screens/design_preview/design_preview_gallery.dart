import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/theme/numuw_theme.dart';
import '../../widgets/numuw_classy_components.dart';
import '../../widgets/numuw_motion_widgets.dart';

class DesignPreviewGallery extends StatelessWidget {
  const DesignPreviewGallery({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Design preview is debug-only.')),
      );
    }

    final previews = <_PreviewItem>[
      _PreviewItem(
        title: '01 · Brand foundations',
        subtitle: 'ألوان، خطوط، surfaces، Light + Black',
        icon: Icons.palette_outlined,
        builder: (_) => const _FoundationPreview(),
      ),
      _PreviewItem(
        title: '02 · Home — Classy motherhood',
        subtitle: 'التصور الرئيسي للـHome النهارية',
        icon: Icons.home_outlined,
        builder: (_) => const _HomePreview(),
      ),
      _PreviewItem(
        title: '03 · Home — Black edition',
        subtitle: 'نفس النظام في وضع الليل الحقيقي',
        icon: Icons.dark_mode_outlined,
        builder: (_) => const _HomePreview(black: true),
      ),
      _PreviewItem(
        title: '04 · Quick log',
        subtitle: 'أفعال يومية كبيرة ومريحة بيد واحدة',
        icon: Icons.add_circle_outline_rounded,
        builder: (_) => const _QuickLogPreview(),
      ),
      _PreviewItem(
        title: '05 · Component library',
        subtitle: 'Buttons, cards, chips, metrics, navigation',
        icon: Icons.widgets_outlined,
        builder: (_) => const _ComponentPreview(),
      ),
      _PreviewItem(
        title: '06 · Motion lab',
        subtitle: 'Press, entrance, pulse, success, numbers',
        icon: Icons.animation_rounded,
        builder: (_) => const _MotionPreview(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PreviewHeader(
                eyebrow: 'NUMUW DESIGN LAB',
                title: 'Classy Motherhood System',
                subtitle:
                    'هوية هادئة، أنثوية وناضجة — ليست طفولية ولا SaaS. كل العناصر قابلة لإعادة الاستخدام داخل Flutter.',
              ),
              const SizedBox(height: 24),
              ...previews.map(
                (item) => Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12),
                  child: _GalleryRow(item: item),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsetsDirectional.all(16),
                decoration: BoxDecoration(
                  color: AppColors.roseMist,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.plumSoft),
                ),
                child: const Text(
                  'Preview only: شغّلي التطبيق بـ --dart-define=DESIGN_PREVIEW=true. لا يتم لمس الـproduction routing.',
                  style: TextStyle(
                    color: AppColors.plumDark,
                    fontWeight: FontWeight.w700,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryRow extends StatelessWidget {
  const _GalleryRow({required this.item});
  final _PreviewItem item;

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
    onTap: () => Navigator.of(context).push(numuwPageRoute(item.builder)),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.roseMist,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(item.icon, color: AppColors.plum, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_left_rounded, color: AppColors.mutedText),
      ],
    ),
  );
}

class _PreviewItem {
  const _PreviewItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: AppColors.plum,
          fontSize: 11,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 29,
          fontWeight: FontWeight.w800,
          height: 1.18,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 13.5,
          height: 1.65,
        ),
      ),
    ],
  );
}

class _PreviewShell extends StatelessWidget {
  const _PreviewShell({
    required this.child,
    this.black = false,
    this.title,
  });

  final Widget child;
  final bool black;
  final String? title;

  @override
  Widget build(BuildContext context) => Theme(
    data: buildNumuwTheme(night: black),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: black ? AppColors.nightBackground : AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 36),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FoundationPreview extends StatelessWidget {
  const _FoundationPreview();

  @override
  Widget build(BuildContext context) => _PreviewShell(
    title: 'Brand foundations',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Light palette'),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Swatch('Rosewood', AppColors.plum),
            _Swatch('Blush', AppColors.blush),
            _Swatch('Champagne', AppColors.champagne),
            _Swatch('Sage', AppColors.sage),
            _Swatch('Lavender', AppColors.lavender),
            _Swatch('Powder', AppColors.powder),
          ],
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Typography'),
        const SizedBox(height: 12),
        const Text(
          'لحظة حب… تنمو بحكاية',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'وضوح قبل الزخرفة. خط عربي هادئ ومساحات تنفّس محسوبة للاستخدام المتكرر طوال اليوم.',
          style: TextStyle(fontSize: 14, height: 1.7),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Black edition'),
        const SizedBox(height: 12),
        Theme(
          data: buildNumuwTheme(night: true),
          child: Container(
            padding: const EdgeInsetsDirectional.all(18),
            decoration: BoxDecoration(
              color: AppColors.nightBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                NumuwClassyButton(
                  label: 'زر أساسي — Black',
                  onPressed: _noop,
                ),
                SizedBox(height: 10),
                NumuwClassyButton(
                  label: 'زر ثانوي — Black',
                  variant: NumuwButtonVariant.secondary,
                  onPressed: _noop,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _HomePreview extends StatelessWidget {
  const _HomePreview({this.black = false});
  final bool black;

  @override
  Widget build(BuildContext context) => _PreviewShell(
    black: black,
    title: black ? 'Home · Black' : 'Home · Light',
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
                      color: black ? AppColors.nightText : AppColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ليان · 9 أشهر و12 يوم',
                    style: TextStyle(
                      color: black
                          ? AppColors.nightSecondaryText
                          : AppColors.secondaryText,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: _noop, icon: const Icon(Icons.notifications_none_rounded)),
          ],
        ),
        const SizedBox(height: 18),
        const NumuwFadeSlideIn(
          child: NumuwChildIdentity(name: 'ليان أحمد', age: '9 أشهر و12 يوم'),
        ),
        const SizedBox(height: 22),
        const NumuwSectionLabel(
          title: 'نظرة سريعة لليوم',
          subtitle: 'الأهم فقط — بدون ازدحام',
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: const [
            NumuwMetricTile(
              label: 'رضعات',
              value: '5',
              icon: Icons.water_drop_outlined,
            ),
            NumuwMetricTile(
              label: 'حفاضات',
              value: '3',
              icon: Icons.baby_changing_station_outlined,
              tint: AppColors.powderSoft,
              accent: AppColors.info,
            ),
            NumuwMetricTile(
              label: 'نوم اليوم',
              value: '2 س 40 د',
              icon: Icons.dark_mode_outlined,
              tint: AppColors.lavenderSoft,
              accent: Color(0xFF8D7399),
            ),
            NumuwMetricTile(
              label: 'دواء',
              value: '1',
              icon: Icons.medication_outlined,
              tint: AppColors.peachLight,
              accent: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const NumuwSectionLabel(title: 'تسجيل سريع'),
        const SizedBox(height: 12),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              NumuwQuickAction(label: 'رضاعة', icon: Icons.water_drop_outlined, onTap: _noop),
              SizedBox(width: 7),
              NumuwQuickAction(
                label: 'شفط',
                icon: Icons.opacity_rounded,
                tint: AppColors.lavenderSoft,
                accent: Color(0xFF8D7399),
                onTap: _noop,
              ),
              SizedBox(width: 7),
              NumuwQuickAction(
                label: 'حفاضة',
                icon: Icons.baby_changing_station_outlined,
                tint: AppColors.powderSoft,
                accent: AppColors.info,
                onTap: _noop,
              ),
              SizedBox(width: 7),
              NumuwQuickAction(
                label: 'طعام',
                icon: Icons.restaurant_rounded,
                tint: AppColors.champagneSoft,
                accent: AppColors.warning,
                onTap: _noop,
              ),
              SizedBox(width: 7),
              NumuwQuickAction(
                label: 'حرارة',
                icon: Icons.thermostat_rounded,
                tint: AppColors.peachLight,
                accent: AppColors.danger,
                onTap: _noop,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const NumuwSectionLabel(
          title: 'آخر الأنشطة',
          actionLabel: 'عرض الكل',
          onAction: _noop,
        ),
        const SizedBox(height: 12),
        const NumuwClassySurface(
          child: Column(
            children: [
              NumuwTimelineRow(
                title: 'رضاعة طبيعية',
                subtitle: '15 دقيقة · الجهة اليمنى',
                time: '12:30',
              ),
              NumuwTimelineRow(
                title: 'حفاضة',
                subtitle: 'مبللة',
                time: '11:20',
                color: AppColors.info,
              ),
              NumuwTimelineRow(
                title: 'نوم',
                subtitle: 'ساعة و20 دقيقة',
                time: '10:10',
                color: Color(0xFF8D7399),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const NumuwBottomBarPreview(),
      ],
    ),
  );
}

class _QuickLogPreview extends StatefulWidget {
  const _QuickLogPreview();

  @override
  State<_QuickLogPreview> createState() => _QuickLogPreviewState();
}

class _QuickLogPreviewState extends State<_QuickLogPreview> {
  String _selected = 'feeding';

  @override
  Widget build(BuildContext context) => _PreviewShell(
    title: 'Quick log',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ماذا تريدين تسجيله؟',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        const Text('مصممة للتسجيل في ثوانٍ وبيد واحدة.'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 14,
          runSpacing: 18,
          children: [
            NumuwQuickAction(
              label: 'رضاعة',
              icon: Icons.water_drop_outlined,
              selected: _selected == 'feeding',
              onTap: () => setState(() => _selected = 'feeding'),
            ),
            NumuwQuickAction(
              label: 'نوم',
              icon: Icons.dark_mode_outlined,
              selected: _selected == 'sleep',
              tint: AppColors.lavenderSoft,
              accent: const Color(0xFF8D7399),
              onTap: () => setState(() => _selected = 'sleep'),
            ),
            NumuwQuickAction(
              label: 'حفاضة',
              icon: Icons.baby_changing_station_outlined,
              selected: _selected == 'diaper',
              tint: AppColors.powderSoft,
              accent: AppColors.info,
              onTap: () => setState(() => _selected = 'diaper'),
            ),
            NumuwQuickAction(
              label: 'دواء',
              icon: Icons.medication_outlined,
              selected: _selected == 'medicine',
              tint: AppColors.peachLight,
              accent: AppColors.danger,
              onTap: () => setState(() => _selected = 'medicine'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        NumuwSegmentedControl(
          value: _selected == 'sleep' ? 'timer' : 'manual',
          items: const {'manual': 'تسجيل الآن', 'timer': 'مؤقت'},
          onChanged: (_) {},
        ),
        const SizedBox(height: 14),
        const NumuwClassySurface(
          tinted: true,
          child: Row(
            children: [
              NumuwPulseDot(),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '00 : 18',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
              ),
              Text('دقيقة'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const NumuwClassyButton(label: 'حفظ التسجيل', onPressed: _noop),
      ],
    ),
  );
}

class _ComponentPreview extends StatelessWidget {
  const _ComponentPreview();

  @override
  Widget build(BuildContext context) => _PreviewShell(
    title: 'Component library',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Buttons · Light'),
        const SizedBox(height: 12),
        const NumuwClassyButton(label: 'زر أساسي', onPressed: _noop),
        const SizedBox(height: 9),
        const NumuwClassyButton(
          label: 'زر ثانوي',
          variant: NumuwButtonVariant.secondary,
          onPressed: _noop,
        ),
        const SizedBox(height: 9),
        const NumuwClassyButton(
          label: 'زر Tonal',
          variant: NumuwButtonVariant.tonal,
          onPressed: _noop,
        ),
        const SizedBox(height: 9),
        const NumuwClassyButton(
          label: 'زر Black',
          variant: NumuwButtonVariant.black,
          onPressed: _noop,
        ),
        const SizedBox(height: 26),
        const _SectionTitle('Surfaces & metrics'),
        const SizedBox(height: 12),
        const NumuwChildIdentity(name: 'ليان أحمد', age: '9 أشهر و12 يوم'),
        const SizedBox(height: 12),
        const SizedBox(
          height: 142,
          child: Row(
            children: [
              Expanded(
                child: NumuwMetricTile(
                  label: 'آخر رضعة',
                  value: '12:30',
                  icon: Icons.water_drop_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: NumuwMetricTile(
                  label: 'نوم اليوم',
                  value: '2 س 40 د',
                  icon: Icons.dark_mode_outlined,
                  tint: AppColors.lavenderSoft,
                  accent: Color(0xFF8D7399),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const _SectionTitle('Black variants'),
        const SizedBox(height: 12),
        Theme(
          data: buildNumuwTheme(night: true),
          child: Container(
            padding: const EdgeInsetsDirectional.all(18),
            decoration: BoxDecoration(
              color: AppColors.nightBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                NumuwClassyButton(label: 'زر أساسي', onPressed: _noop),
                SizedBox(height: 10),
                NumuwClassyButton(
                  label: 'زر ثانوي',
                  variant: NumuwButtonVariant.secondary,
                  onPressed: _noop,
                ),
                SizedBox(height: 14),
                NumuwChildIdentity(name: 'ليان أحمد', age: '9 أشهر و12 يوم'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MotionPreview extends StatefulWidget {
  const _MotionPreview();

  @override
  State<_MotionPreview> createState() => _MotionPreviewState();
}

class _MotionPreviewState extends State<_MotionPreview> {
  int _successKey = 0;
  double _value = 42;

  @override
  Widget build(BuildContext context) => _PreviewShell(
    title: 'Motion lab',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Entrance · 280ms'),
        const SizedBox(height: 12),
        const NumuwFadeSlideIn(
          child: NumuwClassySurface(
            child: Text('Fade + subtle slide. لا يوجد bounce مبالغ فيه.'),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Active timer · pulse'),
        const SizedBox(height: 12),
        const NumuwClassySurface(
          child: Row(
            children: [
              NumuwPulseDot(),
              SizedBox(width: 10),
              Text('جلسة رضاعة جارية الآن'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Animated data'),
        const SizedBox(height: 12),
        NumuwClassySurface(
          child: Row(
            children: [
              Expanded(
                child: NumuwAnimatedNumber(
                  value: _value,
                  builder: (context, value) => Text(
                    '${value.round()} مل',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _value = _value == 42 ? 120 : 42),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Success · 580ms'),
        const SizedBox(height: 12),
        Center(key: ValueKey(_successKey), child: const NumuwSuccessBloom()),
        const SizedBox(height: 12),
        NumuwClassyButton(
          label: 'إعادة حركة النجاح',
          variant: NumuwButtonVariant.tonal,
          onPressed: () => setState(() => _successKey++),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 94,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 94,
          height: 62,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

void _noop() {}
