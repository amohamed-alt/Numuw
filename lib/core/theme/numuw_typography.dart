import 'package:flutter/material.dart';

import 'numuw_colors.dart';

class NumuwTypography {
  const NumuwTypography._();

  static const fontFamily = 'Cairo';

  static TextTheme build(Brightness brightness) {
    final night = brightness == Brightness.dark;
    final primary = night
        ? NumuwColorTokens.darkTextPrimary
        : NumuwColorTokens.lightTextPrimary;
    final secondary = night
        ? NumuwColorTokens.darkTextSecondary
        : NumuwColorTokens.lightTextSecondary;

    return Typography.material2021().black
        .apply(
          fontFamily: fontFamily,
          bodyColor: primary,
          displayColor: primary,
        )
        .copyWith(
          displaySmall: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.18,
            letterSpacing: -.35,
            color: primary,
          ),
          headlineSmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.22,
            letterSpacing: -.2,
            color: primary,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.28,
            color: primary,
          ),
          titleMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.35,
            color: primary,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: primary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.65,
            color: primary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.6,
            color: secondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.55,
            color: secondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: primary,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: secondary,
          ),
        );
  }
}
