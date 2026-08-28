import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Production vector icon wrapper for Numuw's custom icon family.
///
/// SVG assets are monochrome and recolored at runtime so the same artwork works
/// across morning and evening themes without duplicating files.
class NumuwIcon extends StatelessWidget {
  const NumuwIcon(
    this.asset, {
    super.key,
    this.size = 22,
    this.color,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: semanticLabel,
      colorFilter: resolvedColor == null
          ? null
          : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}

class NumuwIcons {
  const NumuwIcons._();

  static const _root = 'assets/icons';

  static const logoMark = '$_root/logo_mark.svg';
  static const home = '$_root/home.svg';
  static const quickLog = '$_root/quick_log.svg';
  static const child = '$_root/child.svg';
  static const assistant = '$_root/assistant.svg';
  static const more = '$_root/more.svg';
  static const feeding = '$_root/feeding.svg';
  static const feedingRight = '$_root/feeding_right.svg';
  static const feedingLeft = '$_root/feeding_left.svg';
  static const pumping = '$_root/pumping.svg';
  static const sleep = '$_root/sleep.svg';
  static const diaper = '$_root/diaper.svg';
  static const food = '$_root/food.svg';
  static const medicine = '$_root/medicine.svg';
  static const temperature = '$_root/temperature.svg';
  static const vaccination = '$_root/vaccination.svg';
  static const bell = '$_root/bell.svg';
  static const calendar = '$_root/calendar.svg';
  static const profile = '$_root/profile.svg';
  static const history = '$_root/history.svg';
}
