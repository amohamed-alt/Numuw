import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/report_service.dart';
import '../../state/app_preferences.dart';
import '../../state/child_session.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/icons/numuw_icon.dart';
import '../../widgets/numuw_classy_components.dart';
import '../../widgets/numuw_motion_widgets.dart';
import '../family/family_screen.dart';
import '../weekly_share_screen.dart';

/// Classy production replacement for the legacy More/settings presentation.
/// Existing preferences, reminders, PDF generation, family sharing and auth
/// actions stay untouched.
class ClassyMoreScreen extends StatefulWidget {
  const ClassyMoreScreen({super.key});

  @override
  State<ClassyMoreScreen> createState() => _ClassyMoreScreenState();
}

class _ClassyMoreScreenState extends State<ClassyMoreScreen> {
  String _version = '';
  String? _message;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = '${info.version}+${info.buildNumber}');
    });
    AppPreferences.instance.addListener(_changed);
    ChildSession.instance.addListener(_changed);
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_changed);
    ChildSession.instance.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _text => _dark ? AppColors.nightText : AppColors.text;
  Color get _secondary => _dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
  Color get _accent => _dark ? AppColors.nightPrimaryStrong : AppColors.plum;

  Future<void> _exportReport() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      setState(() => _message = 'اختاري طفلًا أولًا لإنشاء التقرير.');
      return;
    }
    try {
      final bytes = await ReportService().buildDoctorReport(child);
      await Printing.sharePdf(bytes: bytes, filename: 'numuw-doctor-report.pdf');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _message = 'تعذر إنشاء التقرير: ${readableError(error)}');
    }
  }

  Future<void> _switchChild() async {
    final children = ChildSession.instance.children;
    if (children.length < 2) {
      setState(() => _message = 'لا يوجد أكثر من طفل للتبديل.');
      return;
    }
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('اختاري الطفل', textAlign: TextAlign.center, style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final child in children)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: NumuwClassySurface(
                  onTap: () => Navigator.pop(sheetContext, child.id),
                  padding: const EdgeInsetsDirectional.all(14),
                  child: Row(
                    children: [
                      NumuwIcon(NumuwIcons.child, size: 22, color: _accent),
                      const SizedBox(width: 10),
                      Expanded(child: Text(child.name, style: TextStyle(color: _text, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    ChildSession.instance.selectChild(children.firstWhere((child) => child.id == selected));
  }

  Future<void> _setReminder({required Future<void> Function(bool) setter, required bool value}) async {
    final child = ChildSession.instance.selectedChild;
    await setter(value);
    if (child == null) {
      if (mounted) setState(() => _message = 'اختاري طفلًا أولًا لتحديث التذكيرات.');
      return;
    }
    try {
      await NotificationService.instance.rescheduleForChild(child.id);
      if (mounted) setState(() => _message = 'تم تحديث إعدادات التذكيرات.');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _message = readableError(error));
    }
  }

  void _showInfo(String title, String message) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _ClassyInfoScreen(title: title, message: message)));
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'غير معروف';
    final child = ChildSession.instance.selectedChild;
    final prefs = AppPreferences.instance;

    return Scaffold(
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsHeader(childName: child?.name, email: email),
            const SizedBox(height: 18),
            _Group(
              title: 'أدوات المتابعة',
              children: [
                _SettingsTile(asset: NumuwIcons.sleep, title: 'متابعة النوم', subtitle: 'راجعي تسجيلات النوم اليومية', onTap: () => _showInfo('متابعة النوم', 'تظهر تسجيلات النوم الفعلية في صفحة التسجيل ولوحة اليوم.')),
                _SettingsTile(asset: NumuwIcons.diaper, title: 'متابعة الحفاضات', subtitle: 'سجل واضح للتغييرات اليومية', onTap: () => _showInfo('متابعة الحفاضات', 'استخدمي تبويب التسجيل لحفظ تغييرات الحفاضة ومراجعتها.')),
                _SettingsTile(asset: NumuwIcons.medicine, title: 'الأدوية والمكملات', subtitle: 'تنظيم تعليمات الطبيب المسجلة فقط', onTap: () => _showInfo('الأدوية والمكملات', 'يمكنك تسجيل الدواء والجرعة الموصوفة فقط دون أي توصية طبية.')),
                _SettingsTile(asset: NumuwIcons.weeklyReport, title: 'كارت الأسبوع', subtitle: 'ملخص قابل للمشاركة', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WeeklyShareScreen()))),
              ],
            ),
            const SizedBox(height: 14),
            _Group(
              title: 'التذكيرات',
              children: [
                _SettingsTile(
                  asset: NumuwIcons.feeding,
                  title: 'تذكير الرضعة القادمة',
                  trailing: _VectorSwitch(value: prefs.feedingRemindersEnabled, onChanged: (value) => _setReminder(setter: prefs.setFeedingReminders, value: value)),
                  onTap: () => _setReminder(setter: prefs.setFeedingReminders, value: !prefs.feedingRemindersEnabled),
                ),
                _SettingsTile(
                  asset: NumuwIcons.medicine,
                  title: 'تذكير الدواء المسجل',
                  trailing: _VectorSwitch(value: prefs.medicineRemindersEnabled, onChanged: (value) => _setReminder(setter: prefs.setMedicineReminders, value: value)),
                  onTap: () => _setReminder(setter: prefs.setMedicineReminders, value: !prefs.medicineRemindersEnabled),
                ),
                _SettingsTile(
                  asset: NumuwIcons.vaccination,
                  title: 'تذكير التطعيم القادم',
                  trailing: _VectorSwitch(value: prefs.vaccinationRemindersEnabled, onChanged: (value) => _setReminder(setter: prefs.setVaccinationReminders, value: value)),
                  onTap: () => _setReminder(setter: prefs.setVaccinationReminders, value: !prefs.vaccinationRemindersEnabled),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Group(
              title: 'التجربة',
              children: [
                _SettingsTile(
                  asset: NumuwIcons.moon,
                  title: 'وضع المساء الهادئ',
                  subtitle: prefs.nightMode ? 'مفعّل الآن' : 'الوضع الصباحي مفعّل',
                  trailing: _VectorSwitch(value: prefs.nightMode, onChanged: prefs.setNightMode),
                  onTap: prefs.toggleNightMode,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Group(
              title: 'الحساب والعائلة',
              children: [
                _SettingsTile(asset: NumuwIcons.email, title: 'الحساب', subtitle: email, onTap: () => _showInfo('الحساب', email)),
                _SettingsTile(asset: NumuwIcons.child, title: 'الطفل المحدد', subtitle: child?.name ?? 'غير محدد', onTap: _switchChild),
                _SettingsTile(asset: NumuwIcons.family, title: 'مشاركة العيلة', subtitle: 'الأدوار والصلاحيات والمساعدة', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FamilyScreen()))),
                _SettingsTile(asset: NumuwIcons.doctorReport, title: 'تقرير الطبيب PDF', subtitle: 'تجهيز ومشاركة ملخص منظم', onTap: _exportReport),
                _SettingsTile(asset: NumuwIcons.privacy, title: 'الخصوصية', subtitle: 'البيانات والصلاحيات', onTap: () => _showInfo('الخصوصية', 'بيانات طفلك لا تظهر إلا لكِ ولمن تسمحين له من مشاركة العيلة. مفاتيح الخدمة السرية لا توضع داخل التطبيق.')),
                _SettingsTile(asset: NumuwIcons.info, title: 'إصدار التطبيق', subtitle: _version.isEmpty ? '...' : _version, onTap: () => _showInfo('إصدار التطبيق', _version.isEmpty ? 'غير متاح' : _version)),
                _SettingsTile(
                  asset: NumuwIcons.logout,
                  title: 'تسجيل الخروج',
                  danger: true,
                  onTap: () async {
                    await AuthService().signOut();
                    ChildSession.instance.clear();
                  },
                ),
              ],
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              _MessageCard(message: _message!),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.childName, required this.email});
  final String? childName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .10)),
          child: NumuwIcon(NumuwIcons.settings, size: 26, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المزيد والإعدادات', style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(childName == null ? email : '$childName · $email', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 11.2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 3, bottom: 8),
          child: Text(title, style: TextStyle(color: secondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ),
        NumuwClassySurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) Divider(height: 1, color: border.withValues(alpha: .72)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.asset, required this.title, this.subtitle, this.onTap, this.trailing, this.danger = false});
  final String asset;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = danger ? AppColors.danger : (dark ? AppColors.nightPrimaryStrong : AppColors.plum);
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), color: accent.withValues(alpha: .09)),
              child: NumuwIcon(asset, size: 20, color: accent),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: danger ? AppColors.danger : text, fontSize: 13.2, fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 10.5, height: 1.35)),
                  ],
                ],
              ),
            ),
            trailing ?? NumuwIcon(NumuwIcons.back, size: 16, color: secondary),
          ],
        ),
      ),
    );
  }
}

class _VectorSwitch extends StatelessWidget {
  const _VectorSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 45,
          height: 27,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: value ? accent : border, borderRadius: BorderRadius.circular(15)),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment: value ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
            child: Container(width: 21, height: 21, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Container(
      padding: const EdgeInsetsDirectional.all(13),
      decoration: BoxDecoration(color: accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          NumuwIcon(NumuwIcons.info, size: 19, color: accent),
          const SizedBox(width: 9),
          Expanded(child: Text(message, style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _ClassyInfoScreen extends StatelessWidget {
  const _ClassyInfoScreen({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Scaffold(
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: NumuwPressable(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(width: 44, height: 44, child: Center(child: NumuwIcon(NumuwIcons.back, size: 20, color: text))),
                    ),
                  ),
                  Text(title, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NumuwClassySurface(
              child: Column(
                children: [
                  NumuwIcon(NumuwIcons.info, size: 30, color: accent),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.start, style: TextStyle(color: text, fontSize: 13, height: 1.7, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
