import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/design_preview/numuw_master_preview.dart';

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
      title: 'Numuw Master Preview',
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
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: media.copyWith(textScaler: const TextScaler.linear(.94)),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const NumuwMasterPreview(initialDark: _darkMode),
    );
  }
}
