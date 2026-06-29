import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../models/care_event.dart';
import '../models/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = DashboardRepository();
  Future<DashboardSummary>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child != null) _future = _repo.load(child.id);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null)
      return const Scaffold(
        body: AppPage(child: EmptyState(message: 'لا يوجد طفل محدد.')),
      );
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AppPage(
          child: Column(
            children: [
              AppHeader(
                title: 'مرحبًا يا ماما',
                subtitle: '${child.name} · ${ArabicFormatters.age(child)}',
                trailing: IconButton(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
              const SizedBox(height: 22),
              FutureBuilder<DashboardSummary>(
                future: _future ?? _repo.load(child.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done)
                    return const SoftCard(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  if (snapshot.hasError)
                    return EmptyState(
                      message: readableError(snapshot.error!),
                      icon: Icons.error_outline_rounded,
                    );
                  final summary = snapshot.data!;
                  return Column(
                    children: [
                      _Hero(childName: child.name),
                      const SizedBox(height: 22),
                      const SectionTitle(
                        title: 'ملخص اليوم',
                        icon: Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              title: 'نوم اليوم',
                              value: summary.sleepToday.inMinutes == 0
                                  ? 'لا توجد تسجيلات نوم اليوم'
                                  : ArabicFormatters.duration(
                                      summary.sleepToday,
                                    ),
                              icon: Icons.nightlight_round,
                              color: AppColors.mint,
                              bg: AppColors.mintLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Metric(
                              title: 'آخر رضعة',
                              value: summary.latestFeeding == null
                                  ? 'لا توجد رضعات مسجلة'
                                  : ArabicFormatters.time(
                                      summary.latestFeeding!.startedAt,
                                    ),
                              icon: Icons.local_drink_rounded,
                              color: AppColors.peach,
                              bg: AppColors.peachLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              title: 'آخر حفاضة',
                              value: summary.latestDiaper == null
                                  ? 'لا توجد تغييرات حفاضة مسجلة'
                                  : ArabicFormatters.time(
                                      summary.latestDiaper!.startedAt,
                                    ),
                              icon: Icons.baby_changing_station_rounded,
                              color: AppColors.purple,
                              bg: AppColors.purpleLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Metric(
                              title: 'التطعيم القادم',
                              value: summary.nextVaccination == null
                                  ? 'لم يتم تحديد تطعيم قادم'
                                  : '${summary.nextVaccination!.name}\n${ArabicFormatters.date(summary.nextVaccination!.scheduledDate)}',
                              icon: Icons.vaccines_rounded,
                              color: AppColors.yellow,
                              bg: AppColors.yellowLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SectionTitle(
                        title: 'المهام المعلقة',
                        icon: Icons.assignment_rounded,
                      ),
                      const SizedBox(height: 12),
                      summary.incompleteTasks.isEmpty
                          ? const EmptyState(message: 'لا توجد مهام معلقة')
                          : SoftCard(
                              child: Column(
                                children: summary.incompleteTasks
                                    .map(
                                      (task) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          task.title,
                                          textAlign: TextAlign.start,
                                        ),
                                        subtitle: Text(
                                          task.category ?? 'بدون تصنيف',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                      const SizedBox(height: 22),
                      const SectionTitle(
                        title: 'النشاط الأخير',
                        icon: Icons.history_rounded,
                      ),
                      const SizedBox(height: 12),
                      summary.recentEvents.isEmpty
                          ? const EmptyState(message: 'لا توجد أنشطة مسجلة بعد')
                          : SoftCard(
                              child: Column(
                                children: summary.recentEvents
                                    .map(_eventTile)
                                    .toList(),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventTile(CareEvent event) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(
      Icons.chevron_left_rounded,
      color: AppColors.secondaryText,
    ),
    title: Text(
      ArabicFormatters.eventType(event.eventType),
      textAlign: TextAlign.start,
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    subtitle: Text(
      '${ArabicFormatters.time(event.startedAt)}${event.notes == null ? '' : ' · ${event.notes}'}',
      textAlign: TextAlign.start,
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.childName});
  final String childName;
  @override
  Widget build(BuildContext context) => SoftCard(
    color: const Color(0xFFF0F8F5),
    padding: const EdgeInsets.all(18),
    child: Row(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEADF),
            borderRadius: BorderRadius.circular(55),
            border: Border.all(color: Colors.white, width: 5),
          ),
          child: const Icon(
            Icons.child_care_rounded,
            size: 62,
            color: AppColors.peach,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                childName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'بيانات اليوم من تسجيلاتك الحقيقية',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.all(14),
    child: SizedBox(
      height: 138,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: bg,
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}
