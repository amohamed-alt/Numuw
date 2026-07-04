import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../auth/auth_gate.dart';
import '../screens/design_preview/design_preview_gallery.dart';
import '../state/app_preferences.dart';
import 'theme/numuw_colors.dart';
import 'theme/numuw_theme.dart';

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
          title: 'Ù†ÙÙ…ÙÙˆÙ‘',
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: buildNumuwTheme(night: night),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: ColoredBox(
              color: night
                  ? NumuwColorTokens.darkWebBackground
                  : NumuwColorTokens.lightWebBackground,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ColoredBox(
                    color: night
                        ? NumuwColorTokens.darkBackground
                        : NumuwColorTokens.lightBackground,
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
}
