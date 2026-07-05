import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/assets/numuw_embedded_assets.dart';

class NumuwPixelHomeFixedV2 extends StatelessWidget {
  const NumuwPixelHomeFixedV2({super.key, this.darkMode = false});

  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final p = darkMode ? const _P.dark() : const _P.light();
    return Scaffold(
      backgroundColor: darkMode
          ? const Color(0xFF121512)
          : const Color(0xFFF3EDE3),
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 393,
              height: 852,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.background,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x24000000),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                          child: Column(
                            children: [
                              _StatusBar(p: p),
                              const SizedBox(height: 10),
                              _Header(p: p),
                              const SizedBox(height: 12),
                              _ChildCard(p: p),
                              const SizedBox(height: 12),
                              _GrowthCard(p: p),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'ملخص اليوم',
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: _MetricCard(
                                      p: p,
                                      title: 'الحفاضة',
                                      bytes: NumuwEmbeddedAssets.diaper,
                                      fallback: Icons.baby_changing_station,
                                      line1: 'منذ',
                                      line2: '45m',
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: _MetricCard(
                                      p: p,
                                      title: 'النوم',
                                      bytes: NumuwEmbeddedAssets.moon,
                                      fallback: Icons.nightlight_round,
                                      line1: '11 ساعة',
                                      line2: '20 دقيقة',
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: _MetricCard(
                                      p: p,
                                      title: 'الرضاعة الأخيرة',
                                      bytes: NumuwEmbeddedAssets.bottle,
                                      fallback: Icons.local_drink_rounded,
                                      line1: 'منذ',
                                      line2: '1h 20m',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(child: _TipCard(p: p)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _VaccineCard(p: p)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      _BottomNav(p: p),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.p});
  final _P p;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        children: [
          Text('9:41',
              style: TextStyle(
                  color: p.text, fontSize: 12, fontWeight: FontWeight.w800)),
          const Spacer(),
          Icon(Icons.signal_cellular_alt_rounded, size: 13, color: p.text),
          const SizedBox(width: 4),
          Icon(Icons.wifi_rounded, size: 13, color: p.text),
          const SizedBox(width: 4),
          Icon(Icons.battery_full_rounded, size: 15, color: p.text),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.p});
  final _P p;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            tooltip: 'التنبيهات',
            icon: Icon(Icons.notifications_none_rounded, color: p.text, size: 25),
          ),
          const Spacer(),
          _memory(
            NumuwEmbeddedAssets.leafTip,
            width: 24,
            height: 24,
            fallback: Icon(Icons.eco_rounded, color: p.primary, size: 22),
          ),
          const SizedBox(width: 6),
          Text('مرحباً ماما',
              style: TextStyle(
                  color: p.text, fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.p});
  final _P p;

  @override
  Widget build(BuildContext context) {
    return _Card(
      p: p,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: p.soft, shape: BoxShape.circle),
              child: Icon(Icons.favorite_border_rounded, color: p.gold, size: 22),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('يوسف',
                      style: TextStyle(
                          color: p.text,
                          fontSize: 23,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text('9 أسابيع و3 أيام',
                      style: TextStyle(
                          color: p.muted,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipOval(
              child: _memory(
                NumuwEmbeddedAssets.baby,
                width: 73,
                height: 73,
                fit: BoxFit.cover,
                fallback: Container(
                  width: 73,
                  height: 73,
                  color: p.soft,
                  child: Icon(Icons.child_care_rounded, color: p.primary, size: 34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.p});
  final _P p;

  @override
  Widget build(BuildContext context) {
    return _Card(
      p: p,
      height: 144,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('نبتة يوسف',
                      style: TextStyle(
                          color: p.text,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Text('كل تسجيل يسقي رحلة نموه',
                      style: TextStyle(
                          color: p.muted,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 19),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Container(height: 10, color: p.track),
                        FractionallySizedBox(
                          widthFactor: .65,
                          alignment: Alignment.centerRight,
                          child: Container(height: 10, color: p.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.center,
                    child: Text('65%',
                        style: TextStyle(
                            color: p.primaryDark,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _memory(
              NumuwEmbeddedAssets.plant,
              width: 108,
              height: 116,
              fallback:
                  Icon(Icons.local_florist_rounded, color: p.primary, size: 70),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.p,
    required this.title,
    required this.bytes,
    required this.fallback,
    required this.line1,
    required this.line2,
  });

  final _P p;
  final String title;
  final Uint8List bytes;
  final IconData fallback;
  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    return _Card(
      p: p,
      height: 113,
      elevated: false,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        child: Column(
          children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: p.text,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            _memory(bytes,
                width: 38,
                height: 38,
                fallback: Icon(fallback, color: p.primary, size: 30)),
            const Spacer(),
            Text(line1,
                style: TextStyle(
                    color: p.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(line2,
                style: TextStyle(
                    color: p.text,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.p});
  final _P p;

  @override
  Widget build(BuildContext context) {
    return _Card(
      p: p,
      height: 149,
      radius: 20,
      elevated: false,
      color: p.tip,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('نصيحة اليوم',
                    style: TextStyle(
                        color: p.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                Text(
                  'الحفاظ على روتين النوم يساعد طفلك على الاستقرار والنمو.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 12.5,
                      height: 1.7,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: _memory(
                NumuwEmbeddedAssets.leafTip,
                width: 31,
                height: 31,
                fallback: Icon(Icons.eco_rounded, color: p.primary, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  const _VaccineCard({required this.p});
  final _P p;

  @override
  Widget build(BuildContext context) {
    return _Card(
      p: p,
      height: 149,
      radius: 20,
      elevated: false,
      color: p.vaccine,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('التطعيم القادم',
                style: TextStyle(
                    color: p.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('بعد 6 أيام',
                            style: TextStyle(
                                color: p.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('اللقاح الروتيني',
                            style: TextStyle(
                                color: p.muted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  _memory(
                    NumuwEmbeddedAssets.shield,
                    width: 62,
                    height: 62,
                    fallback: Icon(Icons.health_and_safety_rounded,
                        color: p.primary, size: 48),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.p});
  final _P p;

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
      height: 85,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 14),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: items.map((item) {
          return Expanded(
            child: InkResponse(
              onTap: () {},
              radius: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 34,
                    decoration: BoxDecoration(
                      color: item.$3 ? p.soft : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.$1,
                        size: 22,
                        color: item.$3 ? p.primaryDark : p.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(item.$2,
                      style: TextStyle(
                          color: item.$3 ? p.primaryDark : p.muted,
                          fontSize: 10.5,
                          fontWeight:
                              item.$3 ? FontWeight.w800 : FontWeight.w600)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.p,
    required this.height,
    required this.child,
    this.radius = 22,
    this.color,
    this.elevated = true,
  });

  final _P p;
  final double height;
  final Widget child;
  final double radius;
  final Color? color;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.border),
        boxShadow: elevated
            ? [
                BoxShadow(
                    color: p.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 5)),
              ]
            : null,
      ),
      child: child,
    );
  }
}

Widget _memory(
  Uint8List bytes, {
  required double width,
  required double height,
  required Widget fallback,
  BoxFit fit = BoxFit.contain,
}) {
  return Image.memory(
    bytes,
    width: width,
    height: height,
    fit: fit,
    gaplessPlayback: true,
    errorBuilder: (_, __, ___) => SizedBox(
      width: width,
      height: height,
      child: Center(child: fallback),
    ),
  );
}

class _P {
  const _P.light()
      : background = const Color(0xFFFBF8F1),
        surface = const Color(0xFFFFFDF9),
        primary = const Color(0xFF74865B),
        primaryDark = const Color(0xFF4F6242),
        soft = const Color(0xFFE5EAD9),
        gold = const Color(0xFFD6B36A),
        text = const Color(0xFF37372F),
        muted = const Color(0xFF7D7A70),
        border = const Color(0xFFE7DED2),
        track = const Color(0xFFE7E2D7),
        vaccine = const Color(0xFFF7F1EA),
        tip = const Color(0xFFF4F0E7),
        shadow = const Color(0x188A7B68);

  const _P.dark()
      : background = const Color(0xFF171B17),
        surface = const Color(0xFF222820),
        primary = const Color(0xFFA8B58E),
        primaryDark = const Color(0xFFD3DDBB),
        soft = const Color(0xFF343D30),
        gold = const Color(0xFFE8B86D),
        text = const Color(0xFFF5F1E8),
        muted = const Color(0xFFBDB8AC),
        border = const Color(0xFF394137),
        track = const Color(0xFF394137),
        vaccine = const Color(0xFF2A3128),
        tip = const Color(0xFF252B23),
        shadow = const Color(0x30000000);

  final Color background;
  final Color surface;
  final Color primary;
  final Color primaryDark;
  final Color soft;
  final Color gold;
  final Color text;
  final Color muted;
  final Color border;
  final Color track;
  final Color vaccine;
  final Color tip;
  final Color shadow;
}
