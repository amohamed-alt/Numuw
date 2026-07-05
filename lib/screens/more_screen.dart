import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../state/app_preferences.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import 'family/family_screen.dart';
import 'weekly_share_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String? message;

  @override
  void initState() {
    super.initState();
    AppPreferences.instance.addListener(_refresh);
    ChildSession.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_refresh);
    ChildSession.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _report() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      setState(() => message = 'اختاري طفلًا أولًا لإنشاء التقرير.');
      return;
    }
    try {
      final bytes = await ReportService().buildDoctorReport(child);
      await Printing.sharePdf(bytes: bytes, filename: 'numuw-doctor-report.pdf');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => message = readableError(error));
    }
  }

  Future<void> _switchChild() async {
    final children = ChildSession.instance.children;
    if (children.length < 2) {
      setState(() => message = 'لا يوجد أكثر من طفل للتبديل.');
      return;
    }
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اختاري الطفل', style: TextStyle(color: numuwTextColor(), fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                ...children.map((child) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Text('👶')),
                      title: Text(child.name),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => Navigator.pop(context, child.id),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
    if (id == null) return;
    ChildSession.instance.selectChild(children.firstWhere((item) => item.id == id));
  }

  void _info(String title, String text) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _InfoScreen(title: title, text: text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final child = ChildSession.instance.selectedChild;
    final name = user?.userMetadata?['full_name']?.toString().trim();
    final displayName = name == null || name.isEmpty ? 'ماما' : name;
    final email = user?.email ?? 'الحساب';

    final items = <_Item>[
      _Item(Icons.workspace_premium_outlined, 'نُمُوّ Premium', 'افتحي كل الميزات', AppColors.mint,
          () => _info('نُمُوّ Premium', 'التقارير المتقدمة والمشاركة العائلية والميزات الإضافية.')),
      _Item(Icons.favorite_border_rounded, 'صحّتك أنتِ', 'العناية بالأم', AppColors.peach,
          () => _info('صحّتك أنتِ', 'مساحة هادئة لمتابعة راحتك واحتياجاتك اليومية.')),
      _Item(Icons.pregnant_woman_rounded, 'وضع الحمل', 'التجهيز لاستقبال طفلك', AppColors.blue,
          () => _info('وضع الحمل', 'قوائم التجهيز وخطة أول أسبوع بعد الولادة.')),
      _Item(Icons.family_restroom_rounded, 'مشاركة الأسرة', 'الأب ومقدمو الرعاية', AppColors.success,
          () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FamilyScreen()))),
      _Item(Icons.restaurant_menu_rounded, 'الطعام بعد 6 شهور', 'الوجبات والأطعمة', AppColors.mint,
          () => _info('الطعام بعد 6 شهور', 'سجّلي الأطعمة والوجبات وردود الفعل من تبويب التسجيل.')),
      _Item(Icons.notifications_none_rounded, 'التنبيهات', 'إدارة الإشعارات', AppColors.blue,
          () => _info('التنبيهات', 'إعدادات التذكير متاحة من مفاتيح التنبيهات داخل التطبيق.')),
      _Item(Icons.palette_outlined, 'المظهر والإعدادات', AppPreferences.instance.nightMode ? 'الوضع الليلي' : 'الوضع النهاري', AppColors.mint,
          AppPreferences.instance.toggleNightMode),
      _Item(Icons.child_care_rounded, 'الطفل المحدد', child?.name ?? 'لم يتم اختيار طفل', AppColors.blue, _switchChild),
      _Item(Icons.picture_as_pdf_outlined, 'تقرير الطبيب', 'إنشاء ومشاركة PDF', AppColors.purple, _report),
      _Item(Icons.ios_share_rounded, 'كارت الأسبوع', 'قابل للمشاركة', AppColors.success,
          () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WeeklyShareScreen()))),
      _Item(Icons.logout_rounded, 'تسجيل الخروج', 'الخروج من الحساب الحالي', AppColors.danger, () async {
        await AuthService().signOut();
        ChildSession.instance.clear();
      }),
    ];

    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المزيد', style: TextStyle(color: numuwTextColor(), fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            _Profile(name: displayName, email: email),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12),
                  child: _MoreTile(item: item),
                )),
            if (message != null) InfoBanner(message: message!, icon: Icons.info_outline_rounded),
          ],
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.name, required this.email});
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.all(16),
        decoration: BoxDecoration(color: numuwSurfaceColor(), borderRadius: BorderRadius.circular(22), border: Border.all(color: numuwBorderColor())),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: numuwAccentColor().withValues(alpha: .14), shape: BoxShape.circle),
            child: Text(name.characters.first, style: TextStyle(color: numuwAccentColor(), fontSize: 22, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(color: numuwTextColor(), fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(email, overflow: TextOverflow.ellipsis, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5)),
          ])),
          Icon(Icons.settings_outlined, color: numuwSecondaryTextColor()),
        ]),
      );
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.item});
  final _Item item;

  @override
  Widget build(BuildContext context) => Material(
        color: numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: numuwBorderColor())),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: item.color.withValues(alpha: .13), borderRadius: BorderRadius.circular(16)),
                child: Icon(item.icon, color: item.color, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: TextStyle(color: numuwTextColor(), fontSize: 16.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(item.subtitle, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5)),
              ])),
              Icon(Icons.chevron_left_rounded, color: numuwSecondaryTextColor()),
            ]),
          ),
        ),
      );
}

class _Item {
  const _Item(this.icon, this.title, this.subtitle, this.color, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

class _InfoScreen extends StatelessWidget {
  const _InfoScreen({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: numuwPageColor(),
        appBar: AppBar(title: Text(title)),
        body: AppPage(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: numuwAccentColor().withValues(alpha: .14), borderRadius: BorderRadius.circular(24)),
              child: Icon(Icons.nightlight_round, color: numuwAccentColor(), size: 34),
            ),
            const SizedBox(height: 18),
            Text(text, style: TextStyle(color: numuwTextColor(), fontSize: 16, height: 1.75, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}
