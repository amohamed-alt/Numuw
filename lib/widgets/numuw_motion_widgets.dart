import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_colors.dart';
import '../core/theme/numuw_motion.dart';

/// Central accessibility gate for Numuw motion.
///
/// Keep meaningful state changes, but remove decorative movement when the
/// operating system asks the app to reduce/disable animations.
class NumuwMotionPolicy {
  const NumuwMotionPolicy._();

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Press feedback used for primary actions, quick-log controls and tappable
/// cards. It deliberately uses scale only; no bounce-heavy game-like motion.
class NumuwPressable extends StatefulWidget {
  const NumuwPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = .985,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius borderRadius;

  @override
  State<NumuwPressable> createState() => _NumuwPressableState();
}

class _NumuwPressableState extends State<NumuwPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: widget.onTap,
    onTapDown: (_) => _setPressed(true),
    onTapUp: (_) => _setPressed(false),
    onTapCancel: () => _setPressed(false),
    child: AnimatedScale(
      scale: _pressed && !NumuwMotionPolicy.reduceMotion(context)
          ? widget.scale
          : 1,
      duration: NumuwMotionPolicy.reduceMotion(context)
          ? Duration.zero
          : NumuwMotionTokens.button,
      curve: NumuwMotionTokens.standard,
      child: widget.child,
    ),
  );
}

/// Standard classy entrance animation.
///
/// Backed by flutter_animate to keep screen code concise and consistent while
/// preserving the timings already established by the Numuw design system.
class NumuwFadeSlideIn extends StatelessWidget {
  const NumuwFadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, .035),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    if (NumuwMotionPolicy.reduceMotion(context)) return child;

    return Animate(
      delay: delay,
      effects: <Effect<dynamic>>[
        FadeEffect(
          duration: NumuwMotionTokens.card,
          curve: NumuwMotionTokens.standard,
        ),
        SlideEffect(
          begin: offset,
          end: Offset.zero,
          duration: NumuwMotionTokens.card,
          curve: NumuwMotionTokens.standard,
        ),
      ],
      child: child,
    );
  }
}

class NumuwPulseDot extends StatefulWidget {
  const NumuwPulseDot({
    super.key,
    this.color = AppColors.plum,
    this.size = 8,
    this.active = true,
  });

  final Color color;
  final double size;
  final bool active;

  @override
  State<NumuwPulseDot> createState() => _NumuwPulseDotState();
}

class _NumuwPulseDotState extends State<NumuwPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = NumuwMotionPolicy.reduceMotion(context);
    if (!widget.active || reduceMotion) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: widget.active ? 1 : .45),
          shape: BoxShape.circle,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final halo = widget.size + (t * widget.size * 1.8);
        return SizedBox(
          width: widget.size * 3,
          height: widget.size * 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: halo,
                height: halo,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: .18 * (1 - t)),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NumuwAnimatedNumber extends StatelessWidget {
  const NumuwAnimatedNumber({
    super.key,
    required this.value,
    required this.builder,
    this.duration = NumuwMotionTokens.card,
  });

  final double value;
  final Widget Function(BuildContext context, double value) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (NumuwMotionPolicy.reduceMotion(context)) {
      return builder(context, value);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: NumuwMotionTokens.standard,
      builder: (context, value, child) => builder(context, value),
    );
  }
}

/// Lightweight success moment for completed logs. Uses only paint and scale so
/// it remains smooth on low-end devices.
class NumuwSuccessBloom extends StatefulWidget {
  const NumuwSuccessBloom({
    super.key,
    this.size = 108,
    this.color = AppColors.plum,
  });

  final double size;
  final Color color;

  @override
  State<NumuwSuccessBloom> createState() => _NumuwSuccessBloomState();
}

class _NumuwSuccessBloomState extends State<NumuwSuccessBloom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: NumuwMotionTokens.success,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (NumuwMotionPolicy.reduceMotion(context)) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Container(
            width: widget.size * .54,
            height: widget.size * .54,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: widget.color,
              size: widget.size * .29,
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOutQuart.transform(_controller.value);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BloomPainter(progress: t, color: widget.color),
            child: Center(
              child: Transform.scale(
                scale: .75 + (.25 * t),
                child: Container(
                  width: widget.size * .54,
                  height: widget.size * .54,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: widget.color,
                    size: widget.size * .29,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BloomPainter extends CustomPainter {
  const _BloomPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i;
      final inner = size.width * (.25 + .04 * progress);
      final outer = size.width * (.26 + .15 * progress);
      paint.color = color.withValues(alpha: .55 * (1 - progress));
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BloomPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Fade-through for sibling destinations such as main-shell tabs or state
/// changes that do not have a strong spatial relationship.
class NumuwFadeThroughSwitcher extends StatelessWidget {
  const NumuwFadeThroughSwitcher({
    super.key,
    required this.child,
    this.reverse = false,
    this.fillColor,
  });

  final Widget child;
  final bool reverse;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    if (NumuwMotionPolicy.reduceMotion(context)) return child;

    return PageTransitionSwitcher(
      duration: NumuwMotionTokens.page,
      reverse: reverse,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
          FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            fillColor: fillColor,
            child: child,
          ),
      child: child,
    );
  }
}

/// Material container transform for strong parent → detail relationships.
///
/// Use for quick-log cards and activity rows that open a focused detail/editor
/// screen. Avoid it for unrelated destinations.
class NumuwOpenContainer<T extends Object?> extends StatelessWidget {
  const NumuwOpenContainer({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.onClosed,
    this.closedColor = Colors.transparent,
    this.openColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.transitionType = ContainerTransitionType.fadeThrough,
    this.useRootNavigator = false,
  });

  final CloseContainerBuilder closedBuilder;
  final OpenContainerBuilder<T> openBuilder;
  final ClosedCallback<T?>? onClosed;
  final Color closedColor;
  final Color? openColor;
  final BorderRadius borderRadius;
  final ContainerTransitionType transitionType;
  final bool useRootNavigator;

  @override
  Widget build(BuildContext context) {
    final color = openColor ?? Theme.of(context).scaffoldBackgroundColor;

    return OpenContainer<T>(
      transitionDuration: NumuwMotionPolicy.reduceMotion(context)
          ? Duration.zero
          : NumuwMotionTokens.page,
      transitionType: transitionType,
      closedColor: closedColor,
      openColor: color,
      middleColor: color,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: borderRadius),
      openShape: const RoundedRectangleBorder(),
      useRootNavigator: useRootNavigator,
      onClosed: onClosed,
      closedBuilder: closedBuilder,
      openBuilder: openBuilder,
    );
  }
}

Route<T> numuwPageRoute<T>(WidgetBuilder builder) => PageRouteBuilder<T>(
  transitionDuration: NumuwMotionTokens.page,
  reverseTransitionDuration: NumuwMotionTokens.card,
  pageBuilder: (context, animation, secondaryAnimation) => builder(context),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    if (NumuwMotionPolicy.reduceMotion(context)) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: NumuwMotionTokens.standard,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(.025, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);
