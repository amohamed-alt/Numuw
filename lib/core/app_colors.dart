import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color webBackground = Color(0xFFE8E2D7);
  static const Color background = Color(0xFFFBF8F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF252525);
  static const Color secondaryText = Color(0xFF77736F);
  static const Color mutedText = Color(0xFF9E9690);
  static const Color border = Color(0xFFEDE7E1);

  static const Color mint = Color(0xFF59B8A5);
  static const Color mintDark = Color(0xFF3D9E8C);
  static const Color mintLight = Color(0xFFE7F4F0);
  static const Color mintSoft = Color(0xFFD4EDE8);

  static const Color peach = Color(0xFFF3A26B);
  static const Color peachLight = Color(0xFFFDEBDF);
  static const Color danger = Color(0xFFE77A68);
  static const Color purple = Color(0xFF9B86D8);
  static const Color purpleLight = Color(0xFFF0EBFA);
  static const Color yellow = Color(0xFFE9BC5D);
  static const Color yellowLight = Color(0xFFFFF3D7);
  static const Color blue = Color(0xFF84B7D8);
  static const Color blueLight = Color(0xFFEAF4FA);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [mint, mintDark],
  );
}
