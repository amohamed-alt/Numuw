import 'package:flutter/material.dart';

/// Backward-compatible Numuw palette.
///
/// New code should prefer `core/theme/numuw_colors.dart`; these aliases are
/// kept because several production feature screens still depend on them.
class AppColors {
  const AppColors._();

  // Light mode — warm morning light.
  static const Color webBackground = Color(0xFFEFE8DC);
  static const Color background = Color(0xFFF7F3EA);
  static const Color backgroundDeep = Color(0xFFEFE8DC);
  static const Color surface = Color(0xFFFFFDFC);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF18222D);
  static const Color secondaryText = Color(0xFF607080);
  static const Color mutedText = Color(0xFF87919A);
  static const Color border = Color(0xFFDDD5C8);
  static const Color neutralSoft = Color(0xFFEFE8DC);

  // Legacy "mint" aliases resolve to Numuw moon gold.
  static const Color mint = Color(0xFFB98235);
  static const Color mintDark = Color(0xFF8F6125);
  static const Color mintLight = Color(0xFFF4E6CC);
  static const Color mintSoft = Color(0xFFEAD6B0);

  static const Color peach = Color(0xFFB96658);
  static const Color peachLight = Color(0xFFF6E5E1);
  static const Color danger = Color(0xFFB84F45);
  static const Color purple = Color(0xFF7C6A9A);
  static const Color purpleLight = Color(0xFFEDE8F3);
  static const Color yellow = Color(0xFFB98235);
  static const Color yellowLight = Color(0xFFF4E6CC);
  static const Color blue = Color(0xFF557F9A);
  static const Color blueLight = Color(0xFFE5EEF3);
  static const Color success = Color(0xFF4F8E73);
  static const Color successLight = Color(0xFFE4F0E9);

  // Dark mode — signature Moonlight Nursery.
  static const Color nightBackground = Color(0xFF0F1923);
  static const Color nightBackgroundDeep = Color(0xFF0B1119);
  static const Color nightSurface = Color(0xFF172130);
  static const Color nightSurfaceSoft = Color(0xFF1D283A);
  static const Color nightBorder = Color(0xFF263342);
  static const Color nightText = Color(0xFFF7F3EA);
  static const Color nightSecondaryText = Color(0xFFAAB4BE);
  static const Color nightMutedText = Color(0xFF74808D);
  static const Color nightGold = Color(0xFFE8B86D);
  static const Color nightGoldSoft = Color(0x24E8B86D);
  static const Color nightGoldSoftHigh = Color(0x38E8B86D);
  static const Color nightSuccess = Color(0xFF79B89C);
  static const Color nightSuccessSoft = Color(0x2479B89C);
  static const Color nightWarning = Color(0xFFD98C7C);
  static const Color nightWarningSoft = Color(0x24D98C7C);
  static const Color nightInfo = Color(0xFF7FA9C4);
  static const Color nightInfoSoft = Color(0x247FA9C4);

  // Extra-low-light tracking variation.
  static const Color logBackground = Color(0xFF090E15);
  static const Color logBackgroundDeep = Color(0xFF060A10);
  static const Color logSurface = Color(0xFF0E151F);
  static const Color logSurfaceElevated = Color(0xFF121B27);
  static const Color logBorder = Color(0xFF1B2531);
  static const Color logGold = Color(0xFFC9A063);
  static const Color logText = Color(0xFFDAD4C7);
  static const Color logSecondaryText = Color(0xFF8B95A0);

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
        ? const [nightSurfaceSoft, nightSurface]
        : const [surfaceElevated, surface],
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

  static const double input = 18;
  static const double button = 18;
  static const double card = 22;
  static const double largeCard = 28;
  static const double icon = 14;
  static const double pill = 999;
}

class NumuwMotion {
  const NumuwMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration screen = Duration(milliseconds: 250);
  static const Duration theme = Duration(milliseconds: 450);
  static const Duration toast = Duration(milliseconds: 2200);
}
