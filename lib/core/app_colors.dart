import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color webBackground = Color(0xFFE8E2D7);
  static const Color background = Color(0xFFFBF8F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF252525);
  static const Color secondaryText = Color(0xFF77736F);
  static const Color mutedText = Color(0xFF9E9690);
  static const Color border = Color(0xFFEDE7E1);
  static const Color neutralSoft = Color(0xFFF8F5F1);

  static const Color mint = Color(0xFF59B8A5);
  static const Color mintDark = Color(0xFF3D9E8C);
  static const Color mintLight = Color(0xFFE7F4F0);
  static const Color mintSoft = Color(0xFFD4EDE8);

  static const Color peach = Color(0xFFF3A26B);
  static const Color peachLight = Color(0xFFFDEBDF);
  static const Color danger = Color(0xFFE77A68);
  static const Color purple = Color(0xFF9B86D8);
  static const Color purpleLight = Color(0xFFF0EBFA);
  static const Color yellow = Color(0xFFE9BC5D);
  static const Color yellowLight = Color(0xFFFFF3D7);
  static const Color blue = Color(0xFF84B7D8);
  static const Color blueLight = Color(0xFFEAF4FA);

  static const Color nightBackground = Color(0xFF0F1724);
  static const Color nightSurface = Color(0xFF172130);
  static const Color nightSurfaceSoft = Color(0xFF202D3F);
  static const Color nightBorder = Color(0xFF243040);
  static const Color nightText = Color(0xFFF4EFE7);
  static const Color nightSecondaryText = Color(0xFF9BA8B5);
  static const Color nightGold = Color(0xFFE8B86D);
  static const Color nightGoldSoft = Color(0x33232323);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [mint, mintDark],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [nightSurfaceSoft, nightBackground],
  );
}

class NumuwSpacing {
  const NumuwSpacing._();

  static const double pageX = 18;
  static const double pageTop = 18;
  static const double card = 18;
  static const double gapXs = 6;
  static const double gapSm = 10;
  static const double gapMd = 14;
  static const double gapLg = 18;
  static const double gapXl = 24;
  static const double mobileWidth = 390;
  static const double maxMobileWidth = 390;
}

class NumuwRadius {
  const NumuwRadius._();

  static const double input = 14;
  static const double button = 18;
  static const double card = 20;
  static const double largeCard = 24;
  static const double icon = 22;
}

class NumuwMotion {
  const NumuwMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration screen = Duration(milliseconds: 260);
  static const Duration toast = Duration(milliseconds: 2200);
}
