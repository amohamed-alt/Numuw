import 'package:flutter/animation.dart';

class NumuwMotionTokens {
  const NumuwMotionTokens._();

  static const Duration instant = Duration(milliseconds: 90);
  static const Duration button = Duration(milliseconds: 120);
  static const Duration chip = Duration(milliseconds: 160);
  static const Duration card = Duration(milliseconds: 280);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration bottomSheet = Duration(milliseconds: 320);
  static const Duration success = Duration(milliseconds: 580);
  static const Duration celebration = Duration(milliseconds: 760);
  static const Duration toast = Duration(milliseconds: 2200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve enter = Curves.easeOutBack;
  static const Curve gentle = Curves.easeInOutCubic;
}

/// Emotional growth stages used by success moments. The animation is subtle by
/// design: Numuw should feel reassuring, not gamified.
abstract class NumuwGrowthAnimationController {
  void showSeed();
  void showSprout();
  void growLeaf();
  void showSuccess();
}

class NoopNumuwGrowthAnimationController
    implements NumuwGrowthAnimationController {
  const NoopNumuwGrowthAnimationController();

  @override
  void growLeaf() {}

  @override
  void showSeed() {}

  @override
  void showSprout() {}

  @override
  void showSuccess() {}
}
