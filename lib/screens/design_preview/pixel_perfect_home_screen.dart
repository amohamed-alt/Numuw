import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/assets/numuw_embedded_assets.dart';

class NumuwPixelHomeScreen extends StatelessWidget {
  const NumuwPixelHomeScreen({
    super.key,
    this.darkMode = false,
  });

  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final palette = darkMode
        ? const _PixelPalette.dark()
        : const _PixelPalette.light();

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: palette.background,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              brightness: darkMode ? Brightness.dark : Brightness.light,
              primary: palette.primary,
              surface: palette.surface,
              onSurface: palette.textPrimary,
            ),
      ),
      child: Scaffold(
        key: const ValueKey('numuw-pixel-home'),
        backgroundColor: palette.background,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = (constraints.maxWidth / 393).clamp(.86, 1.12);
              double s(double value) => value * scale;

              return Stack(
                children: [
                  Positioned(
                    top: s(-88),
                    left: s(-70),
                    child: _SoftGlow(
                      size: s(220),
                      color: palette.glow,
                    ),
                  ),
                  Positioned(
                    right: s(-90),
                    bottom: s(122),
                    child: _SoftGlow(
                      size: s(210),
                      color: palette.secondaryGlow,
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            s(18),
                            s(10),
                            s(18),
                            s(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Header(palette: palette, scale: scale),
                              SizedBox(height: s(14)),
                              _ChildCard(palette: palette, scale: scale),
                              SizedBox(height: s(14)),
                              _GrowthCard(palette: palette, scale: scale),
                              SizedBox(height: s(18)),
                              Text(
                                'ملخص اليوم',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: s(18),
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: s(10)),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricCard(
                                      palette: palette,
                                      scale: scale,
                                      title: 'الرضاعة الأخيرة',
                                      imageBytes: NumuwEmbeddedAssets.bottle,
                                      firstLine: 'منذ',
                                      secondLine: '1h 20m',
                                    ),
                                  ),
                                  SizedBox(width: s(9)),
                                  Expanded(
                                    child: _MetricCard(
                                      palette: palette,
                                      scale: scale,
                                      title: 'النوم',
                                      imageBytes: NumuwEmbeddedAssets.moon,
                                      firstLine: '11 ساعة',
                                      secondLine: '20 دقيقة',
                                    ),
                                  ),
                                  SizedBox(width: s(9)),
                                  Expanded(
                                    child: _MetricCard(
                                      palette: palette,
                                      scale: scale,
                                      title: 'الحفاضة',
                                      imageBytes: NumuwEmbeddedAssets.diaper,
                                      firstLine: 'منذ',
                                      secondLine: '45m',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: s(14)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _VaccinationCard(
                                      palette: palette,
                                      scale: scale,
                                    ),
                                  ),
                                  SizedBox(width: s(10)),
                                  Expanded(
                                    child: _DailyTipCard(
                                      palette: palette,
                                      scale: scale,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      _BottomNavigation(palette: palette, scale: scale),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.palette, required this.scale});

  final _PixelPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return SizedBox(
      height: s(42),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('home-notifications'),
            onPressed: () {},
            tooltip: 'التنبيهات',
            style: IconButton.styleFrom(
              minimumSize: Size(s(44), s(44)),
              foregroundColor: palette.textPrimary,
            ),
            icon: Icon(Icons.notifications_none_rounded, size: s(25)),
          ),
          const Spacer(),
          Image.memory(
            NumuwEmbeddedAssets.leafTip,
            width: s(24),
            height: s(24),
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
          SizedBox(width: s(5)),
          Text(
            'مرحباً ماما',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: s(22),
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.palette, required this.scale});

  final _PixelPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return _PixelCard(
      palette: palette,
      height: s(100),
      radius: s(22),
      child: Padding(
        padding: EdgeInsetsDirectional.all(s(13)),
        child: Row(
          children: [
            ClipOval(
              child: Image.memory(
                NumuwEmbeddedAssets.baby,
                width: s(72),
                height: s(72),
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
            SizedBox(width: s(13)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'يوسف',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: s(23),
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: s(6)),
                  Text(
                    '9 أسابيع و3 أيام',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: s(14.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: s(9)),
            Container(
              width: s(38),
              height: s(38),
              decoration: BoxDecoration(
                color: palette.softPrimary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.favorite_border_rounded,
                color: palette.gold,
                size: s(22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.palette, required this.scale});

  final _PixelPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return _PixelCard(
      palette: palette,
      height: s(138),
      radius: s(22),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(s(10), s(12), s(14), s(12)),
        child: Row(
          children: [
            SizedBox(
              width: s(111),
              height: s(116),
              child: Image.memory(
                NumuwEmbeddedAssets.plant,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
            SizedBox(width: s(9)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'نبتة يوسف',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: s(19),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: s(7)),
                  Text(
                    'كل تسجيل يسقي رحلة نموه',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: s(13.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: s(18)),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: s(10),
                        decoration: BoxDecoration(
                          color: palette.progressTrack,
                          borderRadius: BorderRadius.circular(s(20)),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: .65,
                          child: Container(
                            height: s(10),
                            decoration: BoxDecoration(
                              color: palette.primary,
                              borderRadius: BorderRadius.circular(s(20)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: s(-12),
                        child: Text(
                          '65%',
                          style: TextStyle(
                            color: palette.primaryDark,
                            fontSize: s(10.5),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.palette,
    required this.scale,
    required this.title,
    required this.imageBytes,
    required this.firstLine,
    required this.secondLine,
  });

  final _PixelPalette palette;
  final double scale;
  final String title;
  final Uint8List imageBytes;
  final String firstLine;
  final String secondLine;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return _PixelCard(
      palette: palette,
      height: s(114),
      radius: s(18),
      elevation: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(s(6), s(9), s(6), s(8)),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: s(12.2),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: s(4)),
            Image.memory(
              imageBytes,
              width: s(38),
              height: s(38),
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
            const Spacer(),
            Text(
              firstLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: s(11.5),
                fontWeight: FontWeight.w500,
                height: 1.05,
              ),
            ),
            SizedBox(height: s(2)),
            Text(
              secondLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: s(13.2),
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccinationCard extends StatelessWidget {
  const _VaccinationCard({required this.palette, required this.scale});

  final _PixelPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return _PixelCard(
      palette: palette,
      height: s(148),
      radius: s(20),
      elevation: false,
      background: palette.vaccineSurface,
      child: Padding(
        padding: EdgeInsetsDirectional.all(s(11)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'التطعيم القادم',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: s(14.5),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: s(7)),
            Expanded(
              child: Row(
                children: [
                  Image.memory(
                    NumuwEmbeddedAssets.shield,
                    width: s(62),
                    height: s(62),
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                  SizedBox(width: s(7)),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'بعد 6 أيام',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: s(18),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: s(4)),
                        Text(
                          'اللقاح الروتيني',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: s(11.5),
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
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({required this.palette, required this.scale});

  final _PixelPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return _PixelCard(
      palette: palette,
      height: s(148),
      radius: s(20),
      elevation: false,
      background: palette.tipSurface,
      child: Padding(
        padding: EdgeInsetsDirectional.all(s(11)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نصيحة اليوم',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: s(14.5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: s(9)),
                Text(
                  'الحفاظ على روتين النوم يساعد طفلك على الاستقرار والنمو.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: s(12.5),
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              start: 0,
              bottom: 0,
              child: Image.memory(
                NumuwEmbeddedAssets.leafTip,
                width: s(30),
                height: s(30),
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.palette, required this.scale});

  final _PixelPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    const items = <_NavigationItem>[
      _NavigationItem(Icons.home_rounded, 'اليوم', true),
      _NavigationItem(Icons.edit_note_rounded, 'التسجيل', false),
      _NavigationItem(Icons.child_care_rounded, 'طفلي', false),
      _NavigationItem(Icons.auto_awesome_rounded, 'اسألي', false),
      _NavigationItem(Icons.more_horiz_rounded, 'المزيد', false),
    ];

    return Container(
      height: s(84),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(s(10), s(7), s(10), s(15)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: items
              .map(
                (item) => Expanded(
                  child: _NavigationDestination(
                    item: item,
                    palette: palette,
                    scale: scale,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.item,
    required this.palette,
    required this.scale,
  });

  final _NavigationItem item;
  final _PixelPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return Semantics(
      selected: item.selected,
      button: true,
      label: item.label,
      child: InkResponse(
        onTap: () {},
        radius: s(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: s(42),
              height: s(34),
              decoration: BoxDecoration(
                color: item.selected ? palette.softPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(s(20)),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                size: s(22),
                color: item.selected
                    ? palette.primaryDark
                    : palette.textSecondary,
              ),
            ),
            SizedBox(height: s(2)),
            Text(
              item.label,
              style: TextStyle(
                color: item.selected
                    ? palette.primaryDark
                    : palette.textSecondary,
                fontSize: s(10.5),
                fontWeight:
                    item.selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelCard extends StatelessWidget {
  const _PixelCard({
    required this.palette,
    required this.height,
    required this.radius,
    required this.child,
    this.background,
    this.elevation = true,
  });

  final _PixelPalette palette;
  final double height;
  final double radius;
  final Widget child;
  final Color? background;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background ?? palette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.border),
        boxShadow: elevation
            ? [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.color});

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

class _NavigationItem {
  const _NavigationItem(this.icon, this.label, this.selected);

  final IconData icon;
  final String label;
  final bool selected;
}

class _PixelPalette {
  const _PixelPalette.light()
      : background = const Color(0xFFFBF8F1),
        surface = const Color(0xFFFFFDF9),
        primary = const Color(0xFF74865B),
        primaryDark = const Color(0xFF4F6242),
        softPrimary = const Color(0xFFE5EAD9),
        gold = const Color(0xFFD6B36A),
        textPrimary = const Color(0xFF37372F),
        textSecondary = const Color(0xFF7D7A70),
        border = const Color(0xFFE7DED2),
        progressTrack = const Color(0xFFE7E2D7),
        vaccineSurface = const Color(0xFFF7F1EA),
        tipSurface = const Color(0xFFF4F0E7),
        glow = const Color(0x55E7D7B2),
        secondaryGlow = const Color(0x44DCE4CB),
        shadow = const Color(0x188A7B68);

  const _PixelPalette.dark()
      : background = const Color(0xFF171B17),
        surface = const Color(0xFF222820),
        primary = const Color(0xFFA8B58E),
        primaryDark = const Color(0xFFD3DDBB),
        softPrimary = const Color(0xFF343D30),
        gold = const Color(0xFFE8B86D),
        textPrimary = const Color(0xFFF5F1E8),
        textSecondary = const Color(0xFFBDB8AC),
        border = const Color(0xFF394137),
        progressTrack = const Color(0xFF394137),
        vaccineSurface = const Color(0xFF2A3128),
        tipSurface = const Color(0xFF252B23),
        glow = const Color(0x33313B2E),
        secondaryGlow = const Color(0x224F6242),
        shadow = const Color(0x30000000);

  final Color background;
  final Color surface;
  final Color primary;
  final Color primaryDark;
  final Color softPrimary;
  final Color gold;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color progressTrack;
  final Color vaccineSurface;
  final Color tipSurface;
  final Color glow;
  final Color secondaryGlow;
  final Color shadow;
}
