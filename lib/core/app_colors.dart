import 'package:flutter/material.dart';

/// Numuw's product palette.
///
/// The visual direction is intentionally maternal without becoming childish:
/// warm porcelain surfaces, rosewood/plum accents, blush, champagne, sage and
/// lavender. The night palette is true near-black with restrained rose accents
/// for low-glare one-handed use.
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------------
  // Light / porcelain foundation
  // ---------------------------------------------------------------------------
  static const Color webBackground = Color(0xFFF2EAE7);
  static const Color background = Color(0xFFFBF7F5);
  static const Color surface = Color(0xFFFFFDFC);
  static const Color surfaceRaised = Color(0xFFFFFAF8);
  static const Color surfaceTint = Color(0xFFF8EFED);
  static const Color text = Color(0xFF2A2427);
  static const Color secondaryText = Color(0xFF766A70);
  static const Color mutedText = Color(0xFFA2969B);
  static const Color border = Color(0xFFEADFDA);
  static const Color borderStrong = Color(0xFFD8C8C5);
  static const Color neutralSoft = Color(0xFFF6EFEC);

  // ---------------------------------------------------------------------------
  // Brand — rosewood / plum
  // ---------------------------------------------------------------------------
  static const Color plum = Color(0xFF9D4F72);
  static const Color plumDark = Color(0xFF71384F);
  static const Color plumDeep = Color(0xFF512B3D);
  static const Color plumSoft = Color(0xFFE9CBD7);
  static const Color roseMist = Color(0xFFF5E4E8);
  static const Color blush = Color(0xFFEFCFD1);
  static const Color blushSoft = Color(0xFFFAEFF0);
  static const Color champagne = Color(0xFFEAD6B8);
  static const Color champagneSoft = Color(0xFFF8EFE1);
  static const Color sage = Color(0xFFA9BBAA);
  static const Color sageSoft = Color(0xFFEAF0E9);
  static const Color lavender = Color(0xFFCBBBD5);
  static const Color lavenderSoft = Color(0xFFF2EDF5);
  static const Color powder = Color(0xFFB7CED8);
  static const Color powderSoft = Color(0xFFEDF4F6);

  // Compatibility aliases used by the existing application. Keeping these
  // names lets the redesign flow through all current screens without breaking
  // business logic while the component migration happens incrementally.
  static const Color mint = plum;
  static const Color mintDark = plumDark;
  static const Color mintLight = roseMist;
  static const Color mintSoft = plumSoft;

  static const Color peach = Color(0xFFC78772);
  static const Color peachLight = Color(0xFFF5E2DB);
  static const Color danger = Color(0xFFB65862);
  static const Color purple = lavender;
  static const Color purpleLight = lavenderSoft;
  static const Color yellow = champagne;
  static const Color yellowLight = champagneSoft;
  static const Color blue = powder;
  static const Color blueLight = powderSoft;

  // ---------------------------------------------------------------------------
  // Black / night foundation
  // ---------------------------------------------------------------------------
  static const Color nightWebBackground = Color(0xFF09090B);
  static const Color nightBackground = Color(0xFF0F1012);
  static const Color nightSurface = Color(0xFF17181C);
  static const Color nightSurfaceSoft = Color(0xFF202126);
  static const Color nightSurfaceRaised = Color(0xFF26272D);
  static const Color nightBorder = Color(0xFF34343B);
  static const Color nightBorderStrong = Color(0xFF484650);
  static const Color nightText = Color(0xFFF8F2F3);
  static const Color nightSecondaryText = Color(0xFFC4B9BD);
  static const Color nightMutedText = Color(0xFF8C8488);
  static const Color nightGold = Color(0xFFD7A3B6);
  static const Color nightGoldSoft = Color(0x33202026);
  static const Color nightPrimary = Color(0xFFD7A3B6);
  static const Color nightPrimaryStrong = Color(0xFFE1B0C0);
  static const Color nightPrimarySoft = Color(0xFF3B2932);

  // ---------------------------------------------------------------------------
  // Semantic colors
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF6F9276);
  static const Color warning = Color(0xFFC58B58);
  static const Color info = Color(0xFF6D8FA2);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [plum, plumDark],
  );

  static const LinearGradient maternalGlow = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFFFFBF9), Color(0xFFF8EBED)],
  );

  static const LinearGradient childHeroGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFFBEDEE), Color(0xFFF2E7E1), Color(0xFFF7F1EA)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [nightSurfaceRaised, nightBackground],
  );

  static const RadialGradient subtleRoseGlow = RadialGradient(
    center: AlignmentDirectional.topStart,
    radius: 1.15,
    colors: [Color(0x24D7A3B6), Colors.transparent],
  );
}

class NumuwSpacing {
  const NumuwSpacing._();

  static const double pageX = 20;
  static const double pageTop = 18;
  static const double card = 18;
  static const double gap2xs = 4;
  static const double gapXs = 6;
  static const double gapSm = 10;
  static const double gapMd = 14;
  static const double gapLg = 18;
  static const double gapXl = 24;
  static const double gap2xl = 32;
  static const double mobileWidth = 390;
  static const double maxMobileWidth = 430;
  static const double minimumTapTarget = 48;
}

class NumuwRadius {
  const NumuwRadius._();

  static const double compact = 12;
  static const double input = 15;
  static const double button = 17;
  static const double card = 20;
  static const double largeCard = 26;
  static const double hero = 30;
  static const double icon = 18;
  static const double pill = 999;
}

class NumuwMotion {
  const NumuwMotion._();

  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration button = Duration(milliseconds: 120);
  static const Duration card = Duration(milliseconds: 280);
  static const Duration screen = Duration(milliseconds: 300);
  static const Duration bottomSheet = Duration(milliseconds: 320);
  static const Duration success = Duration(milliseconds: 580);
  static const Duration toast = Duration(milliseconds: 2200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve gentle = Curves.easeInOutCubic;
}

class NumuwElevation {
  const NumuwElevation._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D442A34),
      blurRadius: 24,
      offset: Offset(0, 9),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x17442A34),
      blurRadius: 32,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> none = [];
}
