import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../state/app_preferences.dart';
import '../widgets/app_widgets.dart';

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
    final night = prefs.nightMode;
    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('الإعدادات')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title('المظهر'),
            const SizedBox(height: 12),
            SoftCard(
              child: Row(
                children: [
                  Expanded(
                    child: _Swatch(
                      color: numuwPageColor(),
                      label: 'الخلفية',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Swatch(
                      color: numuwSurfaceColor(),
                      label: 'البطاقة',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Swatch(
                      color: numuwAccentColor(),
                      label: 'الذهبي',
                      highlighted: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                    description:
                        'دفء ضوء الصباح — مناسب للقراءة والتقارير والنماذج',
                    selected: prefs.themePreference == 'light',
                    onTap: () => prefs.setThemePreference('light'),
                  ),
                  Divider(height: 1, color: numuwBorderColor()),
                  _ThemeOption(
                    icon: Icons.dark_mode_outlined,
                    title: 'الوضع الليلي',
                    description:
                        'قمر الليل — مريح للعين ليلًا وأثناء الرضاعة',
                    selected: prefs.themePreference == 'dark',
                    onTap: () => prefs.setThemePreference('dark'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Title('وضع التسجيل الليلي'),
            const SizedBox(height: 12),
            Opacity(
              opacity: night ? 1 : .55,
              child: SoftCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _IconBox(
                          icon: Icons.nights_stay_outlined,
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إضاءة منخفضة أثناء الليل',
                                style: TextStyle(
                                  color: numuwTextColor(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'يخفّف السطوع والتوهّج في شاشات التسجيل ويبقي المؤقّت وزر الحفظ واضحين.',
                                style: TextStyle(
                                  color: numuwSecondaryTextColor(),
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: prefs.nightLogging,
                          onChanged: night
                              ? (value) => prefs.setNightLogging(value)
                              : null,
                        ),
                      ],
                    ),
                    if (!night) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: numuwBorderColor()),
                      const SizedBox(height: 12),
                      Text(
                        'يعمل وضع التسجيل الليلي مع الوضع الليلي فقط.',
                        style: TextStyle(
                          color: numuwSecondaryTextColor(),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _Title('إمكانية الوصول'),
            const SizedBox(height: 12),
            SoftCard(
              child: Row(
                children: [
                  _IconBox(
                    icon: Icons.accessibility_new_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقليل الحركة',
                          style: TextStyle(
                            color: numuwTextColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'يستبدل الانتقالات الكبيرة بتلاشٍ بسيط ويزيل الحركة الزخرفية.',
                          style: TextStyle(
                            color: numuwSecondaryTextColor(),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: prefs.reducedMotion,
                    onChanged: prefs.setReducedMotion,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'يُحفظ اختيارك للمظهر وتفضيلات الوصول تلقائيًا.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 13,
                  height: 1.7,
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

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.label,
    this.highlighted = false,
  });

  final Color color;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: highlighted
                    ? numuwAccentColor()
                    : numuwBorderColor(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: numuwSecondaryTextColor(),
              fontSize: 11,
            ),
          ),
        ],
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
  Widget build(BuildContext context) => Material(
        color: selected
            ? numuwAccentColor().withValues(alpha: .10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 14, 12, 14),
            child: Row(
              children: [
                _IconBox(icon: icon, color: numuwAccentColor()),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(
                          color: numuwSecondaryTextColor(),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: selected
                        ? numuwAccentColor()
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? numuwAccentColor()
                          : numuwBorderColor(),
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          color: numuwNightMode()
                              ? AppColors.nightBackground
                              : Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: color, size: 22),
      );
}
