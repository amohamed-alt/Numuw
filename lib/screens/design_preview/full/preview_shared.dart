import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/theme/numuw_theme.dart';
import '../../../widgets/numuw_classy_components.dart';
import '../../../widgets/numuw_motion_widgets.dart';

Color previewText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.nightText
    : AppColors.text;
Color previewSecondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.nightSecondaryText
    : AppColors.secondaryText;
Color previewSurface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.nightSurface
    : AppColors.surface;
Color previewRaised(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.nightSurfaceRaised
    : AppColors.surfaceRaised;
Color previewBorder(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.nightBorder
    : AppColors.border;
Color previewAccent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.nightPrimaryStrong
    : AppColors.plum;

class PreviewScreenScaffold extends StatelessWidget {
  const PreviewScreenScaffold({
    super.key,
    required this.child,
    required this.black,
    this.title,
    this.subtitle,
    this.trailing,
    this.showBack = true,
    this.bottom,
    this.padding = const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 34),
  });

  final Widget child;
  final bool black;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;
  final Widget? bottom;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Theme(
    data: buildNumuwTheme(night: black),
    child: Builder(
      builder: (themedContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: black
              ? AppColors.nightBackground
              : AppColors.background,
          bottomNavigationBar: bottom,
          body: SafeArea(
            child: Column(
              children: [
                if (showBack || title != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        if (showBack)
                          IconButton(
                            onPressed: () => Navigator.maybePop(themedContext),
                            icon: const Icon(Icons.arrow_forward_rounded),
                          )
                        else
                          const SizedBox(width: 48),
                        if (title != null)
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  title!,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: previewText(themedContext),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    subtitle!,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: previewSecondary(themedContext),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        else
                          const Spacer(),
                        SizedBox(width: 48, child: Center(child: trailing)),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: padding,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class PreviewEyebrow extends StatelessWidget {
  const PreviewEyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: previewAccent(context),
      fontSize: 10.5,
      letterSpacing: 1.15,
      fontWeight: FontWeight.w800,
    ),
  );
}

class PreviewPageIntro extends StatelessWidget {
  const PreviewPageIntro({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (eyebrow != null) ...[
        PreviewEyebrow(eyebrow!),
        const SizedBox(height: 7),
      ],
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: previewText(context),
                    fontSize: 25,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: previewSecondary(context),
                      fontSize: 13,
                      height: 1.65,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 12),
            PreviewIcon(icon: icon!),
          ],
        ],
      ),
    ],
  );
}

class PreviewIcon extends StatelessWidget {
  const PreviewIcon({
    super.key,
    required this.icon,
    this.color = AppColors.plum,
    this.background = AppColors.roseMist,
    this.size = 48,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? color.withValues(alpha: .13) : background,
        borderRadius: BorderRadius.circular(size * .34),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: dark ? AppColors.nightPrimary : color,
        size: size * .43,
      ),
    );
  }
}

class PreviewField extends StatelessWidget {
  const PreviewField({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.icon,
    this.obscure = false,
    this.ltr = false,
    this.multiline = false,
  });

  final String label;
  final String? value;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final bool ltr;
  final bool multiline;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: previewText(context),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 7),
      Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: multiline ? 96 : 52),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: previewSurface(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: previewBorder(context)),
        ),
        child: Row(
          crossAxisAlignment: multiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19, color: previewSecondary(context)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                obscure
                    ? '••••••••'
                    : (value?.isNotEmpty == true ? value! : (hint ?? '')),
                textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
                textAlign: ltr ? TextAlign.left : TextAlign.start,
                style: TextStyle(
                  color: value?.isNotEmpty == true
                      ? previewText(context)
                      : previewSecondary(context),
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class PreviewDividerLabel extends StatelessWidget {
  const PreviewDividerLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: previewBorder(context))),
      Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        child: Text(
          text,
          style: TextStyle(
            color: previewSecondary(context),
            fontSize: 11.5,
          ),
        ),
      ),
      Expanded(child: Divider(color: previewBorder(context))),
    ],
  );
}

class PreviewInfoRow extends StatelessWidget {
  const PreviewInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = AppColors.plum,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.symmetric(vertical: 11),
    child: Row(
      children: [
        if (icon != null) ...[
          PreviewIcon(icon: icon!, color: color, size: 38),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: previewSecondary(context),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: previewText(context),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class PreviewStatusPill extends StatelessWidget {
  const PreviewStatusPill({
    super.key,
    required this.label,
    this.color = AppColors.plum,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? .17 : .11,
      ),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.nightPrimary
            : color,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class PreviewMiniStat extends StatelessWidget {
  const PreviewMiniStat({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.plum,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? color.withValues(alpha: .13)
            : color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: previewBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: previewSecondary(context),
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: previewText(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class PreviewChoiceCard extends StatelessWidget {
  const PreviewChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.onTap,
    this.color = AppColors.plum,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    onTap: onTap,
    child: AnimatedContainer(
      duration: NumuwMotion.fast,
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(15),
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? .15
                    : .07,
              )
            : previewSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? color : previewBorder(context),
          width: selected ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          PreviewIcon(icon: icon, color: color, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: previewText(context),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: previewSecondary(context),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? color : previewSecondary(context),
            size: 20,
          ),
        ],
      ),
    ),
  );
}

class PreviewSectionCard extends StatelessWidget {
  const PreviewSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.action,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: previewAccent(context), size: 19),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: previewText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 13),
        child,
      ],
    ),
  );
}

class PreviewSwitchRow extends StatefulWidget {
  const PreviewSwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    this.initial = true,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final bool initial;
  final IconData? icon;

  @override
  State<PreviewSwitchRow> createState() => _PreviewSwitchRowState();
}

class _PreviewSwitchRowState extends State<PreviewSwitchRow> {
  late bool value = widget.initial;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (widget.icon != null) ...[
        PreviewIcon(icon: widget.icon!, size: 38),
        const SizedBox(width: 10),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: previewText(context),
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: TextStyle(
                  color: previewSecondary(context),
                  fontSize: 10.5,
                ),
              ),
          ],
        ),
      ),
      Switch(value: value, onChanged: (next) => setState(() => value = next)),
    ],
  );
}

class PreviewChart extends StatelessWidget {
  const PreviewChart({
    super.key,
    this.color = AppColors.plum,
    this.height = 170,
  });

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(
      painter: _PreviewChartPainter(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.nightPrimary
            : color,
        grid: previewBorder(context),
      ),
    ),
  );
}

class _PreviewChartPainter extends CustomPainter {
  const _PreviewChartPainter({required this.color, required this.grid});
  final Color color;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: .72)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[
      Offset(size.width * .03, size.height * .78),
      Offset(size.width * .18, size.height * .70),
      Offset(size.width * .35, size.height * .55),
      Offset(size.width * .52, size.height * .42),
      Offset(size.width * .68, size.height * .30),
      Offset(size.width * .83, size.height * .24),
      Offset(size.width * .97, size.height * .22),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final mid = (p0.dx + p1.dx) / 2;
      path.cubicTo(mid, p0.dy, mid, p1.dy, p1.dx, p1.dy);
    }
    final line = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);
    final dot = Paint()..color = color;
    for (final point in points) {
      canvas.drawCircle(point, 3.7, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewChartPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.grid != grid;
}

class PreviewSafetyNote extends StatelessWidget {
  const PreviewSafetyNote({super.key, required this.text, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.danger : previewAccent(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(13),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? .14 : .07,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: previewText(context),
                fontSize: 11.5,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void previewNoop() {}
