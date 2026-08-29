import 'package:flutter/material.dart';

import 'numuw_organic_icons.dart';

enum NumuwVisualAssetKind { svg, raster }

@immutable
class NumuwVisualAsset {
  const NumuwVisualAsset({
    required this.lightPath,
    required this.fallbackIcon,
    this.darkPath,
    this.kind = NumuwVisualAssetKind.raster,
  });

  final String lightPath;
  final String? darkPath;
  final NumuwVisualAssetKind kind;
  final NumuwOrganicIconName fallbackIcon;

  String resolve(Brightness brightness) {
    if (brightness == Brightness.dark && darkPath != null) {
      return darkPath!;
    }
    return lightPath;
  }

  bool get hasDedicatedDarkAsset => darkPath != null;
}

/// Canonical paths for the approved Natural Organic illustrated asset system.
///
/// Detailed artwork is intentionally raster-first (PNG/WebP) to preserve the
/// soft watercolor/shading of the approved visual reference. Utility icons stay
/// in [NumuwOrganicIcon]. Every illustrated asset has an SVG fallback so the UI
/// remains functional while binary artwork is being exported or if an asset is
/// missing from a release bundle.
abstract final class NumuwVisualAssets {
  static const breastfeeding = NumuwVisualAsset(
    lightPath: 'assets/organic/light/breastfeeding.webp',
    darkPath: 'assets/organic/dark/breastfeeding.webp',
    fallbackIcon: NumuwOrganicIconName.breastfeeding,
  );
  static const bottle = NumuwVisualAsset(
    lightPath: 'assets/organic/light/bottle.webp',
    darkPath: 'assets/organic/dark/bottle.webp',
    fallbackIcon: NumuwOrganicIconName.bottle,
  );
  static const sleep = NumuwVisualAsset(
    lightPath: 'assets/organic/light/sleep.webp',
    darkPath: 'assets/organic/dark/sleep.webp',
    fallbackIcon: NumuwOrganicIconName.sleep,
  );
  static const diaper = NumuwVisualAsset(
    lightPath: 'assets/organic/light/diaper.webp',
    darkPath: 'assets/organic/dark/diaper.webp',
    fallbackIcon: NumuwOrganicIconName.diaper,
  );
  static const food = NumuwVisualAsset(
    lightPath: 'assets/organic/light/food.webp',
    darkPath: 'assets/organic/dark/food.webp',
    fallbackIcon: NumuwOrganicIconName.food,
  );
  static const medicine = NumuwVisualAsset(
    lightPath: 'assets/organic/light/medicine.webp',
    darkPath: 'assets/organic/dark/medicine.webp',
    fallbackIcon: NumuwOrganicIconName.medicine,
  );
  static const vaccine = NumuwVisualAsset(
    lightPath: 'assets/organic/light/vaccine.webp',
    darkPath: 'assets/organic/dark/vaccine.webp',
    fallbackIcon: NumuwOrganicIconName.vaccine,
  );
  static const temperature = NumuwVisualAsset(
    lightPath: 'assets/organic/light/temperature.webp',
    darkPath: 'assets/organic/dark/temperature.webp',
    fallbackIcon: NumuwOrganicIconName.temperature,
  );
  static const pregnancy = NumuwVisualAsset(
    lightPath: 'assets/organic/light/pregnancy.webp',
    darkPath: 'assets/organic/dark/pregnancy.webp',
    fallbackIcon: NumuwOrganicIconName.pregnancy,
  );
  static const newborn = NumuwVisualAsset(
    lightPath: 'assets/organic/light/newborn.webp',
    darkPath: 'assets/organic/dark/newborn.webp',
    fallbackIcon: NumuwOrganicIconName.newborn,
  );
  static const family = NumuwVisualAsset(
    lightPath: 'assets/organic/light/family.webp',
    darkPath: 'assets/organic/dark/family.webp',
    fallbackIcon: NumuwOrganicIconName.family,
  );
  static const father = NumuwVisualAsset(
    lightPath: 'assets/organic/light/father.webp',
    darkPath: 'assets/organic/dark/father.webp',
    fallbackIcon: NumuwOrganicIconName.father,
  );
  static const aiAssistant = NumuwVisualAsset(
    lightPath: 'assets/organic/light/ai_assistant.webp',
    darkPath: 'assets/organic/dark/ai_assistant.webp',
    fallbackIcon: NumuwOrganicIconName.aiAssistant,
  );
  static const success = NumuwVisualAsset(
    lightPath: 'assets/organic/light/success.webp',
    darkPath: 'assets/organic/dark/success.webp',
    fallbackIcon: NumuwOrganicIconName.done,
  );

  static const all = <NumuwVisualAsset>[
    breastfeeding,
    bottle,
    sleep,
    diaper,
    food,
    medicine,
    vaccine,
    temperature,
    pregnancy,
    newborn,
    family,
    father,
    aiAssistant,
    success,
  ];
}

class NumuwAdaptiveArtwork extends StatelessWidget {
  const NumuwAdaptiveArtwork({
    required this.asset,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.fallbackSize,
  });

  final NumuwVisualAsset asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String? semanticLabel;
  final double? fallbackSize;

  @override
  Widget build(BuildContext context) {
    final path = asset.resolve(Theme.of(context).brightness);
    final resolvedFallbackSize = fallbackSize ?? width ?? height ?? 32;

    Widget fallback() => Center(
      child: NumuwOrganicIcon(
        asset.fallbackIcon,
        size: resolvedFallbackSize,
        semanticLabel: semanticLabel,
      ),
    );

    // SVG artwork remains supported for hand-authored vector illustrations,
    // while approved watercolor artwork is exported as WebP/PNG.
    if (asset.kind == NumuwVisualAssetKind.svg) {
      // The canonical icon system is the safe SVG fallback until an external
      // SVG asset renderer is needed for a specific approved illustration.
      return SizedBox(width: width, height: height, child: fallback());
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      errorBuilder: (context, error, stackTrace) => fallback(),
    );
  }
}
