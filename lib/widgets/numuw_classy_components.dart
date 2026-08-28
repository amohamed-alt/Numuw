import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'numuw_motion_widgets.dart';

/// Premium reusable surfaces and controls for Numuw's motherhood design system.
/// These components are independent of feature logic and can be migrated into
/// existing screens incrementally.

bool _dark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
Color _surface(BuildContext context) =>
    _dark(context) ? AppColors.nightSurface : AppColors.surface;
Color _surfaceRaised(BuildContext context) =>
    _dark(context) ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised;
Color _text(BuildContext context) =>
    _dark(context) ? AppColors.nightText : AppColors.text;
Color _secondary(BuildContext context) => _dark(context)
    ? AppColors.nightSecondaryText
    : AppColors.secondaryText;
Color _border(BuildContext context) =>
    _dark(context) ? AppColors.nightBorder : AppColors.border;
Color _accent(BuildContext context) =>
    _dark(context) ? AppColors.nightPrimaryStrong : AppColors.plum;

class NumuwClassySurface extends StatelessWidget {
  const NumuwClassySurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(18),
    this.radius = NumuwRadius.card,
    this.onTap,
    this.tinted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: tinted ? _surfaceRaised(context) : _surface(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _border(context)),
        boxShadow: _dark(context) ? NumuwElevation.none : NumuwElevation.card,
      ),
      child: child,
    );
    if (onTap == null) return body;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: body,
    );
  }
}

class NumuwClassyButton extends StatelessWidget {
  const NumuwClassyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = NumuwButtonVariant.primary,
    this.size = NumuwButtonSize.large,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final NumuwButtonVariant variant;
  final NumuwButtonSize size;

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      NumuwButtonSize.small => 44.0,
      NumuwButtonSize.medium => 48.0,
      NumuwButtonSize.large => 54.0,
    };
    final radius = switch (size) {
      NumuwButtonSize.small => 13.0,
      NumuwButtonSize.medium => 15.0,
      NumuwButtonSize.large => 17.0,
    };
    final background = switch (variant) {
      NumuwButtonVariant.primary => _dark(context)
          ? AppColors.nightPrimaryStrong
          : AppColors.plum,
      NumuwButtonVariant.secondary => _surface(context),
      NumuwButtonVariant.tonal => _dark(context)
          ? AppColors.nightPrimarySoft
          : AppColors.roseMist,
      NumuwButtonVariant.danger => AppColors.danger,
      NumuwButtonVariant.black => _dark(context)
          ? AppColors.nightText
          : const Color(0xFF181619),
    };
    final foreground = switch (variant) {
      NumuwButtonVariant.primary =>
        _dark(context) ? AppColors.nightBackground : Colors.white,
      NumuwButtonVariant.secondary => _text(context),
      NumuwButtonVariant.tonal => _accent(context),
      NumuwButtonVariant.danger => Colors.white,
      NumuwButtonVariant.black =>
        _dark(context) ? AppColors.nightBackground : Colors.white,
    };
    final border = variant == NumuwButtonVariant.secondary
        ? Border.all(color: _border(context), width: 1.2)
        : null;

    return Opacity(
      opacity: onPressed == null ? .55 : 1,
      child: NumuwPressable(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              else ...[
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 19),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: size == NumuwButtonSize.small ? 13.5 : 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum NumuwButtonVariant { primary, secondary, tonal, danger, black }
enum NumuwButtonSize { small, medium, large }

class NumuwChildIdentity extends StatelessWidget {
  const NumuwChildIdentity({
    super.key,
    required this.name,
    required this.age,
    this.imageProvider,
    this.onTap,
  });

  final String name;
  final String age;
  final ImageProvider? imageProvider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
    radius: NumuwRadius.hero,
    padding: const EdgeInsetsDirectional.all(20),
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _dark(context)
                ? AppColors.nightSurfaceRaised
                : AppColors.blushSoft,
            border: Border.all(
              color: _dark(context)
                  ? AppColors.nightBorderStrong
                  : AppColors.blush,
              width: 1.5,
            ),
            image: imageProvider == null
                ? null
                : DecorationImage(image: imageProvider!, fit: BoxFit.cover),
          ),
          alignment: Alignment.center,
          child: imageProvider == null
              ? Icon(
                  Icons.child_care_rounded,
                  size: 30,
                  color: _accent(context),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: _text(context),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                age,
                style: TextStyle(
                  color: _secondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_left_rounded, color: _secondary(context)),
      ],
    ),
  );
}

class NumuwMetricTile extends StatelessWidget {
  const NumuwMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tint = AppColors.roseMist,
    this.accent = AppColors.plum,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
    onTap: onTap,
    padding: const EdgeInsetsDirectional.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _dark(context)
                ? accent.withValues(alpha: .15)
                : tint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _dark(context) ? AppColors.nightPrimary : accent, size: 20),
        ),
        const Spacer(),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _text(context),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _secondary(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class NumuwQuickAction extends StatelessWidget {
  const NumuwQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.tint = AppColors.roseMist,
    this.accent = AppColors.plum,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color tint;
  final Color accent;
  final bool selected;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 68,
    child: Column(
      children: [
        NumuwPressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: NumuwMotion.fast,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? (_dark(context)
                        ? AppColors.nightPrimarySoft
                        : AppColors.plumSoft)
                  : (_dark(context) ? accent.withValues(alpha: .13) : tint),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? (_dark(context) ? AppColors.nightPrimary : accent)
                    : Colors.transparent,
                width: 1.4,
              ),
            ),
            child: Icon(
              icon,
              color: _dark(context) ? AppColors.nightPrimary : accent,
              size: 23,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _text(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class NumuwSectionLabel extends StatelessWidget {
  const NumuwSectionLabel({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: _text(context),
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  color: _secondary(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
      if (actionLabel != null)
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ],
  );
}

class NumuwSegmentedControl extends StatelessWidget {
  const NumuwSegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final Map<String, String> items;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(4),
    decoration: BoxDecoration(
      color: _surfaceRaised(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border(context)),
    ),
    child: Row(
      children: items.entries.map((entry) {
        final selected = entry.key == value;
        return Expanded(
          child: NumuwPressable(
            onTap: () => onChanged(entry.key),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: NumuwMotion.fast,
              alignment: Alignment.center,
              padding: const EdgeInsetsDirectional.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: selected ? _surface(context) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected && !_dark(context)
                    ? const [
                        BoxShadow(
                          color: Color(0x10442A34),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: selected ? _accent(context) : _secondary(context),
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

class NumuwTimelineRow extends StatelessWidget {
  const NumuwTimelineRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.color = AppColors.plum,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsetsDirectional.only(top: 5),
                    color: _border(context),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: _text(context),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: _secondary(context),
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  time,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: _secondary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class NumuwBottomBarPreview extends StatelessWidget {
  const NumuwBottomBarPreview({super.key, this.selectedIndex = 0});

  final int selectedIndex;

  static const _items = <(IconData, String)>[
    (Icons.home_rounded, 'الرئيسية'),
    (Icons.add_circle_outline_rounded, 'تسجيل'),
    (Icons.child_care_rounded, 'طفلي'),
    (Icons.auto_awesome_outlined, 'المساعد'),
    (Icons.grid_view_rounded, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) => NumuwClassySurface(
    radius: 22,
    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 7),
    child: Row(
      children: List.generate(_items.length, (index) {
        final selected = index == selectedIndex;
        final item = _items[index];
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: NumuwMotion.fast,
                width: 38,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? (_dark(context)
                            ? AppColors.nightPrimarySoft
                            : AppColors.roseMist)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  item.$1,
                  size: 19,
                  color: selected ? _accent(context) : _secondary(context),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.$2,
                style: TextStyle(
                  color: selected ? _accent(context) : _secondary(context),
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}
