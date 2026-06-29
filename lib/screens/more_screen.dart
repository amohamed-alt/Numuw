import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _version = '';
  String? _message;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted)
        setState(() => _version = '${info.version}+${info.buildNumber}');
    });
  }

  Future<void> _exportReport() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    try {
      final bytes = await ReportService().buildDoctorReport(child);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'numuw-doctor-report.pdf',
      );
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      setState(() => _message = 'تعذر إنشاء التقرير: ${readableError(error)}');
    }
  }

  Future<void> _switchChild() async {
    final children = ChildSession.instance.children;
    if (children.length < 2) {
      setState(() => _message = 'لا يوجد أكثر من طفل للتبديل.');
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          title: const Text('اختاري الطفل'),
          children: children
              .map(
                (c) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, c.id),
                  child: Text(c.name),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected == null) return;
    ChildSession.instance.selectChild(
      children.firstWhere((c) => c.id == selected),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final email =
        Supabase.instance.client.auth.currentUser?.email ?? 'غير معروف';
    final child = ChildSession.instance.selectedChild;
    return Scaffold(
      body: AppPage(
        child: Column(
          children: [
            const AppHeader(
              title: 'المزيد',
              subtitle: 'الإعدادات والخدمات الإضافية',
            ),
            const SizedBox(height: 22),
            _Group(
              children: const [
                _Item(
                  icon: Icons.bedtime_outlined,
                  title: 'متابعة النوم',
                  color: AppColors.purple,
                ),
                _Item(
                  icon: Icons.baby_changing_station_outlined,
                  title: 'متابعة الحفاضات',
                  color: AppColors.blue,
                ),
                _Item(
                  icon: Icons.medication_outlined,
                  title: 'الأدوية والمكملات',
                  color: AppColors.peach,
                ),
                _Item(
                  icon: Icons.notifications_outlined,
                  title: 'التذكيرات والإشعارات',
                  color: AppColors.yellow,
                ),
                _Item(
                  icon: Icons.settings_outlined,
                  title: 'إعدادات التطبيق',
                  color: AppColors.mint,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Group(
              children: [
                _Item(
                  icon: Icons.email_outlined,
                  title: 'الحساب: $email',
                  color: AppColors.blue,
                ),
                _Item(
                  icon: Icons.child_care_rounded,
                  title: 'الطفل المحدد: ${child?.name ?? 'غير محدد'}',
                  color: AppColors.mint,
                  onTap: _switchChild,
                ),
                _Item(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'تقرير الطبيب PDF',
                  color: AppColors.purple,
                  onTap: _exportReport,
                ),
                const _Item(
                  icon: Icons.privacy_tip_outlined,
                  title:
                      'الخصوصية: تستخدم بياناتك داخل حسابك وفق صلاحيات Supabase RLS',
                  color: AppColors.yellow,
                ),
                _Item(
                  icon: Icons.info_outline_rounded,
                  title:
                      'إصدار التطبيق: ${_version.isEmpty ? '...' : _version}',
                  color: AppColors.blue,
                ),
                _Item(
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  color: AppColors.peach,
                  onTap: () async {
                    await AuthService().signOut();
                    ChildSession.instance.clear();
                  },
                ),
              ],
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              InfoBanner(message: _message!, icon: Icons.info_outline_rounded),
            ],
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<_Item> children;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1)
            const Divider(height: 1, color: AppColors.border),
        ],
      ],
    ),
  );
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsetsDirectional.fromSTEB(15, 6, 15, 6),
    leading: CircleAvatar(
      backgroundColor: color.withValues(alpha: .12),
      child: Icon(icon, color: color),
    ),
    title: Text(
      title,
      textAlign: TextAlign.start,
      style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4),
    ),
    trailing: const Icon(
      Icons.chevron_left_rounded,
      color: AppColors.mutedText,
    ),
    onTap: onTap,
  );
}
