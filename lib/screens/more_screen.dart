import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../design/numuw_motion_widgets.dart';
import '../design/numuw_organic_icons.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/report_service.dart';
import '../state/app_preferences.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';
import 'family/family_screen.dart';
import 'weekly_share_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _version = '';
  String? _message;
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
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

  void _prefsChanged() {
    if (mounted) setState(() {});
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
      if (mounted) {
        setState(() => _message = 'تعذر إنشاء التقرير: ${readableError(error)}');
      }
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
    if (selected == null || !mounted) return;
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
    if (!mounted) return;
    if (child == null) {
      setState(() => _message = 'اختاري طفلًا أولًا لتحديث التذكيرات.');
      return;
    }
    try {
      await NotificationService.instance.rescheduleForChild(child.id);
      if (mounted) {
        setState(() => _message = 'تم تحديث إعدادات التذكيرات.');
      }
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _message = readableError(error));
    }
  }

  Future<void> _deleteAccount() async {
    if (_deletingAccount) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Directionality(
        textDirection: TextDirection.rtl,
        child: ConfirmationDialog(
          title: 'حذف الحساب نهائيًا؟',
          message:
              'سيتم حذف حسابك وبياناتك المرتبطة به نهائيًا، بما فيها بيانات الأطفال والسجلات التي لا يشارك ملكيتها مستخدم آخر. لا يمكن التراجع عن هذه الخطوة.',
          confirmLabel: 'حذف الحساب نهائيًا',
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingAccount = true;
      _message = null;
    });

    try {
      await AuthService().deleteAccount();
      ChildSession.instance.clear();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) {
        setState(() {
          _message = 'تعذر حذف الحساب: ${readableError(error)}';
          _deletingAccount = false;
        });
      }
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
        child: NumuwEntrance(
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
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.sleep,
                    title: 'متابعة النوم',
                    onTap: () => _feature(
                      'متابعة النوم',
                      'تظهر تسجيلات النوم الفعلية في صفحة التسجيل ولوحة اليوم.',
                    ),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.diaper,
                    title: 'متابعة الحفاضات',
                    onTap: () => _feature(
                      'متابعة الحفاضات',
                      'استخدمي تبويب التسجيل لحفظ تغييرات الحفاضة ومراجعتها.',
                    ),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.medicine,
                    title: 'الأدوية والمكملات',
                    onTap: () => _feature(
                      'الأدوية والمكملات',
                      'يمكنك تسجيل الدواء والجرعة الموصوفة فقط دون أي توصية طبية.',
                    ),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.share,
                    title: 'كارت الأسبوع القابل للمشاركة',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WeeklyShareScreen(),
                      ),
                    ),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.bottle,
                    title: 'تذكير الرضعة القادمة',
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
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.medicine,
                    title: 'تذكير الدواء المسجل',
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
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.vaccine,
                    title: 'تذكير التطعيم القادم',
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
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.sleep,
                    title: 'وضع الليل الهادئ',
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
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.account,
                    title: 'الحساب: $email',
                    onTap: () => _feature('الحساب', email),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.newborn,
                    title: 'الطفل المحدد: ${child?.name ?? 'غير محدد'}',
                    onTap: _switchChild,
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.family,
                    title: 'مشاركة العيلة',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FamilyScreen(),
                      ),
                    ),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.documents,
                    title: 'تقرير الطبيب PDF',
                    onTap: _exportReport,
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.privacy,
                    title: 'الخصوصية',
                    onTap: () => _feature(
                      'الخصوصية',
                      'بيانات طفلك لا تظهر إلا لكِ ولمن تسمحين له من مشاركة العيلة. يمكنك إدارة أفراد العيلة وصلاحيات الوصول من شاشة مشاركة العيلة، ولا نضع مفاتيح سرية داخل التطبيق.',
                    ),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.help,
                    title:
                        'إصدار التطبيق: ${_version.isEmpty ? '...' : _version}',
                    onTap: () => _feature(
                      'إصدار التطبيق',
                      _version.isEmpty ? 'غير متاح' : _version,
                    ),
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.cancel,
                    title: 'تسجيل الخروج',
                    onTap: () async {
                      await AuthService().signOut();
                      ChildSession.instance.clear();
                    },
                  ),
                  _OrganicSettingsRow(
                    icon: NumuwOrganicIconName.delete,
                    title: _deletingAccount
                        ? 'جارٍ حذف الحساب...'
                        : 'حذف الحساب نهائيًا',
                    danger: true,
                    trailing: _deletingAccount
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : null,
                    onTap: _deletingAccount ? null : _deleteAccount,
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
      ),
    );
  }
}

class _OrganicSettingsRow extends StatelessWidget {
  const _OrganicSettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.danger = false,
  });

  final NumuwOrganicIconName icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final textColor = danger ? AppColors.danger : numuwTextColor();
    return NumuwPressable(
      onTap: onTap,
      semanticLabel: title,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          children: [
            NumuwOrganicIcon(icon, size: 34, semanticLabel: title),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_left_rounded,
                color: danger ? AppColors.danger : numuwSecondaryTextColor(),
                size: 18,
              ),
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
      child: NumuwEntrance(
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
    ),
  );
}
