import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../auth/auth_gate.dart';
import '../screens/design_preview/full/preview_home.dart';
import '../screens/design_preview/full_app_preview.dart';
import '../state/app_preferences.dart';
import 'theme/numuw_colors.dart';
import 'theme/numuw_theme.dart';

class NumuwApp extends StatelessWidget {
  const NumuwApp({super.key, this.startupError});

  final String? startupError;
  static const bool designPreview = bool.fromEnvironment('DESIGN_PREVIEW');
  static const bool homePreview = bool.fromEnvironment('HOME_PREVIEW');
  static const bool darkPreview = bool.fromEnvironment('DARK_PREVIEW');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppPreferences.instance,
      builder: (context, _) {
        final night = designPreview && homePreview
            ? darkPreview
            : AppPreferences.instance.nightMode;
        final appBackground = night
            ? NumuwColorTokens.darkBackground
            : NumuwColorTokens.lightBackground;
        final desktopBackground = night
            ? NumuwColorTokens.darkWebBackground
            : NumuwColorTokens.lightWebBackground;

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
          theme: buildNumuwTheme(night: night),
          themeAnimationDuration: const Duration(milliseconds: 240),
          themeAnimationCurve: Curves.easeOutCubic,
          builder: (context, child) {
            final app = Directionality(
              textDirection: TextDirection.rtl,
              child: ColoredBox(
                color: appBackground,
                child: child ?? const SizedBox.shrink(),
              ),
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 700) {
                  return app;
                }

                return ColoredBox(
                  color: desktopBackground,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: appBackground,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x24000000),
                              blurRadius: 36,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: app,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          home: designPreview
              ? (homePreview
                    ? PreviewHomeScreen(black: darkPreview)
                    : const FullAppPreview())
              : AuthGate(startupError: startupError),
        );
      },
    );
  }
}
