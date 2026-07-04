import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../state/app_preferences.dart';

bool numuwNightMode() => AppPreferences.instance.nightMode;

Color numuwPageColor() =>
    numuwNightMode() ? AppColors.nightBackground : AppColors.background;

Color numuwSurfaceColor() =>
    numuwNightMode() ? AppColors.nightSurface : AppColors.surface;

Color numuwTextColor() =>
    numuwNightMode() ? AppColors.nightText : AppColors.text;

Color numuwSecondaryTextColor() =>
    numuwNightMode() ? AppColors.nightSecondaryText : AppColors.secondaryText;

Color numuwBorderColor() =>
    numuwNightMode() ? AppColors.nightBorder : AppColors.border;

Color numuwAccentColor() =>
    numuwNightMode() ? AppColors.nightGold : AppColors.mint;

class MobileContentContainer extends StatelessWidget {
  const MobileContentContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < NumuwSpacing.maxMobileWidth
          ? constraints.maxWidth
          : NumuwSpacing.maxMobileWidth;
      return Center(
        child: SizedBox(width: width, child: child),
      );
    },
  );
}

class NumuwPageScaffold extends StatelessWidget {
  const NumuwPageScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 24),
    this.scrollable = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = MobileContentContainer(
      child: ColoredBox(
        color: numuwPageColor(),
        child: Padding(padding: padding, child: child),
      ),
    );
    return SafeArea(
      bottom: false,
      child: scrollable
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: content,
            )
          : content,
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 24),
    this.scrollable = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return NumuwPageScaffold(
      padding: padding,
      scrollable: scrollable,
      child: child,
    );
  }
}

class NumuwHeader extends StatelessWidget {
  const NumuwHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.leading,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showNotification = true,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final bool showNotification;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
    child: NumuwHeader(
      title: title,
      subtitle: subtitle,
      trailing:
          trailing ?? (showNotification ? const NotificationButton() : null),
    ),
  );
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key, this.onPressed, this.badge = true});

  final VoidCallback? onPressed;
  final bool badge;

  @override
  Widget build(BuildContext context) => AppIconButton(
    icon: Icons.notifications_none_rounded,
    onPressed: onPressed ?? () {},
    badge: badge,
  );
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.badge = false,
    this.size = 44,
    this.radius = 14,
    this.iconSize = 22,
    this.borderWidth = 1,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool badge;
  final double size;
  final double radius;
  final double iconSize;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onPressed,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: numuwSurfaceColor(),
            borderRadius: borderRadius,
            border: Border.all(color: numuwBorderColor(), width: borderWidth),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: numuwTextColor(), size: iconSize),
              ),
              if (badge)
                PositionedDirectional(
                  top: 8,
                  end: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.peach,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(16),
    this.color,
    this.radius = 20,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final card = Ink(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? numuwSurfaceColor(),
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? numuwBorderColor(),
          width: 1.2,
        ),
        boxShadow: numuwNightMode()
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? card
          : InkWell(borderRadius: borderRadius, onTap: onTap, child: card),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color ?? AppColors.mint,
          disabledBackgroundColor: numuwNightMode()
              ? AppColors.nightSurfaceSoft
              : AppColors.border,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: enabled ? Colors.white : numuwAccentColor(),
                ),
              )
            : Text(label),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.action,
  });

  final String title;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: numuwNightMode()
              ? AppColors.nightGold.withValues(alpha: .14)
              : AppColors.mintLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.mintDark, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
      ),
      if (action != null) action!,
    ],
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: numuwNightMode()
          ? AppColors.nightSurfaceSoft
          : AppColors.neutralSoft,
      borderColor: numuwBorderColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: '🌱',
            background: numuwNightMode()
                ? AppColors.nightGold.withValues(alpha: .14)
                : AppColors.mintLight,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: numuwTextColor(),
              fontWeight: FontWeight.w800,
              height: 1.55,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textDirection,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextDirection? textDirection;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          minLines: minLines,
          maxLines: obscureText ? 1 : maxLines,
          textDirection: textDirection ?? TextDirection.rtl,
          textAlign: TextAlign.start,
          style: TextStyle(color: numuwTextColor(), fontSize: 15, height: 1.45),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, color: AppColors.mint),
            filled: true,
            fillColor: numuwSurfaceColor(),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            errorMaxLines: 2,
            errorStyle: const TextStyle(height: 1.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: numuwBorderColor(), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: numuwAccentColor(), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (numuwNightMode()
                    ? AppColors.nightGold.withValues(alpha: .14)
                    : AppColors.mintLight)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.mintDark : AppColors.border,
            width: selected ? 2 : 1.4,
          ),
        ),
        child: Text(
          icon == null ? label : '$label $icon',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.mintDark : AppColors.text,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.color = AppColors.mint,
    this.background = AppColors.mintLight,
    this.icon = Icons.check_circle_outline_rounded,
  });

  final String message;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(15),
      decoration: BoxDecoration(
        color: background.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.background,
    this.size = 42,
    this.borderColor,
  });

  final String icon;
  final Color background;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * .34),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(icon, style: TextStyle(fontSize: size * .46)),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: numuwSurfaceColor(),
        foregroundColor: numuwTextColor(),
        side: BorderSide(color: numuwBorderColor(), width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    ),
  );
}

class TextActionButton extends StatelessWidget {
  const TextActionButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Text(
      label,
      style: TextStyle(
        color: numuwAccentColor(),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class NumuwTextField extends AppTextField {
  const NumuwTextField({
    super.key,
    required super.controller,
    required super.label,
    super.hint,
    super.keyboardType,
    super.validator,
    super.textDirection,
    super.minLines,
    super.maxLines,
  });
}

class NumuwPasswordField extends AppTextField {
  const NumuwPasswordField({
    super.key,
    required super.controller,
    required super.label,
    super.validator,
    super.hint = '••••••••',
  }) : super(obscureText: true, textDirection: TextDirection.ltr);
}

class NumuwNumberField extends AppTextField {
  const NumuwNumberField({
    super.key,
    required super.controller,
    required super.label,
    super.hint,
    super.validator,
  }) : super(
         keyboardType: TextInputType.number,
         textDirection: TextDirection.ltr,
       );
}

class NumuwTextArea extends AppTextField {
  const NumuwTextArea({
    super.key,
    required super.controller,
    required super.label,
    super.hint,
    super.validator,
  }) : super(minLines: 3, maxLines: 6);
}

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: AnimatedContainer(
      duration: NumuwMotion.fast,
      padding: padding,
      decoration: BoxDecoration(
        color: selected
            ? (numuwNightMode()
                  ? AppColors.nightGold.withValues(alpha: .16)
                  : AppColors.mintLight)
            : numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? numuwAccentColor() : numuwBorderColor(),
          width: selected ? 2 : 1.5,
        ),
      ),
      child: child,
    ),
  );
}

class SegmentedSelector extends StatelessWidget {
  const SegmentedSelector({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items.entries
        .map(
          (entry) => ChoicePill(
            label: entry.value,
            selected: entry.key == value,
            onTap: () => onChanged(entry.key),
          ),
        )
        .toList(),
  );
}

class QuickLogTypeButton extends StatelessWidget {
  const QuickLogTypeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    required this.border,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final String icon;
  final Color background;
  final Color border;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 78,
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.mintLight : background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.mintDark : border,
                width: selected ? 2.2 : 1.6,
              ),
              boxShadow: numuwNightMode()
                  ? const []
                  : [
                      BoxShadow(
                        color: border.withValues(alpha: .15),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class TimerCard extends StatelessWidget {
  const TimerCard({
    super.key,
    required this.time,
    required this.status,
    required this.color,
    required this.active,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String time;
  final String status;
  final Color color;
  final bool active;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SoftCard(
    radius: 24,
    padding: const EdgeInsetsDirectional.fromSTEB(18, 20, 18, 18),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: active ? color : AppColors.mutedText,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 50,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: buttonLabel,
          color: active ? AppColors.danger : color,
          onPressed: onPressed,
        ),
      ],
    ),
  );
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key, this.color});

  final Color? color;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      3,
      (index) => FadeTransition(
        opacity: Tween<double>(begin: .35, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Interval(index / 3, 1)),
        ),
        child: Container(
          width: 9,
          height: 9,
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: widget.color ?? numuwAccentColor(),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

class WarningBanner extends InfoBanner {
  const WarningBanner({super.key, required super.message})
    : super(
        color: AppColors.danger,
        background: AppColors.peachLight,
        icon: Icons.warning_amber_rounded,
      );
}

class ErrorMessageCard extends InfoBanner {
  const ErrorMessageCard({super.key, required super.message})
    : super(
        color: AppColors.danger,
        background: AppColors.peachLight,
        icon: Icons.error_outline_rounded,
      );
}

class EmptyStateCard extends EmptyState {
  const EmptyStateCard({super.key, required super.message, super.icon});
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.height = 96});

  final double height;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            LoadingDots(color: numuwAccentColor()),
          ],
        ),
      ),
    ),
  );
}

class ActivityListItem extends StatelessWidget {
  const ActivityListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color background;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(15, 13, 15, 13),
    child: Row(
      children: [
        IconBadge(icon: icon, background: background, size: 36),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_left_rounded,
          color: numuwSecondaryTextColor(),
          size: 18,
        ),
      ],
    ),
  );
}

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.completed,
    required this.onChanged,
    this.onDelete,
  });

  final String title;
  final String? subtitle;
  final bool completed;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
    value: completed,
    onChanged: (value) => onChanged(value ?? false),
    title: Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: numuwTextColor(),
        fontWeight: FontWeight.w700,
        decoration: completed ? TextDecoration.lineThrough : null,
      ),
    ),
    subtitle: subtitle == null
        ? null
        : Text(subtitle!, textAlign: TextAlign.start),
    secondary: onDelete == null
        ? null
        : IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
  );
}

class VaccinationCard extends StatelessWidget {
  const VaccinationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    child: Row(
      children: [
        const IconBadge(
          icon: '💉',
          background: AppColors.yellowLight,
          size: 42,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: numuwAccentColor(),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class GrowthCard extends StatelessWidget {
  const GrowthCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwSecondaryTextColor(),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.start,
          style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12),
        ),
      ],
    ),
  );
}

class ProfileInfoCard extends SoftCard {
  const ProfileInfoCard({super.key, required super.child}) : super(radius: 24);
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1)
            Divider(height: 1, color: numuwBorderColor()),
        ],
      ],
    ),
  );
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.mintDark, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          trailing ??
              Icon(
                Icons.chevron_left_rounded,
                color: numuwSecondaryTextColor(),
                size: 18,
              ),
        ],
      ),
    ),
  );
}

class NumuwSwitch extends StatelessWidget {
  const NumuwSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: NumuwMotion.fast,
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: value ? AppColors.mint : AppColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        duration: NumuwMotion.fast,
        alignment: value
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 3)],
          ),
        ),
      ),
    ),
  );
}

class SuccessToast extends StatelessWidget {
  const SuccessToast({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => PositionedDirectional(
    bottom: 96,
    start: 18,
    end: 18,
    child: Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: numuwNightMode() ? AppColors.nightSurface : AppColors.mintDark,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(confirmLabel),
      ),
    ],
  );
}

class ChildHeroCard extends StatelessWidget {
  const ChildHeroCard({
    super.key,
    required this.name,
    required this.age,
    this.onTap,
  });

  final String name;
  final String age;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.all(20),
    decoration: BoxDecoration(
      gradient: numuwNightMode()
          ? AppColors.nightGradient
          : const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [AppColors.mintLight, AppColors.mintSoft],
            ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          IconBadge(
            icon: '👶',
            background: numuwSurfaceColor(),
            size: 68,
            borderColor: numuwAccentColor().withValues(alpha: .25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: numuwAccentColor(),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  age,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: numuwAccentColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'بيانات اليوم من تسجيلاتكِ',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
    this.label = '',
  });

  final String title;
  final String value;
  final String icon;
  final Color color;
  final Color background;
  final String label;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsetsDirectional.all(16),
    child: SizedBox(
      height: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (label.isNotEmpty)
                      Text(
                        label,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: numuwSecondaryTextColor(),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              IconBadge(icon: icon, background: background, size: 42),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: value.length > 18 ? 14 : 19,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ],
      ),
    ),
  );
}
