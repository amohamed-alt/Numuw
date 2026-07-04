import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/report_service.dart';
import 'family/family_screen.dart';
import 'weekly_share_screen.dart';
import '../state/app_preferences.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';

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
    ChildSession.instance.addListener(_prefsChanged);
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_prefsChanged);
    ChildSession.instance.removeListener(_prefsChanged);
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

  Future<void> _setReminder({
    required Future<void> Function(bool value) setter,
    required bool value,
  }) async {
    final child = ChildSession.instance.selectedChild;
    await setter(value);
    if (child == null) {
      setState(() => _message = 'اختاري طفلًا أولًا لتحديث التذكيرات.');
      return;
    }
    try {
      await NotificationService.instance.rescheduleForChild(child.id);
      setState(() => _message = 'تم تحديث إعدادات التذكيرات.');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      setState(() => _message = readableError(error));
    }
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
            NumuwAppBar(
              title: 'المزيد',
              subtitle: 'الإعدادات والخدمات الإضافية',
              trailing: const NumuwStatusBadge(
                label: 'إعدادات',
                color: AppColors.mint,
              ),
            ),
            const SizedBox(height: 14),
            NumuwPlantProgress(
              progress: child == null ? .24 : .56,
              label: child == null ? 'اختاري طفلاً' : 'التجربة مكتملة جزئياً',
            ),
            const SizedBox(height: 14),
            if (child != null) ...[
              NumuwBabyHeader(name: child.name, subtitle: 'الحساب: $email'),
              const SizedBox(height: 16),
            ] else ...[
              NumuwCard(
                child: Text(
                  'الحساب: $email',
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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
                  icon: Icons.ios_share_rounded,
                  title: 'كارت الأسبوع القابل للمشاركة',
                  color: AppColors.mint,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WeeklyShareScreen(),
                    ),
                  ),
                ),
                SettingsRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'تذكير الرضعة القادمة',
                  color: AppColors.yellow,
                  trailing: NumuwSwitch(
                    value: AppPreferences.instance.feedingRemindersEnabled,
                    onChanged: (value) => _setReminder(
                      setter: AppPreferences.instance.setFeedingReminders,
                      value: value,
                    ),
                  ),
                  onTap: () => _setReminder(
                    setter: AppPreferences.instance.setFeedingReminders,
                    value: !AppPreferences.instance.feedingRemindersEnabled,
                  ),
                ),
                SettingsRow(
                  icon: Icons.medication_liquid_outlined,
                  title: 'تذكير الدواء المسجل',
                  color: AppColors.peach,
                  trailing: NumuwSwitch(
                    value: AppPreferences.instance.medicineRemindersEnabled,
                    onChanged: (value) => _setReminder(
                      setter: AppPreferences.instance.setMedicineReminders,
                      value: value,
                    ),
                  ),
                  onTap: () => _setReminder(
                    setter: AppPreferences.instance.setMedicineReminders,
                    value: !AppPreferences.instance.medicineRemindersEnabled,
                  ),
                ),
                SettingsRow(
                  icon: Icons.vaccines_outlined,
                  title: 'تذكير التطعيم القادم',
                  color: AppColors.blue,
                  trailing: NumuwSwitch(
                    value: AppPreferences.instance.vaccinationRemindersEnabled,
                    onChanged: (value) => _setReminder(
                      setter: AppPreferences.instance.setVaccinationReminders,
                      value: value,
                    ),
                  ),
                  onTap: () => _setReminder(
                    setter: AppPreferences.instance.setVaccinationReminders,
                    value: !AppPreferences.instance.vaccinationRemindersEnabled,
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
                  icon: Icons.family_restroom_rounded,
                  title: 'مشاركة العيلة',
                  color: AppColors.mint,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FamilyScreen(),
                    ),
                  ),
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
                    'بيانات طفلك لا تظهر إلا لكِ ولمن تسمحين له من مشاركة العيلة. يمكنك إدارة أفراد العيلة وصلاحيات الوصول من شاشة مشاركة العيلة، ولا نضع مفاتيح سرية داخل التطبيق.',
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
          NumuwAppBar(
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
          const SizedBox(height: 14),
          NumuwCard(
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
