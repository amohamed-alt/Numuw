import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/design_preview/pixel_home_fixed_v2.dart';

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
        child: child ?? const SizedBox.shrink(),
      ),
      home: const NumuwPixelHomeFixedV2(darkMode: _darkMode),
    );
  }
}
