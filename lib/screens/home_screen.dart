import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../models/care_event.dart';
import '../models/dashboard_summary.dart';
import '../models/family_task.dart';
import '../repositories/family_task_repository.dart';
import '../state/app_events.dart';
import '../state/child_session.dart';
import '../state/log_timer_state.dart';
import '../state/numuw_app_state.dart';
import '../widgets/app_widgets.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FamilyTaskRepository _taskRepository = FamilyTaskRepository();
  Future<DashboardSummary?>? _summaryFuture;

  @override
  void initState() {
    super.initState();
    _load();
    AppEvents.instance.addListener(_handleExternalChange);
    ChildSession.instance.addListener(_handleExternalChange);
    LogTimerState.instance.addListener(_handleTimerChange);
  }

  @override
  void dispose() {
    AppEvents.instance.removeListener(_handleExternalChange);
    ChildSession.instance.removeListener(_handleExternalChange);
    LogTimerState.instance.removeListener(_handleTimerChange);
    super.dispose();
  }

  void _load() {
    if (ChildSession.instance.selectedChild != null) {
      _summaryFuture = NumuwAppState.instance.refreshDashboard(force: true);
    }
  }

  void _handleExternalChange() {
    if (!mounted) return;
    setState(_load);
  }

  void _handleTimerChange() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    setState(_load);
    await _summaryFuture;
  }

  void _openRegister() => MainShellScope.maybeOf(context)?.selectTab(1);

  void _openChildSection(String section) =>
      MainShellScope.maybeOf(context)?.openChildSection(section);

  Future<void> _completeTask(
    DashboardSummary summary,
    FamilyTask task,
  ) async {
    final optimistic = summary.incompleteTasks
        .where((item) => item.id != task.id)
        .toList(growable: false);
    setState(() {
      _summaryFuture = Future.value(
        summary.copyWith(incompleteTasks: optimistic),
      );
    });

    try {
      await _taskRepository.setCompleted(task.id, true);
      AppEvents.instance.tasksChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('تم إنجاز المهمة'),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () async {
                await _taskRepository.setCompleted(task.id, false);
                AppEvents.instance.tasksChanged();
                await _refresh();
              },
            ),
          ),
        );
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(readableError(error))),
      );
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(message: 'أضيفي بيانات طفلك لبدء يومك مع نُمُوّ.'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: FutureBuilder<DashboardSummary?>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done &&
              !snapshot.hasData) {
            return const _HomeLoading();
          }

          if (snapshot.hasError) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    ErrorMessageCard(message: readableError(snapshot.error!)),
                    const SizedBox(height: 12),
                    PrimaryButton(label: 'إعادة المحاولة', onPressed: _refresh),
                  ],
                ),
              ),
            );
          }

          final summary = snapshot.data;
          return SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: numuwAccentColor(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 26),
                children: [
                  _HomeHeader(
                    childName: child.name,
                    onNotification: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('مركز الإشعارات جاهز من قسم المزيد.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _HeroCard(
                    childName: child.name,
                    ageLabel: _ageLabel(child.birthDate, child.dueDate),
                    summary: summary,
                    onTap: () => MainShellScope.maybeOf(context)?.selectTab(2),
                  ),
                  const SizedBox(height: 14),
                  _SummaryGrid(
                    summary: summary,
                    onRegister: _openRegister,
                  ),
                  const SizedBox(height: 24),
                  const _SectionHeading(title: 'التطعيم القادم'),
                  const SizedBox(height: 10),
                  _VaccinationCard(
                    summary: summary,
                    onTap: () => _openChildSection('vaccinations'),
                  ),
                  const SizedBox(height: 24),
                  const _SectionHeading(title: 'نصيحة اليوم'),
                  const SizedBox(height: 10),
                  const _InfoCard(
                    icon: Icons.lightbulb_outline_rounded,
                    tone: _CardTone.gold,
                    text:
                        'ضعي طفلك على بطنه لدقائق قليلة أثناء استيقاظه وتحت مراقبتك.',
                  ),
                  const SizedBox(height: 18),
                  const _SectionHeading(title: 'نشاط مناسب لعمر طفلك'),
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.auto_awesome_rounded,
                    tone: _CardTone.green,
                    text: 'تحدثي مع ${child.name} وقلّدي الأصوات التي يصدرها.',
                    onTap: () => _openChildSection('milestones'),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'مهام اليوم',
                    trailing: Text(
                      '${summary?.incompleteTasks.length ?? 0} متبقية',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TasksCard(
                    tasks: summary?.incompleteTasks ?? const <FamilyTask>[],
                    onComplete: summary == null
                        ? null
                        : (task) => _completeTask(summary, task),
                  ),
                  const SizedBox(height: 14),
                  _SafetyNote(onAsk: () => MainShellScope.maybeOf(context)?.selectTab(3)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.childName,
    required this.onNotification,
  });

  final String childName;
  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : 'مساء الخير';
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: numuwNightMode()
                ? AppColors.nightGold.withValues(alpha: .13)
                : AppColors.mintLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: numuwBorderColor()),
          ),
          child: Icon(
            Icons.nightlight_round,
            color: numuwAccentColor(),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'كيف حال $childName اليوم؟',
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: onNotification,
          badge: true,
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.childName,
    required this.ageLabel,
    required this.summary,
    required this.onTap,
  });

  final String childName;
  final String ageLabel;
  final DashboardSummary? summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = numuwAccentColor();
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 20, 18, 18),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient(numuwNightMode()),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: accent.withValues(alpha: numuwNightMode() ? .22 : .28),
            ),
            boxShadow: numuwNightMode()
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                start: -26,
                top: -36,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: .08),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طفلك اليوم',
                    style: TextStyle(
                      color: accent,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$childName عمره $ageLabel',
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 23,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: [
                      _MiniStat(
                        label: 'آخر رضعة',
                        value: _relativeTime(summary?.latestFeeding),
                      ),
                      _MiniStat(
                        label: 'آخر حفاضة',
                        value: _relativeTime(summary?.latestDiaper),
                      ),
                      _MiniStat(
                        label: 'نام اليوم',
                        value: _durationLabel(summary?.sleepToday),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary, required this.onRegister});

  final DashboardSummary? summary;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final feedingActive = LogTimerState.instance.feedingActive;
    final sleepActive = LogTimerState.instance.sleepActive;
    final items = [
      _SummaryData(
        title: 'الرضاعة',
        subtitle: feedingActive
            ? 'رضاعة جارية الآن'
            : _relativeTime(summary?.latestFeeding),
        action: feedingActive ? 'متابعة المؤقت' : 'تسجيل رضعة',
        icon: Icons.water_drop_outlined,
        tone: _CardTone.gold,
      ),
      _SummaryData(
        title: 'النوم',
        subtitle: sleepActive ? 'نوم جارٍ الآن' : _durationLabel(summary?.sleepToday),
        action: sleepActive ? 'متابعة المؤقت' : 'بدء النوم',
        icon: Icons.dark_mode_outlined,
        tone: _CardTone.blue,
      ),
      _SummaryData(
        title: 'الحفاضات',
        subtitle: _relativeTime(summary?.latestDiaper),
        action: 'تسجيل حفاضة',
        icon: Icons.opacity_rounded,
        tone: _CardTone.green,
      ),
      const _SummaryData(
        title: 'الدواء',
        subtitle: 'نظّمي الجرعات الموصوفة',
        action: 'إضافة دواء',
        icon: Icons.medication_outlined,
        tone: _CardTone.coral,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _SummaryCard(data: item, onTap: onRegister),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.onTap});

  final _SummaryData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = _toneColors(data.tone);
    return SoftCard(
      padding: const EdgeInsetsDirectional.all(15),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tone.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tone.foreground.withValues(alpha: .16)),
            ),
            child: Icon(data.icon, color: tone.foreground, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: numuwSecondaryTextColor(),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${data.action} ‹',
            style: TextStyle(
              color: numuwAccentColor(),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccinationCard extends StatelessWidget {
  const _VaccinationCard({required this.summary, required this.onTap});

  final DashboardSummary? summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vaccination = summary?.nextVaccination;
    final date = vaccination?.scheduledDate;
    final subtitle = vaccination == null
        ? 'لا يوجد موعد مسجل — أضيفي جدول التطعيمات'
        : date == null
        ? 'الموعد غير محدد بعد'
        : _dateLabel(date);

    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          _ToneIcon(icon: Icons.vaccines_outlined, tone: _CardTone.blue),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination?.name ?? 'جدول التطعيمات',
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 13,
                    height: 1.4,
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
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.tone,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final _CardTone tone;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ToneIcon(icon: icon, tone: tone),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 14.5,
              height: 1.65,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.tasks, required this.onComplete});

  final List<FamilyTask> tasks;
  final ValueChanged<FamilyTask>? onComplete;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SoftCard(
        child: Row(
          children: [
            _ToneIcon(icon: Icons.check_rounded, tone: _CardTone.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'أنجزتِ كل مهام اليوم. خذي نفسًا هادئًا 🤍',
                style: TextStyle(fontWeight: FontWeight.w800, height: 1.5),
              ),
            ),
          ],
        ),
      );
    }

    return SoftCard(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: List.generate(tasks.length, (index) {
          final task = tasks[index];
          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onComplete == null ? null : () => onComplete!(task),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: numuwAccentColor().withValues(alpha: .55),
                            width: 1.4,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: numuwAccentColor(),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: numuwTextColor(),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index != tasks.length - 1)
                Divider(color: numuwBorderColor(), height: 1),
            ],
          );
        }),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote({required this.onAsk});

  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(15),
    decoration: BoxDecoration(
      color: numuwNightMode()
          ? AppColors.nightGold.withValues(alpha: .07)
          : AppColors.mintLight.withValues(alpha: .72),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: numuwAccentColor().withValues(alpha: .17)),
    ),
    child: Row(
      children: [
        Icon(Icons.auto_awesome_rounded, color: numuwAccentColor(), size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'نُمُوّ يساعدك بالمعلومات والتنظيم، ولا يقدّم تشخيصًا طبيًا.',
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(onPressed: onAsk, child: const Text('اسألي')),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
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
      if (trailing != null) trailing!,
    ],
  );
}

class _ToneIcon extends StatelessWidget {
  const _ToneIcon({required this.icon, required this.tone});

  final IconData icon;
  final _CardTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.foreground.withValues(alpha: .14)),
      ),
      child: Icon(icon, color: colors.foreground, size: 22),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 11.5),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          color: numuwTextColor(),
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: numuwPageColor(),
    body: const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            LoadingSkeleton(height: 72),
            SizedBox(height: 14),
            LoadingSkeleton(height: 190),
            SizedBox(height: 14),
            LoadingSkeleton(height: 280),
          ],
        ),
      ),
    ),
  );
}

class _SummaryData {
  const _SummaryData({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String action;
  final IconData icon;
  final _CardTone tone;
}

enum _CardTone { gold, blue, green, coral }

class _ToneColors {
  const _ToneColors(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

_ToneColors _toneColors(_CardTone tone) {
  final night = numuwNightMode();
  return switch (tone) {
    _CardTone.gold => _ToneColors(
        night ? AppColors.nightGold : AppColors.mint,
        night
            ? AppColors.nightGold.withValues(alpha: .12)
            : AppColors.mintLight,
      ),
    _CardTone.blue => _ToneColors(
        night ? AppColors.nightInfo : AppColors.blue,
        night
            ? AppColors.nightInfo.withValues(alpha: .12)
            : AppColors.blueLight,
      ),
    _CardTone.green => _ToneColors(
        night ? AppColors.nightSuccess : AppColors.success,
        night
            ? AppColors.nightSuccess.withValues(alpha: .12)
            : AppColors.successLight,
      ),
    _CardTone.coral => _ToneColors(
        night ? AppColors.nightWarning : AppColors.peach,
        night
            ? AppColors.nightWarning.withValues(alpha: .12)
            : AppColors.peachLight,
      ),
  };
}

String _relativeTime(CareEvent? event) {
  if (event == null) return 'لا يوجد تسجيل';
  final difference = DateTime.now().difference(event.startedAt);
  if (difference.isNegative) return 'الآن';
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inHours < 1) return 'منذ ${difference.inMinutes} د';
  if (difference.inDays < 1) return 'منذ ${difference.inHours} س';
  return 'منذ ${difference.inDays} ي';
}

String _durationLabel(Duration? duration) {
  if (duration == null || duration == Duration.zero) return 'لا يوجد تسجيل';
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '$minutes دقيقة';
  return '$hours س و$minutes د';
}

String _ageLabel(DateTime? birthDate, DateTime? dueDate) {
  if (birthDate == null) {
    if (dueDate == null) return 'في مرحلة الحمل';
    final days = dueDate.difference(DateTime.now()).inDays;
    return days <= 0 ? 'موعد الولادة قريب' : 'متبقّي $days يومًا للولادة';
  }
  final days = DateTime.now().difference(birthDate).inDays.clamp(0, 5000);
  if (days < 14) return '$days يومًا';
  if (days < 90) return '${days ~/ 7} أسابيع و${days % 7} أيام';
  if (days < 730) return '${days ~/ 30} أشهر';
  final years = days ~/ 365;
  final months = (days % 365) ~/ 30;
  return months == 0 ? '$years سنوات' : '$years سنوات و$months أشهر';
}

String _dateLabel(DateTime date) {
  final days = date.difference(DateTime.now()).inDays;
  if (days == 0) return 'اليوم';
  if (days == 1) return 'غدًا';
  if (days > 1 && days < 30) return 'بعد $days أيام';
  return '${date.day}/${date.month}/${date.year}';
}
