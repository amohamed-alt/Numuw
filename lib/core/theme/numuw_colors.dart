import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Theme-facing color tokens. Values are sourced from [AppColors] so the
/// legacy widgets and the Material theme stay visually identical.
class NumuwColorTokens {
  const NumuwColorTokens._();

  static const lightBackground = AppColors.background;
  static const lightSurface = AppColors.surface;
  static const lightSurfaceSoft = AppColors.neutralSoft;
  static const lightPrimary = AppColors.plum;
  static const lightPrimaryDark = AppColors.plumDark;
  static const lightPrimarySoft = AppColors.roseMist;
  static const lightClay = AppColors.peach;
  static const lightClaySoft = AppColors.peachLight;
  static const lightMoon = AppColors.champagne;
  static const lightLavenderSoft = AppColors.lavenderSoft;
  static const lightTextPrimary = AppColors.text;
  static const lightTextSecondary = AppColors.secondaryText;
  static const lightBorder = AppColors.border;
  static const lightSuccess = AppColors.success;
  static const lightWarning = AppColors.warning;
  static const lightError = AppColors.danger;
  static const lightWebBackground = AppColors.webBackground;

  static const darkBackground = AppColors.nightBackground;
  static const darkSurface = AppColors.nightSurface;
  static const darkSurfaceElevated = AppColors.nightSurfaceRaised;
  static const darkPrimary = AppColors.nightPrimary;
  static const darkPrimarySoft = AppColors.nightPrimarySoft;
  static const darkTextPrimary = AppColors.nightText;
  static const darkTextSecondary = AppColors.nightSecondaryText;
  static const darkBorder = AppColors.nightBorder;
  static const darkSuccess = Color(0xFF92B197);
  static const darkWarning = Color(0xFFD2AA78);
  static const darkError = Color(0xFFD7868E);
  static const darkWebBackground = AppColors.nightWebBackground;

  static const primaryGradient = AppColors.primaryGradient;

  static const clayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.peachLight, AppColors.champagneSoft],
  );

  static const nightGradient = AppColors.nightGradient;
  static const botanicalGlow = AppColors.subtleRoseGlow;
}
