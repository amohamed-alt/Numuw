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
          bodyLarge: const TextStyle(fontSize: 16, height: 1.55),
          bodyMedium: TextStyle(fontSize: 14, height: 1.55, color: secondary),
          bodySmall: TextStyle(fontSize: 12, height: 1.45, color: secondary),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: primary,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: primary,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: primary,
          ),
        );
  }
}
