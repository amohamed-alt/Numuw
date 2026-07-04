class NumuwMotionTokens {
  const NumuwMotionTokens._();

  static const Duration button = Duration(milliseconds: 120);
  static const Duration card = Duration(milliseconds: 280);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration success = Duration(milliseconds: 580);
  static const Duration bottomSheet = Duration(milliseconds: 320);
  static const Duration toast = Duration(milliseconds: 2200);
}

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
