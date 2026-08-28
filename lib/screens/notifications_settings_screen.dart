import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../services/notification_service.dart';
import '../state/app_preferences.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool saving = false;
  String? message;

  @override
  void initState() {
    super.initState();
    AppPreferences.instance.addListener(refresh);
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  Future<void> update(Future<void> Function() action) async {
    if (saving) return;
    setState(() {
      saving = true;
      message = null;
    });
    try {
      await action();
      final child = ChildSession.instance.selectedChild;
      if (child != null) {
        await NotificationService.instance.rescheduleForChild(child.id);
      }
      if (mounted) setState(() => message = 'تم حفظ إعدادات التنبيهات.');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => message = readableError(error));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferences.instance;
    final hasChild = ChildSession.instance.selectedChild != null;
    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('التنبيهات')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختاري التنبيهات المناسبة ليومك',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _Tile(
              icon: Icons.local_drink_outlined,
              color: AppColors.mint,
              title: 'تذكير الرضاعة',
              subtitle: 'حسب آخر مواعيد الرضاعة المسجلة.',
              value: prefs.feedingRemindersEnabled,
              enabled: hasChild && !saving,
              onChanged: (value) =>
                  update(() => prefs.setFeedingReminders(value)),
            ),
            const SizedBox(height: 12),
            _Tile(
              icon: Icons.medication_outlined,
              color: AppColors.peach,
              title: 'تذكير الأدوية',
              subtitle: 'بعد تسجيل الدواء وموعده.',
              value: prefs.medicineRemindersEnabled,
              enabled: hasChild && !saving,
              onChanged: (value) =>
                  update(() => prefs.setMedicineReminders(value)),
            ),
            const SizedBox(height: 12),
            _Tile(
              icon: Icons.vaccines_outlined,
              color: AppColors.blue,
              title: 'تذكير التطعيمات',
              subtitle: 'للموعد القادم المسجل للطفل.',
              value: prefs.vaccinationRemindersEnabled,
              enabled: hasChild && !saving,
              onChanged: (value) =>
                  update(() => prefs.setVaccinationReminders(value)),
            ),
            if (saving) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (message != null) ...[
              const SizedBox(height: 16),
              InfoBanner(message: message!, icon: Icons.info_outline_rounded),
            ],
            const SizedBox(height: 16),
            InfoBanner(
              message:
                  'قد يطلب الهاتف إذن الإشعارات أول مرة. يمكنك تغييره من إعدادات الهاتف.',
              color: AppColors.blue,
              background: AppColors.blueLight,
              icon: Icons.notifications_none_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SoftCard(
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      );
}
