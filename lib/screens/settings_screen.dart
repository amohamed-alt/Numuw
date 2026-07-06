import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../state/app_preferences.dart';
import '../state/country_preference.dart';
import '../widgets/app_widgets.dart';
import 'country_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    AppPreferences.instance.addListener(_refresh);
    CountryPreference.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AppPreferences.instance.removeListener(_refresh);
    CountryPreference.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferences.instance;
    final country = CountryPreference.instance.selectedCountry;
    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NumuwHeader(
              title: 'الإعدادات',
              subtitle: 'تحكّمي في تجربة نُمُوّ بما يناسب بيتكِ.',
            ),
            const SizedBox(height: 18),
            NumuwCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.public_rounded,
                    title: 'الدولة والمصادر الصحية',
                    subtitle: country == null
                        ? 'اختاري الدولة لعرض التطعيمات والمراجع المناسبة.'
                        : '${country.flagEmoji} ${country.arabicName} · ${country.sourceSummary}',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CountrySelectionScreen(),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: prefs.nightMode,
                    onChanged: (value) async => prefs.setNightMode(value),
                    title: Text(
                      'وضع الليل الهادئ',
                      style: TextStyle(
                        color: numuwTextColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      'ألوان أهدى للرضعات وتسجيلات الساعة 3 الفجر.',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NumuwCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_active_outlined,
                    title: 'التنبيهات',
                    subtitle: 'تذكيرات الرضاعة، الدواء، والتطعيمات.',
                    onTap: () {},
                  ),
                  const Divider(height: 24),
                  _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'الخصوصية والأمان',
                    subtitle: 'الحساب، حذف البيانات، وصلاحيات الأسرة.',
                    onTap: () {},
                  ),
                  const Divider(height: 24),
                  _SettingsRow(
                    icon: Icons.workspace_premium_outlined,
                    title: 'الاشتراك المميز',
                    subtitle: 'التقارير، الذكاء الاصطناعي، ومكتبة الوثائق.',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NumuwCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مصدر المحتوى الطبي',
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    country == null
                        ? 'اختيار الدولة مطلوب قبل عرض جداول التطعيمات المحلية. لا يتم عرض أي جرعة غير موثقة.'
                        : 'المصادر الحالية: ${country.sourceSummary}. تظهر التفاصيل داخل شاشة الدولة قبل الاعتماد.',
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.mint),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_left_rounded, color: numuwSecondaryTextColor()),
        ],
      ),
    );
  }
}
