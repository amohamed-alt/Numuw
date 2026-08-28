import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../state/app_preferences.dart';
import '../widgets/app_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    AppPreferences.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferences.instance;
    final enabledCount = [
      prefs.feedingRemindersEnabled,
      prefs.medicineRemindersEnabled,
      prefs.vaccinationRemindersEnabled,
    ].where((enabled) => enabled).length;

    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('التنبيهات')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'تنبيهات هادئة ومفيدة',
              subtitle: 'اختاري ما تحتاجينه فقط حتى لا يتحول التطبيق إلى مصدر إزعاج.',
              showNotification: false,
              trailing: IconBadge(
                icon: '🔔',
                background: AppColors.blue.withValues(alpha: .13),
              ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              color: enabledCount == 0
                  ? (numuwNightMode() ? AppColors.nightSurfaceSoft : AppColors.neutralSoft)
                  : numuwAccentColor().withValues(alpha: .10),
              borderColor: enabledCount == 0 ? numuwBorderColor() : numuwAccentColor().withValues(alpha: .22),
              child: Row(
                children: [
                  IconBadge(
                    icon: enabledCount == 0 ? '🌙' : '✓',
                    background: numuwAccentColor().withValues(alpha: .14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      enabledCount == 0
                          ? 'كل التنبيهات متوقفة حاليًا. يمكنك تشغيل ما يناسب روتينك.'
                          : 'مفعّل $enabledCount من 3 أنواع تنبيهات.',
                      style: TextStyle(color: numuwTextColor(), height: 1.55, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionTitle(title: 'أنواع التنبيهات', icon: Icons.notifications_active_outlined),
            const SizedBox(height: 12),
            _ReminderSwitch(
              icon: Icons.baby_changing_station_rounded,
              color: AppColors.blue,
              title: 'تذكير الرضاعة',
              subtitle: 'يساعدك على متابعة الرضعات بدون حسابات كثيرة.',
              value: prefs.feedingRemindersEnabled,
              onChanged: prefs.setFeedingReminders,
            ),
            const SizedBox(height: 12),
            _ReminderSwitch(
              icon: Icons.medication_outlined,
              color: AppColors.peach,
              title: 'تذكير الدواء',
              subtitle: 'للمواعيد التي تضيفينها بنفسك داخل الروتين.',
              value: prefs.medicineRemindersEnabled,
              onChanged: prefs.setMedicineReminders,
            ),
            const SizedBox(height: 12),
            _ReminderSwitch(
              icon: Icons.vaccines_outlined,
              color: AppColors.success,
              title: 'تذكير التطعيمات',
              subtitle: 'تنبيه لطيف قبل المواعيد المهمة للطفل.',
              value: prefs.vaccinationRemindersEnabled,
              onChanged: prefs.setVaccinationReminders,
            ),
            const SizedBox(height: 18),
            InfoBanner(
              message: 'سيتم حفظ اختياراتك على الجهاز. ربط جدولة الإشعارات المحلية يتم فوق هذه التفضيلات بدون تغيير البيانات.',
              color: AppColors.blue,
              background: AppColors.blueLight,
              icon: Icons.privacy_tip_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderSwitch extends StatelessWidget {
  const _ReminderSwitch({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SoftCard(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 12, 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: numuwTextColor(), fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5, height: 1.5)),
                ],
              ),
            ),
            Switch.adaptive(value: value, onChanged: onChanged),
          ],
        ),
      );
}
