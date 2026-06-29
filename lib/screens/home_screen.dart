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
    if (child == null) {
      return const Scaffold(
        body: AppPage(child: EmptyState(message: 'لا يوجد طفل محدد.')),
      );
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AppPage(
          child: Column(
            children: [
              AppHeader(
                title: 'صباح الخير يا ماما',
                subtitle: '${child.name} · ${ArabicFormatters.age(child)}',
                trailing: AppIconButton(
                  icon: Icons.refresh_rounded,
                  onPressed: _refresh,
                ),
              ),
              const SizedBox(height: 18),
              FutureBuilder<DashboardSummary>(
                future: _future ?? _repo.load(child.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SoftCard(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      message: readableError(snapshot.error!),
                      icon: Icons.error_outline_rounded,
                    );
                  }
                  final summary = snapshot.data!;
                  return Column(
                    children: [
                      _HeroCard(childName: child.name),
                      const SizedBox(height: 18),
                      const SectionTitle(
                        title: 'ملخص اليوم',
                        icon: Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 11,
                        crossAxisSpacing: 11,
                        childAspectRatio: .96,
                        children: [
                          _MetricCard(
                            title: 'آخر رضعة',
                            value: summary.latestFeeding == null
                                ? 'لا توجد رضعات مسجلة'
                                : ArabicFormatters.time(
                                    summary.latestFeeding!.startedAt,
                                  ),
                            label: summary.latestFeeding == null ? '' : 'في',
                            icon: '🍼',
                            color: AppColors.peach,
                            bg: AppColors.peachLight,
                          ),
                          _MetricCard(
                            title: 'نوم اليوم',
                            value: summary.sleepToday.inMinutes == 0
                                ? 'لا توجد تسجيلات نوم اليوم'
                                : ArabicFormatters.duration(summary.sleepToday),
                            icon: '🌙',
                            color: AppColors.mint,
                            bg: AppColors.mintLight,
                          ),
                          _MetricCard(
                            title: 'آخر تغيير حفاضة',
                            value: summary.latestDiaper == null
                                ? 'لا توجد تغييرات حفاضة مسجلة'
                                : ArabicFormatters.time(
                                    summary.latestDiaper!.startedAt,
                                  ),
                            label: summary.latestDiaper == null ? '' : 'في',
                            icon: '🧷',
                            color: AppColors.purple,
                            bg: AppColors.purpleLight,
                          ),
                          _MetricCard(
                            title: 'التطعيم القادم',
                            value: summary.nextVaccination == null
                                ? 'لم يتم تحديد تطعيم قادم'
                                : summary.nextVaccination!.name,
                            label: summary.nextVaccination == null
                                ? ''
                                : ArabicFormatters.date(
                                    summary.nextVaccination!.scheduledDate,
                                  ),
                            icon: '💉',
                            color: AppColors.yellow,
                            bg: AppColors.yellowLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _TasksCard(summary: summary),
                      const SizedBox(height: 18),
                      const SectionTitle(
                        title: 'النشاط الأخير',
                        icon: Icons.history_rounded,
                      ),
                      const SizedBox(height: 12),
                      summary.recentEvents.isEmpty
                          ? const EmptyState(message: 'لا توجد أنشطة مسجلة بعد')
                          : SoftCard(
                              padding: EdgeInsets.zero,
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
    contentPadding: const EdgeInsetsDirectional.fromSTEB(15, 8, 15, 8),
    leading: IconBadge(
      icon: _eventIcon(event.eventType),
      background: _eventBg(event.eventType),
      size: 36,
    ),
    title: Text(
      ArabicFormatters.eventType(event.eventType),
      textAlign: TextAlign.start,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
    ),
    subtitle: Text(
      '${ArabicFormatters.time(event.startedAt)}${event.notes == null ? '' : ' · ${event.notes}'}',
      textAlign: TextAlign.start,
      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
    ),
    trailing: const Icon(
      Icons.chevron_left_rounded,
      color: AppColors.mutedText,
    ),
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.mintLight, AppColors.mintSoft],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -38,
            end: -30,
            child: _bubble(96, AppColors.mint.withValues(alpha: .15)),
          ),
          PositionedDirectional(
            bottom: -50,
            start: 48,
            child: _bubble(112, AppColors.mint.withValues(alpha: .10)),
          ),
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.mint.withValues(alpha: .25),
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3359B8A5),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text('👶', style: TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childName,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'بيانات اليوم من تسجيلاتك الحقيقية',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.mintDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    this.label = '',
  });

  final String title;
  final String value;
  final String icon;
  final Color color;
  final Color bg;
  final String label;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsetsDirectional.all(16),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      label,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconBadge(icon: icon, background: bg, size: 42),
          ],
        ),
        const Spacer(),
        Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
      ],
    ),
  );
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.incompleteTasks.isEmpty) {
      return const EmptyState(message: 'لا توجد مهام معلقة');
    }
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionTitle(
                  title: 'مهام لم تكتمل',
                  icon: Icons.assignment_rounded,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${summary.incompleteTasks.length}',
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...summary.incompleteTasks
              .take(3)
              .map(
                (task) => Padding(
                  padding: const EdgeInsetsDirectional.only(top: 6),
                  child: Text(
                    '• ${task.title}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

String _eventIcon(String type) => switch (type) {
  'feeding' => '🍼',
  'sleep' => '🌙',
  'diaper' => '🧷',
  'food' => '🥣',
  'medicine' => '💊',
  'temperature' => '🌡️',
  _ => '📝',
};

Color _eventBg(String type) => switch (type) {
  'feeding' => AppColors.peachLight,
  'sleep' => AppColors.mintLight,
  'diaper' => AppColors.purpleLight,
  'food' => AppColors.yellowLight,
  'medicine' => AppColors.blueLight,
  'temperature' => AppColors.peachLight,
  _ => AppColors.mintLight,
};
