import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';
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
      : AppColors.surfaceRaised;
  final primary = night
      ? NumuwColorTokens.darkPrimary
      : NumuwColorTokens.lightPrimary;
  final primaryStrong = night
      ? AppColors.nightPrimaryStrong
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

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: night ? AppColors.nightBackground : Colors.white,
    primaryContainer: primarySoft,
    onPrimaryContainer: textPrimary,
    secondary: night ? AppColors.nightPrimaryStrong : AppColors.peach,
    onSecondary: night ? AppColors.nightBackground : Colors.white,
    secondaryContainer: night
        ? AppColors.nightSurfaceRaised
        : AppColors.peachLight,
    onSecondaryContainer: textPrimary,
    tertiary: night ? const Color(0xFFB9CBB9) : AppColors.sage,
    onTertiary: night ? AppColors.nightBackground : AppColors.text,
    tertiaryContainer: night
        ? const Color(0xFF29312C)
        : AppColors.sageSoft,
    onTertiaryContainer: textPrimary,
    error: error,
    onError: Colors.white,
    errorContainer: night ? const Color(0xFF3D2428) : AppColors.peachLight,
    onErrorContainer: textPrimary,
    surface: surface,
    onSurface: textPrimary,
    surfaceContainerHighest: elevatedSurface,
    onSurfaceVariant: textSecondary,
    outline: border,
    outlineVariant: night ? AppColors.nightBorderStrong : AppColors.borderStrong,
    shadow: const Color(0x22000000),
    scrim: const Color(0x66000000),
    inverseSurface: textPrimary,
    onInverseSurface: background,
    inversePrimary: primarySoft,
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
    splashFactory: InkRipple.splashFactory,
    highlightColor: primary.withValues(alpha: .045),
    splashColor: primary.withValues(alpha: .07),
    dividerColor: border,
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: night ? Colors.transparent : const Color(0x12442A34),
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
        fontWeight: FontWeight.w800,
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
        minimumSize: const Size(48, 54),
        backgroundColor: primaryStrong,
        foregroundColor: night ? AppColors.nightBackground : Colors.white,
        disabledBackgroundColor: night
            ? AppColors.nightSurfaceRaised
            : AppColors.border,
        disabledForegroundColor: textSecondary,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15.5,
          height: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NumuwRadiusTokens.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 54),
        foregroundColor: textPrimary,
        backgroundColor: surface,
        side: BorderSide(color: border, width: 1.2),
        elevation: 0,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15.5,
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
        night ? AppColors.nightBackground : Colors.white,
      ),
      side: BorderSide(color: border, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? (night ? AppColors.nightBackground : Colors.white)
            : textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primary : border,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: elevatedSurface,
      selectedColor: primarySoft,
      disabledColor: elevatedSurface.withValues(alpha: .5),
      side: BorderSide(color: border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NumuwRadiusTokens.pill),
      ),
      labelStyle: TextStyle(
        color: textPrimary,
        fontFamily: NumuwTypography.fontFamily,
        fontWeight: FontWeight.w700,
      ),
      secondaryLabelStyle: TextStyle(
        color: primaryStrong,
        fontFamily: NumuwTypography.fontFamily,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 8),
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
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: TextStyle(
        color: textSecondary,
        fontFamily: NumuwTypography.fontFamily,
        fontSize: 14,
        height: 1.6,
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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
