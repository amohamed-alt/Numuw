import 'package:flutter/material.dart';

abstract final class NumuwMotionSpec {
  static const tap = Duration(milliseconds: 120);
  static const quick = Duration(milliseconds: 180);
  static const enter = Duration(milliseconds: 280);
  static const success = Duration(milliseconds: 520);

  static const standard = Curves.easeOutCubic;
  static const expressive = Curves.easeOutBack;
}

class NumuwPressable extends StatefulWidget {
  const NumuwPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.97,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;

  @override
  State<NumuwPressable> createState() => _NumuwPressableState();
}

class _NumuwPressableState extends State<NumuwPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reducedMotion ? Duration.zero : NumuwMotionSpec.tap;

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
        onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
        onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: duration,
          curve: NumuwMotionSpec.standard,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.9 : 1,
            duration: duration,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class NumuwEntrance extends StatelessWidget {
  const NumuwEntrance({
    super.key,
    required this.child,
    this.visible = true,
    this.offset = const Offset(0, 0.035),
  });

  final Widget child;
  final bool visible;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reducedMotion ? Duration.zero : NumuwMotionSpec.enter;

    return AnimatedSlide(
      offset: visible ? Offset.zero : offset,
      duration: duration,
      curve: NumuwMotionSpec.standard,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: NumuwMotionSpec.standard,
        child: child,
      ),
    );
  }
}

class NumuwSuccessPulse extends StatefulWidget {
  const NumuwSuccessPulse({
    super.key,
    required this.child,
    required this.trigger,
  });

  final Widget child;
  final Object? trigger;

  @override
  State<NumuwSuccessPulse> createState() => _NumuwSuccessPulseState();
}

class _NumuwSuccessPulseState extends State<NumuwSuccessPulse> {
  bool _pulse = false;

  @override
  void didUpdateWidget(covariant NumuwSuccessPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _runPulse();
    }
  }

  Future<void> _runPulse() async {
    if (!mounted) return;
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reducedMotion) return;

    setState(() => _pulse = true);
    await Future<void>.delayed(const Duration(milliseconds: 170));
    if (mounted) setState(() => _pulse = false);
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimatedScale(
      scale: _pulse && !reducedMotion ? 1.08 : 1,
      duration: reducedMotion ? Duration.zero : NumuwMotionSpec.quick,
      curve: NumuwMotionSpec.expressive,
      child: widget.child,
    );
  }
}
