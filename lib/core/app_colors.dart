import 'package:flutter/material.dart';

/// Numuw semantic palette.
///
/// The visual identity is "Moonlight Nursery": warm daylight surfaces and a
/// calm navy night theme. Existing aliases are intentionally preserved so the
/// current feature screens inherit the redesign without losing functionality.
class AppColors {
  const AppColors._();

  // Light mode — warm morning light, never clinical white.
  static const Color webBackground = Color(0xFFEFE8DC);
  static const Color background = Color(0xFFF7F3EA);
  static const Color surface = Color(0xFFFFFDFC);
  static const Color text = Color(0xFF18222D);
  static const Color secondaryText = Color(0xFF607080);
  static const Color mutedText = Color(0xFF87919A);
  static const Color border = Color(0xFFDDD5C8);
  static const Color neutralSoft = Color(0xFFEFE8DC);

  // Legacy "mint" aliases now resolve to Numuw moon gold.
  static const Color mint = Color(0xFFB98235);
  static const Color mintDark = Color(0xFF8F6125);
  static const Color mintLight = Color(0xFFF4E6CC);
  static const Color mintSoft = Color(0xFFEAD5AE);

  static const Color peach = Color(0xFFB96658);
  static const Color peachLight = Color(0xFFF6E5E1);
  static const Color danger = Color(0xFFB96658);
  static const Color purple = Color(0xFF7C6A9A);
  static const Color purpleLight = Color(0xFFEDE8F3);
  static const Color yellow = Color(0xFFB98235);
  static const Color yellowLight = Color(0xFFF4E6CC);
  static const Color blue = Color(0xFF557F9A);
  static const Color blueLight = Color(0xFFE5EEF3);
  static const Color success = Color(0xFF4F8E73);
  static const Color successLight = Color(0xFFE4F0E9);

  // Dark mode — the signature Moonlight Nursery identity.
  static const Color nightBackground = Color(0xFF0F1923);
  static const Color nightSurface = Color(0xFF172130);
  static const Color nightSurfaceSoft = Color(0xFF1D283A);
  static const Color nightBorder = Color(0xFF263342);
  static const Color nightText = Color(0xFFF7F3EA);
  static const Color nightSecondaryText = Color(0xFFAAB4BE);
  static const Color nightMutedText = Color(0xFF74808D);
  static const Color nightGold = Color(0xFFE8B86D);
  static const Color nightGoldSoft = Color(0x332E261A);
  static const Color nightSuccess = Color(0xFF79B89C);
  static const Color nightWarning = Color(0xFFD98C7C);
  static const Color nightInfo = Color(0xFF7FA9C4);

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

  static LinearGradient heroGradient(bool night) => LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: night
        ? const [Color(0xFF1D2B3C), Color(0xFF172130)]
        : const [Color(0xFFFFFDFC), Color(0xFFF4E6CC)],
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
