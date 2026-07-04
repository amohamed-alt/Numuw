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
  final elevatedSurface = night
      ? NumuwColorTokens.darkSurfaceElevated
      : NumuwColorTokens.lightSurfaceSoft;
  final primary = night
      ? NumuwColorTokens.darkPrimary
      : NumuwColorTokens.lightPrimary;
  final primaryStrong = night
      ? NumuwColorTokens.darkPrimary
      : NumuwColorTokens.lightPrimaryDark;
  final primarySoft = night
      ? NumuwColorTokens.darkPrimarySoft
      : NumuwColorTokens.lightPrimarySoft;
  final textPrimary = night
      ? NumuwColorTokens.darkTextPrimary
      : NumuwColorTokens.lightTextPrimary;
  final textSecondary = night
      ? NumuwColorTokens.darkTextSecondary
      : NumuwColorTokens.lightTextSecondary;
  final border = night
      ? NumuwColorTokens.darkBorder
      : NumuwColorTokens.lightBorder;
  final error = night
      ? NumuwColorTokens.darkError
      : NumuwColorTokens.lightError;

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    primary: primary,
    onPrimary: night ? NumuwColorTokens.darkBackground : Colors.white,
    secondary: primarySoft,
    onSecondary: textPrimary,
    surface: surface,
    onSurface: textPrimary,
    outline: border,
    error: error,
    onError: Colors.white,
  );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
    borderSide: BorderSide(color: border, width: 1.2),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    fontFamily: NumuwTypography.fontFamily,
    colorScheme: scheme,
    textTheme: NumuwTypography.build(brightness),
    splashFactory: InkSparkle.splashFactory,
    highlightColor: primary.withValues(alpha: .06),
    splashColor: primary.withValues(alpha: .08),
    dividerColor: border,
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: night ? Colors.transparent : const Color(0x12000000),
      elevation: night ? 0 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.lg),
        side: BorderSide(color: border),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary, size: 22),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontFamily: NumuwTypography.fontFamily,
        height: 1.25,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: TextStyle(color: textSecondary, fontSize: 14),
      labelStyle: TextStyle(color: textSecondary, fontSize: 14),
      floatingLabelStyle: TextStyle(
        color: primaryStrong,
        fontWeight: FontWeight.w700,
      ),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: primary, width: 1.8),
      ),
      disabledBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: border.withValues(alpha: .55)),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: error, width: 1.4),
      ),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: error, width: 1.8),
      ),
      errorStyle: TextStyle(color: error, height: 1.35),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        backgroundColor: primaryStrong,
        foregroundColor: night ? NumuwColorTokens.darkBackground : Colors.white,
        disabledBackgroundColor: night
            ? NumuwColorTokens.darkPrimarySoft
            : NumuwColorTokens.lightBorder,
        disabledForegroundColor: textSecondary,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          height: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        foregroundColor: textPrimary,
        backgroundColor: surface,
        side: BorderSide(color: border, width: 1.2),
        elevation: 0,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          height: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: primaryStrong,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NumuwRadiusTokens.sm),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: textPrimary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NumuwRadiusTokens.sm),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primary : surface,
      ),
      checkColor: WidgetStatePropertyAll(
        night ? NumuwColorTokens.darkBackground : Colors.white,
      ),
      side: BorderSide(color: border, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? (night ? NumuwColorTokens.darkBackground : Colors.white)
            : textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primary : border,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: night ? 0 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.xl),
        side: BorderSide(color: border),
      ),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontFamily: NumuwTypography.fontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w900,
      ),
      contentTextStyle: TextStyle(
        color: textSecondary,
        fontFamily: NumuwTypography.fontFamily,
        fontSize: 14,
        height: 1.55,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      modalBackgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: border,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NumuwRadiusTokens.xl),
        ),
        side: BorderSide(color: border),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: elevatedSurface,
      contentTextStyle: TextStyle(
        color: textPrimary,
        fontFamily: NumuwTypography.fontFamily,
        fontWeight: FontWeight.w700,
      ),
      actionTextColor: primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        side: BorderSide(color: border),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
      circularTrackColor: border,
    ),
  );
}
