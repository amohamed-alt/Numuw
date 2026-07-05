import 'package:flutter/material.dart';

class NumuwColorTokens {
  const NumuwColorTokens._();

  // Light mode
  static const lightBackground = Color(0xFFF7F3EA);
  static const lightSurface = Color(0xFFFFFDFC);
  static const lightSurfaceSoft = Color(0xFFEFE8DC);
  static const lightPrimary = Color(0xFFB98235);
  static const lightPrimaryDark = Color(0xFF8F6125);
  static const lightPrimarySoft = Color(0xFFF4E6CC);
  static const lightClay = Color(0xFFB96658);
  static const lightClaySoft = Color(0xFFF6E5E1);
  static const lightMoon = Color(0xFFEAD5AE);
  static const lightLavenderSoft = Color(0xFFEDE8F3);
  static const lightTextPrimary = Color(0xFF18222D);
  static const lightTextSecondary = Color(0xFF607080);
  static const lightBorder = Color(0xFFDDD5C8);
  static const lightSuccess = Color(0xFF4F8E73);
  static const lightWarning = Color(0xFFB96658);
  static const lightError = Color(0xFFB84F45);
  static const lightWebBackground = Color(0xFFEFE8DC);

  // Dark mode
  static const darkBackground = Color(0xFF0F1923);
  static const darkSurface = Color(0xFF172130);
  static const darkSurfaceElevated = Color(0xFF1D283A);
  static const darkPrimary = Color(0xFFE8B86D);
  static const darkPrimarySoft = Color(0xFF332A1E);
  static const darkTextPrimary = Color(0xFFF7F3EA);
  static const darkTextSecondary = Color(0xFFAAB4BE);
  static const darkBorder = Color(0xFF263342);
  static const darkSuccess = Color(0xFF79B89C);
  static const darkWarning = Color(0xFFD98C7C);
  static const darkError = Color(0xFFE08C82);
  static const darkWebBackground = Color(0xFF0B1119);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPrimary, lightPrimaryDark],
  );

  static const clayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightClaySoft, lightMoon],
  );

  static const nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurfaceElevated, darkBackground],
  );

  static const botanicalGlow = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.1,
    colors: [Color(0x2EE8B86D), Colors.transparent],
    stops: [0.0, 1.0],
  );
}
