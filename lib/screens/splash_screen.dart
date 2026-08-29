import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../design/numuw_motion_widgets.dart';
import '../design/numuw_organic_icons.dart';
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
                const NumuwEntrance(child: _HeroMark()),
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFF3E8D3), Color(0xFFE8DEC7)],
        ),
        boxShadow: numuwNightMode()
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x1A4F6242),
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
      ),
      child: const NumuwOrganicIcon(
        NumuwOrganicIconName.growth,
        size: 104,
        semanticLabel: 'نمو الطفل',
      ),
    );
  }
}
