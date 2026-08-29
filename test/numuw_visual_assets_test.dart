import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/design/numuw_visual_assets.dart';

void main() {
  group('NumuwVisualAsset', () {
    test('resolves dedicated light and dark artwork deterministically', () {
      const asset = NumuwVisualAsset(
        lightPath: 'assets/organic/light/example.webp',
        darkPath: 'assets/organic/dark/example.webp',
        fallbackIcon: NumuwOrganicIconName.sleep,
      );

      expect(asset.resolve(Brightness.light), asset.lightPath);
      expect(asset.resolve(Brightness.dark), asset.darkPath);
      expect(asset.hasDedicatedDarkAsset, isTrue);
    });

    test('falls back to light artwork when no dark variant is supplied', () {
      const asset = NumuwVisualAsset(
        lightPath: 'assets/organic/light/example.webp',
        fallbackIcon: NumuwOrganicIconName.bottle,
      );

      expect(asset.resolve(Brightness.light), asset.lightPath);
      expect(asset.resolve(Brightness.dark), asset.lightPath);
      expect(asset.hasDedicatedDarkAsset, isFalse);
    });

    test('canonical illustrated assets have explicit night variants', () {
      for (final asset in NumuwVisualAssets.all) {
        expect(asset.lightPath, startsWith('assets/organic/light/'));
        expect(asset.darkPath, startsWith('assets/organic/dark/'));
        expect(asset.hasDedicatedDarkAsset, isTrue);
      }
    });
  });
}
