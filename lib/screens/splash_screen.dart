import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _HeroMark(),
                const SizedBox(height: 22),
                Text(
                  'نُموّ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'رفيقتكِ في رحلة الأمومة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 26),
                const NumuwPlantProgress(progress: .12, label: 'البذرة الأولى'),
                const SizedBox(height: 22),
                const LoadingDots(color: AppColors.mintDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroMark extends StatelessWidget {
  const _HeroMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      height: 138,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFF3E8D3), Color(0xFFE8DEC7)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A4F6242),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: CustomPaint(painter: _NumuwMarkPainter()),
    );
  }
}

class _NumuwMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stemPaint = Paint()
      ..color = AppColors.mintDark
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final leafPaint = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.fill;
    final clayPaint = Paint()..color = AppColors.peach;

    final pot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * .72),
        width: size.width * .42,
        height: size.height * .18,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(pot, clayPaint);

    canvas.drawLine(
      Offset(center.dx, size.height * .56),
      Offset(center.dx, size.height * .40),
      stemPaint,
    );

    final leftLeaf = Path()
      ..moveTo(center.dx, size.height * .48)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .42,
        size.width * .30,
        size.height * .31,
      )
      ..quadraticBezierTo(
        size.width * .42,
        size.height * .37,
        center.dx,
        size.height * .48,
      );
    final rightLeaf = Path()
      ..moveTo(center.dx, size.height * .44)
      ..quadraticBezierTo(
        size.width * .76,
        size.height * .36,
        size.width * .70,
        size.height * .24,
      )
      ..quadraticBezierTo(
        size.width * .58,
        size.height * .30,
        center.dx,
        size.height * .44,
      );
    canvas.drawPath(leftLeaf, leafPaint);
    canvas.drawPath(rightLeaf, leafPaint);

    final seed = Paint()
      ..color = Colors.white.withValues(alpha: .8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, size.height * .66), 6, seed);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
