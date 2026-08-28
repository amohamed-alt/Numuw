import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../core/formatters/arabic_formatters.dart';
import '../../models/care_event.dart';
import '../../models/dashboard_summary.dart';
import '../../state/app_events.dart';
import '../../state/child_session.dart';
import '../../state/numuw_app_state.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/classy/classy_home_view.dart';
import '../main_shell.dart';

class ClassyHomeScreen extends StatefulWidget {
  const ClassyHomeScreen({super.key});

  @override
  State<ClassyHomeScreen> createState() => _ClassyHomeScreenState();
}

class _ClassyHomeScreenState extends State<ClassyHomeScreen> {
  Future<DashboardSummary?>? _future;

  @override
  void initState() {
    super.initState();
    _load(force: false);
    ChildSession.instance.addListener(_onChanged);
    AppEvents.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    ChildSession.instance.removeListener(_onChanged);
    AppEvents.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() => _load(force: true));
  }

  void _load({required bool force}) {
    final child = ChildSession.instance.selectedChild;
    _future = child == null
        ? Future<DashboardSummary?>.value(null)
        : NumuwAppState.instance.refreshDashboard(force: force);
  }

  Future<void> _refresh() async {
    setState(() => _load(force: true));
    await _future;
  }

  void _openQuickLog() => MainShellScope.maybeOf(context)?.selectTab(1);

  void _openChild() => MainShellScope.maybeOf(context)?.selectTab(2);

  void _openVaccinations() =>
      MainShellScope.maybeOf(context)?.openChildSection('vaccinations');

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      return const Scaffold(
        body: AppPage(
          child: EmptyState(message: 'اختاري طفلًا أولًا لعرض اليوم.'),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AppPage(
          child: FutureBuilder<DashboardSummary?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _ClassyHomeSkeleton();
              }
              if (snapshot.hasError) {
                return _ClassyHomeError(
                  message: readableError(snapshot.error!),
                  onRetry: _refresh,
                );
              }
              final summary =
                  NumuwAppState.instance.dashboard ?? snapshot.data;
              if (summary == null) {
                return _ClassyHomeError(
                  message: 'تعذر تحميل ملخص اليوم.',
                  onRetry: _refresh,
                );
              }

              final data = ClassyHomeViewData(
                greeting: 'مرحباً يا ماما',
                subtitle: 'يوم هادئ وواضح مع ${child.name}',
                childName: child.name,
                childAge: ArabicFormatters.age(child),
                latestFeeding: summary.latestFeeding == null
                    ? 'لسه مفيش'
                    : ArabicFormatters.time(summary.latestFeeding!.startedAt),
                sleepToday: summary.sleepToday.inMinutes == 0
                    ? 'لسه مفيش'
                    : ArabicFormatters.duration(summary.sleepToday),
                latestDiaper: summary.latestDiaper == null
                    ? 'لسه مفيش'
                    : ArabicFormatters.time(summary.latestDiaper!.startedAt),
                nextVaccination: summary.nextVaccination == null
                    ? 'غير محدد'
                    : summary.nextVaccination!.name,
                timeline: summary.recentEvents
                    .take(3)
                    .map(_timelineItem)
                    .toList(growable: false),
              );

              return ClassyHomeView(
                data: data,
                onRefresh: _refresh,
                onChildTap: _openChild,
                onVaccinationTap: _openVaccinations,
                onViewAll: _openQuickLog,
                onFeeding: _openQuickLog,
                onPumping: _openQuickLog,
                onSleep: _openQuickLog,
                onDiaper: _openQuickLog,
                onFood: _openQuickLog,
                onMedicine: _openQuickLog,
              );
            },
          ),
        ),
      ),
    );
  }
}

ClassyHomeTimelineItem _timelineItem(CareEvent event) {
  final type = event.isPumping ? 'pumping' : event.eventType;
  return ClassyHomeTimelineItem(
    title: ArabicFormatters.eventType(type),
    subtitle: _eventSubtitle(event),
    time: ArabicFormatters.time(event.startedAt),
    color: switch (type) {
      'sleep' => const Color(0xFF8D7399),
      'diaper' => AppColors.info,
      'food' => AppColors.warning,
      'medicine' || 'temperature' => AppColors.danger,
      _ => AppColors.plum,
    },
  );
}

String _eventSubtitle(CareEvent event) {
  final notes = event.notes?.trim();
  if (notes != null && notes.isNotEmpty) return notes;
  if (event.endedAt != null) {
    final duration = event.endedAt!.difference(event.startedAt);
    if (duration.inMinutes > 0) return ArabicFormatters.duration(duration);
  }
  if (event.amountMl != null) return '${event.amountMl!.round()} مل';
  if (event.pumpedAmountMl != null) {
    return '${event.pumpedAmountMl!.round()} مل';
  }
  return 'تم التسجيل';
}

class _ClassyHomeSkeleton extends StatelessWidget {
  const _ClassyHomeSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 170,
        height: 24,
        decoration: BoxDecoration(
          color: numuwBorderColor().withValues(alpha: .65),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: 230,
        height: 12,
        decoration: BoxDecoration(
          color: numuwBorderColor().withValues(alpha: .45),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      const SizedBox(height: 18),
      for (var i = 0; i < 4; i++) ...[
        Container(
          height: i == 0 ? 112 : 92,
          decoration: BoxDecoration(
            color: numuwSurfaceColor(),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: numuwBorderColor()),
          ),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class _ClassyHomeError extends StatelessWidget {
  const _ClassyHomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}
