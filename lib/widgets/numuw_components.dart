import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../design/numuw_motion_widgets.dart';
import '../design/numuw_organic_icons.dart';
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
    return NumuwCard(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
      child: Row(
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
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
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
    this.padding = const EdgeInsetsDirectional.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      SoftCard(padding: padding, onTap: onTap, child: child);
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
  Widget build(BuildContext context) =>
      SectionTitle(title: title, icon: icon, action: action);
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: .18)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    ),
  );
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

class NumuwPlantProgress extends StatelessWidget {
  const NumuwPlantProgress({super.key, required this.progress, this.label});

  final double progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0).toDouble();
    final stage = normalized == 0
        ? 'البذرة'
        : normalized < .35
        ? 'البرعم'
        : normalized < .75
        ? 'الأوراق'
        : 'نمو ثابت';

    return NumuwEntrance(
      child: NumuwCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: NumuwOrganicIcon(
                  NumuwOrganicIconName.growth,
                  size: 42,
                  semanticLabel: 'تقدم النمو',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label ?? stage,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: normalized,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.mint),
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
  Widget build(BuildContext context) => NumuwEntrance(
    child: NumuwCard(
      child: Row(
        children: [
          const NumuwOrganicIcon(
            NumuwOrganicIconName.newborn,
            size: 52,
            semanticLabel: 'الطفل',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 18,
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
        ],
      ),
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
  Widget build(BuildContext context) {
    return AlertDialog(
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
}

class NumuwSuccessSheet extends StatelessWidget {
  const NumuwSuccessSheet({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
    decoration: BoxDecoration(
      color: numuwSurfaceColor(),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 18,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NumuwSuccessPulse(
            trigger: true,
            child: NumuwOrganicIcon(
              NumuwOrganicIconName.done,
              size: 48,
              semanticLabel: 'تم بنجاح',
            ),
          ),
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
          Icon(icon, color: AppColors.mintDark, size: 20),
          const SizedBox(height: 8),
        ],
        Text(
          value,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5),
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
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(top: 5),
        decoration: const BoxDecoration(
          color: AppColors.mint,
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
  Widget build(BuildContext context) => NumuwEntrance(
    child: NumuwCard(
      child: Row(
        children: [
          const NumuwOrganicIcon(
            NumuwOrganicIconName.notifications,
            size: 34,
            semanticLabel: 'تذكير',
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
      NumuwOrganicIcon(
        completed ? NumuwOrganicIconName.done : NumuwOrganicIconName.tasks,
        size: 28,
        semanticLabel: completed ? 'مكتملة' : 'مهمة غير مكتملة',
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
        Text(
          title,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: numuwSecondaryTextColor(),
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}
