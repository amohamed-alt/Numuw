import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/numuw_colors.dart';

class NumuwHomeV2 extends StatelessWidget {
  const NumuwHomeV2({super.key, required this.darkMode});

  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final colors = _HomeColors(darkMode: darkMode);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.clamp(320.0, 430.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: Stack(
                  children: [
                    Positioned(
                      top: -80,
                      right: -120,
                      child: _Glow(size: 260, color: colors.glow),
                    ),
                    Positioned(
                      bottom: 130,
                      left: -100,
                      child: _Glow(size: 220, color: colors.secondaryGlow),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  18,
                                  12,
                                  18,
                                  24,
                                ),
                                sliver: SliverList.list(
                                  children: [
                                    _Header(colors: colors),
                                    const SizedBox(height: 14),
                                    _ChildHeroCard(colors: colors),
                                    const SizedBox(height: 14),
                                    _GrowthCard(colors: colors),
                                    const SizedBox(height: 20),
                                    _SectionTitle(
                                      title: 'ملخص اليوم',
                                      colors: colors,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _MetricCard(
                                            colors: colors,
                                            title: 'الرضاعة',
                                            asset: 'assets/illustrations/feeding_bottle.svg',
                                            primaryValue: 'منذ ساعة و20 دقيقة',
                                            accent: colors.gold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _MetricCard(
                                            colors: colors,
                                            title: 'النوم',
                                            asset: 'assets/illustrations/sleep_moon.svg',
                                            primaryValue: '11 ساعة و20 دقيقة',
                                            accent: const Color(0xFF7D88A8),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _MetricCard(
                                            colors: colors,
                                            title: 'الحفاضة',
                                            asset: 'assets/illustrations/diaper.svg',
                                            primaryValue: 'منذ 45 دقيقة',
                                            accent: colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _VaccineCard(colors: colors),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _DailyTipCard(colors: colors),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _BottomNavigation(colors: colors),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          colors: colors,
          icon: Icons.notifications_none_rounded,
          tooltip: 'التنبيهات',
          onPressed: () {},
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_rounded, size: 22, color: colors.primary),
                const SizedBox(width: 6),
                Text(
                  'مرحباً ماما',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'صباح هادئ لكِ وليوسف',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChildHeroCard extends StatelessWidget {
  const _ChildHeroCard({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      colors: colors,
      radius: 24,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 14, 14),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _BabyPortrait(colors: colors),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'يوسف',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 19,
                        color: colors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '9 أسابيع و3 أيام',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _Pill(
                      colors: colors,
                      icon: Icons.eco_rounded,
                      label: 'رضاعة طبيعية',
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      colors: colors,
                      icon: Icons.monitor_weight_outlined,
                      label: '3.25 كجم',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BabyPortrait extends StatelessWidget {
  const _BabyPortrait({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.gold.withValues(alpha: .45)),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: .12),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          ClipOval(
            child: SvgPicture.asset(
              'assets/illustrations/baby_portrait.svg',
              width: 82,
              height: 82,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 5,
            child: Transform.rotate(
              angle: -.55,
              child: Icon(Icons.eco_rounded, size: 29, color: colors.primary),
            ),
          ),
          Positioned(
            right: 1,
            top: 2,
            child: Icon(Icons.auto_awesome_rounded, size: 18, color: colors.gold),
          ),
        ],
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      colors: colors,
      radius: 24,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 18, 14),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 122,
            height: 126,
            child: SvgPicture.asset(
              'assets/illustrations/growth_plant.svg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نبتة يوسف',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'كل تسجيل يسقي رحلة نموه',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '65%',
                      style: TextStyle(
                        color: colors.primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مستوى النمو',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: .65,
                    minHeight: 11,
                    backgroundColor: colors.progressTrack,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.colors,
    required this.title,
    required this.asset,
    required this.primaryValue,
    required this.accent,
  });

  final _HomeColors colors;
  final String title;
  final String asset;
  final String primaryValue;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      colors: colors,
      radius: 20,
      elevated: false,
      padding: const EdgeInsetsDirectional.fromSTEB(9, 11, 9, 12),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(9),
            child: SvgPicture.asset(asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 9),
          Text(
            primaryValue,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  const _VaccineCard({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      colors: colors,
      radius: 22,
      background: colors.vaccineSurface,
      elevated: false,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'التطعيم القادم',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(
                  width: 62,
                  height: 70,
                  child: SvgPicture.asset(
                    'assets/illustrations/vaccine_shield.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'بعد 6 أيام',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اللقاح الروتيني',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      colors: colors,
      radius: 22,
      background: colors.tipSurface,
      elevated: false,
      padding: const EdgeInsets.all(13),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'نصيحة اليوم',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'الحفاظ على روتين نوم ثابت يساعد يوسف على الاستقرار والنمو.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.65,
                ),
              ),
            ],
          ),
          PositionedDirectional(
            start: 0,
            bottom: 0,
            child: Icon(Icons.eco_rounded, color: colors.primary, size: 30),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.colors});

  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'اليوم', true),
      (Icons.edit_note_rounded, 'التسجيل', false),
      (Icons.child_care_rounded, 'طفلي', false),
      (Icons.auto_awesome_rounded, 'اسألي', false),
      (Icons.more_horiz_rounded, 'المزيد', false),
    ];

    return Container(
      height: 84,
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 15),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: .96),
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: darkModeFor(colors) ? .16 : .04),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: items.map((item) {
          final selected = item.$3;
          return Expanded(
            child: InkResponse(
              onTap: () {},
              radius: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 34,
                    decoration: BoxDecoration(
                      color: selected ? colors.primarySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      item.$1,
                      size: 22,
                      color: selected ? colors.primaryDark : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: selected ? colors.primaryDark : colors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

bool darkModeFor(_HomeColors colors) => colors.background.computeLuminance() < .3;

class _Pill extends StatelessWidget {
  const _Pill({required this.colors, required this.icon, required this.label});

  final _HomeColors colors;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 5, 8, 5),
      decoration: BoxDecoration(
        color: colors.subtleSurface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.colors,
    required this.child,
    required this.padding,
    this.radius = 20,
    this.background,
    this.elevated = true,
  });

  final _HomeColors colors;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? background;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.border),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.colors,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final _HomeColors colors;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: const Size(46, 46),
        backgroundColor: colors.surface.withValues(alpha: .72),
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
      ),
      icon: Icon(icon, size: 24),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.colors});

  final String title;
  final _HomeColors colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _HomeColors {
  _HomeColors({required bool darkMode})
      : background = darkMode
            ? NumuwColorTokens.darkBackground
            : NumuwColorTokens.lightBackground,
        surface = darkMode
            ? NumuwColorTokens.darkSurface
            : NumuwColorTokens.lightSurface,
        subtleSurface = darkMode
            ? NumuwColorTokens.darkSurfaceElevated
            : NumuwColorTokens.lightSurfaceSoft,
        vaccineSurface = darkMode
            ? const Color(0xFF282C27)
            : const Color(0xFFF6F0E9),
        tipSurface = darkMode
            ? const Color(0xFF232923)
            : const Color(0xFFF3F0E7),
        primary = darkMode
            ? NumuwColorTokens.darkPrimary
            : NumuwColorTokens.lightPrimary,
        primaryDark = darkMode
            ? NumuwColorTokens.darkTextPrimary
            : NumuwColorTokens.lightPrimaryDark,
        primarySoft = darkMode
            ? NumuwColorTokens.darkPrimarySoft
            : NumuwColorTokens.lightPrimarySoft,
        textPrimary = darkMode
            ? NumuwColorTokens.darkTextPrimary
            : NumuwColorTokens.lightTextPrimary,
        textSecondary = darkMode
            ? NumuwColorTokens.darkTextSecondary
            : NumuwColorTokens.lightTextSecondary,
        border = darkMode
            ? NumuwColorTokens.darkBorder
            : NumuwColorTokens.lightBorder,
        progressTrack = darkMode
            ? NumuwColorTokens.darkBorder
            : const Color(0xFFE9E3D8),
        gold = darkMode ? const Color(0xFFE8B86D) : const Color(0xFFD6B36A),
        glow = darkMode
            ? const Color(0x44394533)
            : const Color(0x55E7D7B2),
        secondaryGlow = darkMode
            ? const Color(0x22343D30)
            : const Color(0x44DCE4CB),
        shadow = darkMode
            ? const Color(0x3D000000)
            : const Color(0x1C7A6D5C);

  final Color background;
  final Color surface;
  final Color subtleSurface;
  final Color vaccineSurface;
  final Color tipSurface;
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color progressTrack;
  final Color gold;
  final Color glow;
  final Color secondaryGlow;
  final Color shadow;
}
