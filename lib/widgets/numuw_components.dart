import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'app_widgets.dart';

class NumuwAppBar extends StatelessWidget {
  const NumuwAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;

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
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 13.5,
                  height: 1.55,
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

class NumuwPrimaryButton extends StatelessWidget {
  const NumuwPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) =>
      PrimaryButton(label: label, onPressed: onPressed, loading: loading);
}

class NumuwSecondaryButton extends StatelessWidget {
  const NumuwSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      SecondaryButton(label: label, onPressed: onPressed);
}

class NumuwCard extends StatelessWidget {
  const NumuwCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      SoftCard(padding: padding, radius: 22, onTap: onTap, child: child);
}

class NumuwSectionHeader extends StatelessWidget {
  const NumuwSectionHeader({
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
          Icon(icon, color: numuwAccentColor(), size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      );
}

class NumuwStatusBadge extends StatelessWidget {
  const NumuwStatusBadge({
    super.key,
    required this.label,
    this.color = AppColors.mint,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final active = numuwAccentColor();
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: active.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active.withValues(alpha: .24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class NumuwEmptyState extends StatelessWidget {
  const NumuwEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => EmptyState(message: message);
}

class NumuwLoadingState extends StatelessWidget {
  const NumuwLoadingState({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) => LoadingSkeleton(height: height);
}

class NumuwErrorState extends StatelessWidget {
  const NumuwErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => ErrorMessageCard(message: message);
}

/// Compatibility component used by existing feature screens. It now renders
/// the Figma moon-progress language instead of the legacy plant identity.
class NumuwPlantProgress extends StatelessWidget {
  const NumuwPlantProgress({super.key, required this.progress, this.label});

  final double progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0).toDouble();
    final accent = numuwAccentColor();
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: numuwNightMode()
            ? AppColors.nightSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: numuwBorderColor()),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: normalized,
                  strokeWidth: 4.5,
                  backgroundColor: numuwBorderColor(),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
                Icon(Icons.nightlight_round, color: accent, size: 24),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label ?? 'يوم هادئ مع نُمُوّ',
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'كل تسجيل صغير يساعدك على رؤية الصورة بوضوح.',
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NumuwBabyHeader extends StatelessWidget {
  const NumuwBabyHeader({
    super.key,
    required this.name,
    required this.subtitle,
  });

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient(numuwNightMode()),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: numuwBorderColor()),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: numuwSurfaceColor(),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: numuwAccentColor().withValues(alpha: .24),
                ),
              ),
              child: const Text('👶', style: TextStyle(fontSize: 29)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: numuwAccentColor()),
          ],
        ),
      );
}

class NumuwConfirmationDialog extends StatelessWidget {
  const NumuwConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmLabel),
          ),
        ],
      );
}

class NumuwSuccessSheet extends StatelessWidget {
  const NumuwSuccessSheet({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 22),
        decoration: BoxDecoration(
          color: numuwSurfaceColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: numuwBorderColor())),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: numuwAccentColor(), size: 44),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
}

class NumuwMetricCard extends StatelessWidget {
  const NumuwMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => NumuwCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: numuwAccentColor(), size: 20),
              const SizedBox(height: 9),
            ],
            Text(
              value,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
}

class NumuwEventTile extends StatelessWidget {
  const NumuwEventTile({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => NumuwCard(child: child);
}

class NumuwTimelineItem extends StatelessWidget {
  const NumuwTimelineItem({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: numuwAccentColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class NumuwReminderCard extends StatelessWidget {
  const NumuwReminderCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => NumuwCard(
        child: Row(
          children: [
            Icon(Icons.notifications_active_outlined,
                color: numuwAccentColor()),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class NumuwFamilyTaskTile extends StatelessWidget {
  const NumuwFamilyTaskTile({
    super.key,
    required this.title,
    required this.completed,
  });

  final String title;
  final bool completed;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            color: completed ? numuwAccentColor() : numuwBorderColor(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      );
}

class NumuwAiDraftCard extends StatelessWidget {
  const NumuwAiDraftCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => NumuwCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: numuwAccentColor(), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
}
