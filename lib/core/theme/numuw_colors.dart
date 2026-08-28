import 'package:flutter/material.dart';

/// Semantic Numuw colors mirrored from the Figma Make source of truth.
///
/// Dark is the signature "Moonlight Nursery" theme. Light is warm daylight;
/// Night Logging is an extra-low-light variation used only by feeding, sleep,
/// and diaper tracking screens.
class NumuwColorTokens {
  const NumuwColorTokens._();

  // Light mode — warm morning light, never clinical white.
  static const lightBackground = Color(0xFFF7F3EA);
  static const lightBackgroundDeep = Color(0xFFEFE8DC);
  static const lightSurface = Color(0xFFFFFDFC);
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  // Compatibility alias used by the existing ThemeData builder.
  static const lightSurfaceSoft = lightSurfaceElevated;
  static const lightPrimary = Color(0xFFB98235);
  static const lightPrimaryDark = Color(0xFF8F6125);
  static const lightPrimarySoft = Color(0xFFF4E6CC);
  static const lightPrimarySoftHigh = Color(0xFFEAD6B0);
  static const lightTextPrimary = Color(0xFF18222D);
  static const lightTextSecondary = Color(0xFF607080);
  static const lightTextMuted = Color(0xFF87919A);
  static const lightBorder = Color(0xFFDDD5C8);
  static const lightSuccess = Color(0xFF4F8E73);
  static const lightSuccessSoft = Color(0xFFE4F0E9);
  static const lightWarning = Color(0xFFB96658);
  static const lightWarningSoft = Color(0xFFF6E5E1);
  static const lightInfo = Color(0xFF557F9A);
  static const lightInfoSoft = Color(0xFFE5EEF3);
  static const lightError = Color(0xFFB84F45);
  static const lightWebBackground = Color(0xFFEFE8DC);
  static const lightShadow = Color(0x1F503E1E);

  // Dark mode — Moonlight Nursery.
  static const darkBackground = Color(0xFF0F1923);
  static const darkBackgroundDeep = Color(0xFF0B1119);
  static const darkSurface = Color(0xFF172130);
  static const darkSurfaceElevated = Color(0xFF1D283A);
  static const darkPrimary = Color(0xFFE8B86D);
  static const darkPrimarySoft = Color(0x24E8B86D);
  static const darkPrimarySoftHigh = Color(0x38E8B86D);
  static const darkTextPrimary = Color(0xFFF7F3EA);
  static const darkTextSecondary = Color(0xFFAAB4BE);
  static const darkTextMuted = Color(0xFF74808D);
  static const darkBorder = Color(0xFF263342);
  static const darkSuccess = Color(0xFF79B89C);
  static const darkSuccessSoft = Color(0x2479B89C);
  static const darkWarning = Color(0xFFD98C7C);
  static const darkWarningSoft = Color(0x24D98C7C);
  static const darkInfo = Color(0xFF7FA9C4);
  static const darkInfoSoft = Color(0x247FA9C4);
  static const darkError = Color(0xFFE08C82);
  static const darkWebBackground = Color(0xFF0B1119);
  static const darkShadow = Color(0x47000000);

  // Night Logging — scoped low-light variation of Dark.
  static const logBackground = Color(0xFF090E15);
  static const logBackgroundDeep = Color(0xFF060A10);
  static const logSurface = Color(0xFF0E151F);
  static const logSurfaceElevated = Color(0xFF121B27);
  static const logPrimary = Color(0xFFC9A063);
  static const logTextPrimary = Color(0xFFDAD4C7);
  static const logTextSecondary = Color(0xFF8B95A0);
  static const logTextMuted = Color(0xFF5E6A76);
  static const logBorder = Color(0xFF1B2531);
  static const logSuccess = Color(0xFF6BA189);
  static const logWarning = Color(0xFFC0806F);
  static const logInfo = Color(0xFF7098B0);

  static const primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [lightPrimary, lightPrimaryDark],
  );

  static const nightGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [darkSurfaceElevated, darkBackground],
  );

  static const botanicalGlow = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.1,
    colors: [Color(0x2EE8B86D), Colors.transparent],
    stops: [0.0, 1.0],
  );
}
