import 'package:flutter/material.dart';

import '../content/health_sources.dart';
import '../core/app_colors.dart';
import '../state/app_preferences.dart';
import '../state/country_preference.dart';
import '../widgets/app_widgets.dart';
import 'account_security_screen.dart';
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
    final country = CountryPreference.instance.country;

    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NumuwHeader(
              title: 'الإعدادات',
              subtitle: 'خلّي نُمُوّ أهدى وأسهل بالشكل اللي يناسبكِ.',
            ),
            const SizedBox(height: 18),
            _AppearanceCard(prefs: prefs),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.public_rounded,
                    title: 'الدولة والمصادر الصحية',
                    subtitle:
                        '${country.flagEmoji} ${country.arabicName} · ${country.sourceSummary}',
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
                  _SettingsRow(
                    icon: Icons.notifications_active_outlined,
                    title: 'التنبيهات',
                    subtitle: 'تذكيرات الرضاعة، الدواء، والتطعيمات.',
                    onTap: () {},
                  ),
                  const Divider(height: 24),
                  _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'الخصوصية والأذونات',
                    subtitle: 'اعرفي بالضبط متى ولماذا نطلب أي إذن.',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountPolicyScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _SettingsRow(
                    icon: Icons.workspace_premium_outlined,
                    title: 'نُمُوّ Premium',
                    subtitle: 'التقارير، الأسرة، والمزايا الإضافية.',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مصدر المحتوى الصحي',
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المصادر الحالية: ${country.sourceSummary}. تظهر التفاصيل داخل شاشة الدولة، ولا يعرض نُمُوّ جرعات أو تشخيصات من عنده.',
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      height: 1.65,
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

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.prefs});

  final AppPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final options = const [
      ('system', 'تلقائي', Icons.brightness_auto_rounded),
      ('light', 'فاتح', Icons.light_mode_outlined),
      ('dark', 'داكن', Icons.dark_mode_outlined),
    ];

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: numuwAccentColor().withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.palette_outlined, color: numuwAccentColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المظهر',
                      style: TextStyle(
                        color: numuwTextColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'فاتح نهارًا، وقمر هادئ في الظلام.',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: options.map((option) {
              final selected = prefs.themePreference == option.$1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => prefs.setThemePreference(option.$1),
                    child: AnimatedContainer(
                      duration: NumuwMotion.fast,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? numuwAccentColor().withValues(alpha: .13)
                            : numuwPageColor(),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? numuwAccentColor().withValues(alpha: .45)
                              : numuwBorderColor(),
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            option.$3,
                            color: selected
                                ? numuwAccentColor()
                                : numuwSecondaryTextColor(),
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            option.$2,
                            style: TextStyle(
                              color: selected
                                  ? numuwTextColor()
                                  : numuwSecondaryTextColor(),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: numuwBorderColor()),
          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: prefs.nightLogging,
            onChanged: prefs.nightMode
                ? (value) => prefs.setNightLogging(value)
                : null,
            title: Text(
              'وضع التسجيل الليلي',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              prefs.nightMode
                  ? 'يخفض إضاءة شاشات الرضاعة والنوم والحفاضة أكثر.'
                  : 'يتاح عند استخدام الوضع الداكن.',
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: prefs.reducedMotion,
            onChanged: (value) => prefs.setReducedMotion(value),
            title: Text(
              'تقليل الحركة',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              'يقلل الانتقالات والحركات المساعدة لو بتضايقك.',
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ],
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
              color: numuwAccentColor().withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: numuwAccentColor()),
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
