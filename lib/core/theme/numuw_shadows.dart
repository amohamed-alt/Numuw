import 'package:flutter/material.dart';

class NumuwShadows {
  const NumuwShadows._();

  static List<BoxShadow> surface(bool night) => night
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0E3E392C),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ];

  static List<BoxShadow> elevated(bool night) => night
      ? const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x143E392C),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ];

  static List<BoxShadow> button(bool night) => night
      ? const []
      : const [
          BoxShadow(
            color: Color(0x224E6242),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ];
}
