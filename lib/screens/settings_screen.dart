import 'package:flutter/material.dart';

import '../content/health_sources.dart';
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
    CountryPreference.instance.load();
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
    final night = prefs.nightMode;

    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('الإعدادات')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Title('الدولة والمحتوى المحلي'),
            const SizedBox(height: 12),
            SoftCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CountrySelectionScreen(),
                ),
              ),
              child: Row(
                children: [
                  _IconBox(icon: Icons.public_rounded, color: AppColors.blue),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.arabicName,
                          style: TextStyle(
                            color: numuwTextColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'تُستخدم لمصادر التطعيمات والمحتوى الصحي المحلي',
                          style: TextStyle(
                            color: numuwSecondaryTextColor(),
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: numuwSecondaryTextColor(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Title('المظهر'),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsetsDirectional.all(8),
              child: Column(
                children: [
                  _ThemeOption(
                    icon: Icons.smartphone_rounded,
                    title: 'حسب إعداد الجهاز',
                    description:
                        'يتبع مظهر هاتفك تلقائيًا · حاليًا ${night ? 'الوضع الليلي' : 'الوضع النهاري'}',
                    selected: prefs.themePreference == 'system',
                    onTap: () => prefs.setThemePreference('system'),
                  ),
                  Divider(height: 1, color: numuwBorderColor()),
                  _ThemeOption(
                    icon: Icons.light_mode_outlined,
                    title: 'الوضع النهاري',
                    description: 'مناسب للقراءة والتقارير والنماذج',
                    selected: prefs.themePreference == 'light',
                    onTap: () => prefs.setThemePreference('light'),
                  ),
                  Divider(height: 1, color: numuwBorderColor()),
                  _ThemeOption(
                    icon: Icons.dark_mode_outlined,
                    title: 'الوضع الليلي',
                    description: 'قمر الليل — مريح أثناء الرضاعة ليلًا',
                    selected: prefs.themePreference == 'dark',
                    onTap: () => prefs.setThemePreference('dark'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Title('الراحة وإمكانية الوصول'),
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                children: [
                  _ToggleRow(
                    icon: Icons.nights_stay_outlined,
                    color: AppColors.blue,
                    title: 'إضاءة منخفضة أثناء التسجيل',
                    description: 'تقلل التوهج في شاشات التسجيل الليلي.',
                    value: prefs.nightLogging,
                    onChanged: night ? prefs.setNightLogging : null,
                  ),
                  Divider(height: 1, color: numuwBorderColor()),
                  _ToggleRow(
                    icon: Icons.accessibility_new_rounded,
                    color: AppColors.success,
                    title: 'تقليل الحركة',
                    description: 'يقلل الانتقالات والحركة الزخرفية.',
                    value: prefs.reducedMotion,
                    onChanged: prefs.setReducedMotion,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'تُحفظ اختياراتك تلقائيًا على هذا الجهاز.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: numuwTextColor(),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 21),
      );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Icon(icon, color: selected ? numuwAccentColor() : null),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? numuwAccentColor() : numuwSecondaryTextColor(),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
        child: Row(
          children: [
            _IconBox(icon: icon, color: color),
            const SizedBox(width: 13),
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
                    description,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(value: value, onChanged: onChanged),
          ],
        ),
      );
}
