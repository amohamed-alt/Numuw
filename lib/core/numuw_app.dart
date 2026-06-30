import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../auth/auth_gate.dart';
import '../screens/design_preview/design_preview_gallery.dart';
import '../state/app_preferences.dart';
import 'app_colors.dart';

class NumuwApp extends StatelessWidget {
  const NumuwApp({super.key, this.startupError});

  final String? startupError;
  static const bool designPreview = bool.fromEnvironment('DESIGN_PREVIEW');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppPreferences.instance,
      builder: (context, _) {
        final night = AppPreferences.instance.nightMode;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'نُمُوّ',
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: _theme(night),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: ColoredBox(
              color: night
                  ? AppColors.nightBackground
                  : AppColors.webBackground,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: NumuwSpacing.maxMobileWidth,
                  ),
                  child: ColoredBox(
                    color: night
                        ? AppColors.nightBackground
                        : AppColors.background,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          home: designPreview
              ? const DesignPreviewGallery()
              : AuthGate(startupError: startupError),
        );
      },
    );
  }

  ThemeData _theme(bool night) {
    final background = night ? AppColors.nightBackground : AppColors.background;
    final surface = night ? AppColors.nightSurface : AppColors.surface;
    final text = night ? AppColors.nightText : AppColors.text;
    final secondary = night
        ? AppColors.nightSecondaryText
        : AppColors.secondaryText;
    final accent = night ? AppColors.nightGold : AppColors.mint;
    return ThemeData(
      useMaterial3: true,
      brightness: night ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: night ? Brightness.dark : Brightness.light,
        surface: surface,
      ),
      textTheme: Typography.material2021().black.apply(
        fontFamily: 'Cairo',
        bodyColor: text,
        displayColor: text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: night ? AppColors.nightBackground : Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NumuwRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: secondary),
        hintStyle: TextStyle(color: secondary),
      ),
    );
  }
}
