import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../state/app_preferences.dart';
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
    AppPreferences.instance.addListener(_prefsChanged);
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_prefsChanged);
    super.dispose();
  }

  void _prefsChanged() => setState(() {});

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

  void _feature(String title, String message) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FeatureInfoScreen(title: title, message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email =
        Supabase.instance.client.auth.currentUser?.email ?? 'غير معروف';
    final child = ChildSession.instance.selectedChild;
    final night = AppPreferences.instance.nightMode;
    return Scaffold(
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'المزيد ⚙️',
              subtitle: 'الإعدادات والخدمات الإضافية',
              showNotification: false,
            ),
            const SizedBox(height: 22),
            const _GroupLabel('أدوات المتابعة'),
            const SizedBox(height: 9),
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: Icons.bedtime_outlined,
                  title: 'متابعة النوم',
                  color: AppColors.purple,
                  onTap: () => _feature(
                    'متابعة النوم',
                    'تظهر تسجيلات النوم الفعلية في صفحة التسجيل ولوحة اليوم.',
                  ),
                ),
                SettingsRow(
                  icon: Icons.baby_changing_station_outlined,
                  title: 'متابعة الحفاضات',
                  color: AppColors.blue,
                  onTap: () => _feature(
                    'متابعة الحفاضات',
                    'استخدمي تبويب التسجيل لحفظ تغييرات الحفاضة ومراجعتها.',
                  ),
                ),
                SettingsRow(
                  icon: Icons.medication_outlined,
                  title: 'الأدوية والمكملات',
                  color: AppColors.peach,
                  onTap: () => _feature(
                    'الأدوية والمكملات',
                    'يمكنك تسجيل الدواء والجرعة الموصوفة فقط دون أي توصية طبية.',
                  ),
                ),
                SettingsRow(
                  icon: Icons.notifications_outlined,
                  title: 'التذكيرات والإشعارات',
                  color: AppColors.yellow,
                  onTap: () => _feature(
                    'التذكيرات',
                    'سيتم تفعيل تذكيرات متقدمة لاحقًا. حاليًا يمكنك متابعة المهام من ملف الطفل.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _GroupLabel('التجربة'),
            const SizedBox(height: 9),
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: Icons.nightlight_round,
                  title: 'وضع الليل الهادئ',
                  color: AppColors.nightGold,
                  trailing: NumuwSwitch(
                    value: night,
                    onChanged: (_) => AppPreferences.instance.toggleNightMode(),
                  ),
                  onTap: AppPreferences.instance.toggleNightMode,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _GroupLabel('الحساب والطفل'),
            const SizedBox(height: 9),
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: Icons.email_outlined,
                  title: 'الحساب: $email',
                  color: AppColors.blue,
                  onTap: () => _feature('الحساب', email),
                ),
                SettingsRow(
                  icon: Icons.child_care_rounded,
                  title: 'الطفل المحدد: ${child?.name ?? 'غير محدد'}',
                  color: AppColors.mint,
                  onTap: _switchChild,
                ),
                SettingsRow(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'تقرير الطبيب PDF',
                  color: AppColors.purple,
                  onTap: _exportReport,
                ),
                SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'الخصوصية',
                  color: AppColors.yellow,
                  onTap: () => _feature(
                    'الخصوصية',
                    'تُستخدم بياناتك داخل حسابك فقط وفق صلاحيات الوصول الآمنة. لا نضع مفاتيح سرية داخل التطبيق.',
                  ),
                ),
                SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title:
                      'إصدار التطبيق: ${_version.isEmpty ? '...' : _version}',
                  color: AppColors.blue,
                  onTap: () => _feature(
                    'إصدار التطبيق',
                    _version.isEmpty ? 'غير متاح' : _version,
                  ),
                ),
                SettingsRow(
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

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: numuwSecondaryTextColor(),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: .5,
      ),
    ),
  );
}

class _FeatureInfoScreen extends StatelessWidget {
  const _FeatureInfoScreen({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwHeader(
            title: title,
            subtitle: 'معلومات آمنة داخل التطبيق',
            leading: AppIconButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.pop(context),
              badge: false,
              size: 42,
              radius: 13,
              iconSize: 20,
              borderWidth: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          SoftCard(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: numuwTextColor(),
                height: 1.7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
