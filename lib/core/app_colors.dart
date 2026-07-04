import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color webBackground = Color(0xFFF3EDE3);
  static const Color background = Color(0xFFFBF8F1);
  static const Color surface = Color(0xFFFFFDF9);
  static const Color text = Color(0xFF37372F);
  static const Color secondaryText = Color(0xFF7D7A70);
  static const Color mutedText = Color(0xFF9A9589);
  static const Color border = Color(0xFFE7DED2);
  static const Color neutralSoft = Color(0xFFF6F0E7);

  static const Color mint = Color(0xFF74865B);
  static const Color mintDark = Color(0xFF4F6242);
  static const Color mintLight = Color(0xFFE5EAD9);
  static const Color mintSoft = Color(0xFFDCE4CB);

  static const Color peach = Color(0xFFC98E6D);
  static const Color peachLight = Color(0xFFF0DDD1);
  static const Color danger = Color(0xFFBD6F68);
  static const Color purple = Color(0xFFE7E1EF);
  static const Color purpleLight = Color(0xFFF2EEF6);
  static const Color yellow = Color(0xFFE7D7B2);
  static const Color yellowLight = Color(0xFFF6EED5);
  static const Color blue = Color(0xFFC9D7E4);
  static const Color blueLight = Color(0xFFEAF0F6);

  static const Color nightBackground = Color(0xFF171B17);
  static const Color nightSurface = Color(0xFF222820);
  static const Color nightSurfaceSoft = Color(0xFF2A3128);
  static const Color nightBorder = Color(0xFF394137);
  static const Color nightText = Color(0xFFF5F1E8);
  static const Color nightSecondaryText = Color(0xFFBDB8AC);
  static const Color nightGold = Color(0xFFA8B58E);
  static const Color nightGoldSoft = Color(0x332A3128);

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
  static const double maxMobileWidth = 430;
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
