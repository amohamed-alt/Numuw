import 'package:flutter/material.dart';

import 'numuw_colors.dart';
import 'numuw_radius.dart';
import 'numuw_typography.dart';

ThemeData buildNumuwTheme({required bool night}) {
  final brightness = night ? Brightness.dark : Brightness.light;
  final background = night
      ? NumuwColorTokens.darkBackground
      : NumuwColorTokens.lightBackground;
  final surface = night
      ? NumuwColorTokens.darkSurface
      : NumuwColorTokens.lightSurface;
  final primary = night
      ? NumuwColorTokens.darkPrimary
      : NumuwColorTokens.lightPrimary;
  final primaryDark = night
      ? NumuwColorTokens.darkPrimary
      : NumuwColorTokens.lightPrimaryDark;
  final textPrimary = night
      ? NumuwColorTokens.darkTextPrimary
      : NumuwColorTokens.lightTextPrimary;
  final textSecondary = night
      ? NumuwColorTokens.darkTextSecondary
      : NumuwColorTokens.lightTextSecondary;
  final border = night
      ? NumuwColorTokens.darkBorder
      : NumuwColorTokens.lightBorder;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: background,
    fontFamily: NumuwTypography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: night
          ? NumuwColorTokens.darkPrimarySoft
          : NumuwColorTokens.lightPrimarySoft,
      surface: surface,
      outline: border,
      error: night ? NumuwColorTokens.darkError : NumuwColorTokens.lightError,
    ),
    textTheme: NumuwTypography.build(brightness),
    cardTheme: CardThemeData(
      color: surface,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.lg),
        side: BorderSide(color: border),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontFamily: NumuwTypography.fontFamily,
      ),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: TextStyle(color: textSecondary),
      labelStyle: TextStyle(color: textSecondary),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        borderSide: BorderSide(color: border, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        borderSide: BorderSide(color: border, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        borderSide: BorderSide(color: primaryDark, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        borderSide: BorderSide(
          color: night
              ? NumuwColorTokens.darkError
              : NumuwColorTokens.lightError,
          width: 1.4,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: night ? NumuwColorTokens.darkBackground : Colors.white,
        disabledBackgroundColor: night
            ? NumuwColorTokens.darkPrimarySoft
            : NumuwColorTokens.lightBorder,
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        backgroundColor: surface,
        side: BorderSide(color: border, width: 1.4),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}
