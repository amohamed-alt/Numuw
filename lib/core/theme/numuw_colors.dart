import 'package:flutter/material.dart';

class NumuwColorTokens {
  const NumuwColorTokens._();

  static const lightBackground = Color(0xFFFBF8F1);
  static const lightSurface = Color(0xFFFFFDF9);
  static const lightSurfaceSoft = Color(0xFFF6F0E7);
  static const lightPrimary = Color(0xFF74865B);
  static const lightPrimaryDark = Color(0xFF4F6242);
  static const lightPrimarySoft = Color(0xFFE5EAD9);
  static const lightClay = Color(0xFFC98E6D);
  static const lightClaySoft = Color(0xFFF0DDD1);
  static const lightMoon = Color(0xFFE7D7B2);
  static const lightLavenderSoft = Color(0xFFE7E1EF);
  static const lightTextPrimary = Color(0xFF37372F);
  static const lightTextSecondary = Color(0xFF7D7A70);
  static const lightBorder = Color(0xFFE7DED2);
  static const lightSuccess = Color(0xFF68846B);
  static const lightWarning = Color(0xFFC58B58);
  static const lightError = Color(0xFFBD6F68);
  static const lightWebBackground = Color(0xFFF3EDE3);

  static const darkBackground = Color(0xFF171B17);
  static const darkSurface = Color(0xFF222820);
  static const darkSurfaceElevated = Color(0xFF2A3128);
  static const darkPrimary = Color(0xFFA8B58E);
  static const darkPrimarySoft = Color(0xFF343D30);
  static const darkTextPrimary = Color(0xFFF5F1E8);
  static const darkTextSecondary = Color(0xFFBDB8AC);
  static const darkBorder = Color(0xFF394137);
  static const darkSuccess = Color(0xFF8FA690);
  static const darkWarning = Color(0xFFC2A171);
  static const darkError = Color(0xFFC8807A);
  static const darkWebBackground = Color(0xFF121512);

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
    colors: [Color(0x22E7D7B2), Colors.transparent],
    stops: [0.0, 1.0],
  );
}
