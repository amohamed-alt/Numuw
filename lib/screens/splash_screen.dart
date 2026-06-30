import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../widgets/app_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(34),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x6659B8A5),
                    blurRadius: 48,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: CustomPaint(painter: _NumuwMarkPainter()),
            ),
            const SizedBox(height: 28),
            Text(
              'نُمُوّ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'رفيقتكِ في رحلة الأمومة',
              textAlign: TextAlign.center,
              style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 15),
            ),
            const SizedBox(height: 48),
            const LoadingDots(color: AppColors.mint),
          ],
        ),
      ),
    );
  }
}

class _NumuwMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withValues(alpha: .95);
    final mint = Paint()..color = AppColors.mint;
    final strokeWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final strokeMint = Paint()
      ..color = AppColors.mint
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    canvas.drawCircle(Offset(cx, size.height * .43), size.width * .23, white);
    canvas.drawCircle(Offset(size.width * .42, size.height * .38), 2.5, mint);
    canvas.drawCircle(Offset(size.width * .58, size.height * .38), 2.5, mint);

    final smile = Path()
      ..moveTo(size.width * .42, size.height * .49)
      ..quadraticBezierTo(
        cx,
        size.height * .56,
        size.width * .58,
        size.height * .49,
      );
    canvas.drawPath(smile, strokeMint);
    canvas.drawLine(
      Offset(cx, size.height * .63),
      Offset(cx, size.height * .86),
      strokeWhite,
    );

    final leaf1 = Path()
      ..moveTo(cx, size.height * .80)
      ..quadraticBezierTo(
        size.width * .40,
        size.height * .72,
        size.width * .40,
        size.height * .62,
      );
    final leaf2 = Path()
      ..moveTo(cx, size.height * .77)
      ..quadraticBezierTo(
        size.width * .60,
        size.height * .70,
        size.width * .60,
        size.height * .59,
      );
    canvas.drawPath(leaf1, strokeWhite..strokeWidth = 2.5);
    canvas.drawPath(leaf2, strokeWhite..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
