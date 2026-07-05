import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/design_preview/pixel_perfect_home_screen.dart';

const bool _darkMode = bool.fromEnvironment('PIXEL_DARK');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _NumuwPixelPreviewApp());
}

class _NumuwPixelPreviewApp extends StatelessWidget {
  const _NumuwPixelPreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Numuw Pixel Preview',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: _darkMode ? Brightness.dark : Brightness.light,
        fontFamily: 'Cairo',
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final preview = child ?? const SizedBox.shrink();
            if (constraints.maxWidth < 700) return preview;
            return ColoredBox(
              color: _darkMode
                  ? const Color(0xFF121512)
                  : const Color(0xFFF3EDE3),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: preview,
                ),
              ),
            );
          },
        ),
      ),
      home: const NumuwPixelHomeScreen(darkMode: _darkMode),
    );
  }
}
