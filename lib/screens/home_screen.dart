Warning: truncated output (original token count: 16047)
Total output lines: 1910

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../design/numuw_organic_icons.dart';
import '../models/care_event.dart';
import '../models/child_profile.dart';
import '../models/dashboard_summary.dart';
import '../models/family_task.dart';
import '../repositories/care_event_repository.dart';
import '../repositories/family_task_repository.dart';
import '../state/app_events.dart';
import '../state/child_session.dart';
import '../state/log_timer_state.dart';
import '../state/numuw_app_state.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';
import 'main_shell.dart';
import 'pumping_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskRepo = FamilyTaskRepository();
  final _careRepo = CareEventRepository();
  Future<DashboardSummary?>? _future;

  @override
  void initState() {
    super.initState();
    _load();
    AppEvents.instance.addListener(_onCareEventsChanged);
    ChildSession.instance.addListener(_onChildChanged);
    NumuwAppState.instance.addListener(_onAppStateChanged);
    LogTimerState.instance.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    AppEvents.instance.removeListener(_onCareEventsChanged);
    ChildSession.instance.removeListener(_onChildChanged);
    NumuwAppState.instance.removeListener(_onAppStateChanged);
    LogTimerState.instance.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onCareEventsChanged() {
    if (mounted) setState(_load);
  }

  void _onChildChanged() {
    if (mounted) setState(_load);
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child != null) {
      _future = NumuwAppState.instance.refreshDashboard(force: true);
    }
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  void _showProfileTab() {
    MainShellScope.maybeOf(context)?.openChildSection('vaccinations');
  }

  Future<void> _completeTask(DashboardSummary summary, FamilyTask task) async {
    final updatedTasks = summary.incompleteTasks
        .where((item) => item.id != task.id)
        .toList();
    setState(() {
      _future = Future.value(summary.copyWith(incompleteTasks: updatedTasks));
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    final snack = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إنجاز المهمة'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () async {
            await _taskRepo.setCompleted(task.id, false);
            AppEvents.instance.tasksChanged();
            await _refresh();
          },
        ),
      ),
    );
    try {
      await _taskRepo.setCompleted(task.id, true);
      AppEvents.instance.tasksChanged();
      await snack.closed;
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(readableError(error))));
      await _refresh();
    }
  }

  Future<void> _deleteEvent(DashboardSummary summary, CareEvent event) async {
    if (event.isPumping) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف جلسة الشفط؟'),
            content: const Text('لن تتمكني من استعادة هذا التسجيل.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        ),
      );
      if (confirmed != true) return;
    }
    final updatedEvents = summary.recentEvents
        .where((item) => item.id != event.id)
        .toList();
    setState(() {
      _future = Future.value(summary.copyWith(recentEvents: updatedEvents));
    });
    try {
      await NumuwAppState.instance.deleteCareEvent(event);
      if (mounted) Navigator.pop(context);
      await _refresh();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
      }
      await _refresh();
    }
  }

  Future<void> _editEvent(DashboardSummary summary, CareEvent event) async {
    if (event.isPumping) {
      await _editPumpingEvent(summary, event);
      return;
    }
    final notes = TextEditingController(text: event.notes ?? '');
    final amount = TextEditingController(
      text: event.amountMl == null ? '' : event.amountMl!.round().toString(),
    );
    final medicine = TextEditingController(text: event.medicineName ?? '');
    final dose = TextEditingController(text: event.medicineDose ?? '');
    final temp = TextEditingController(
      text: event.temperatureC?.toString() ?? '',
    );
    final food = TextEditingController(
      text: event.metadata?['food_name']?.toString() ?? '',
    );
    final foodAmount = TextEditingController(
      text: event.metadata?['description']?.toString() ?? '',
    );
    var side = event.side ?? 'right';
    var feedingMethod = event.feedingMethod ?? 'breast';
    var diaperType = _diaperTypeValue(event);
    var burped = event.burped ?? false;
    var vomited = event.vomited ?? false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('تعديل ${ArabicFormatters.eventType(event.eventType)}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (event.eventType == 'feeding') ...[
                    _DialogDropdown(
                      label: 'الجهة',
                      value: side,
                      items: const {
                        'right': 'اليمنى',
                        'left': 'اليسرى',
                        'both': 'كلاهما',
                      },
                      onChanged: (value) => setDialogState(() => side = value),
                    ),
                    _DialogDropdown(
                      label: 'طريقة الرضاعة',
                      value: feedingMethod,
                      items: const {
                        'breast': 'طبيعية',
                        'bottle': 'زجاجة',
                        'formula': 'صناعية',
                        'pumping': 'شفط',
                        'mixed': 'مختلطة',
                      },
                      onChanged: (value) =>
                          setDialogState(() => feedingMethod = value),
                    ),
                    _DialogTextField(
                      controller: amount,
                      label: 'الكمية مل',
                      keyboardType: TextInputType.number,
                    ),
                    _DialogSwitch(
                      label: 'تجشأ',
                      value: burped,
                      onChanged: (value) =>
                          setDialogState(() => burped = value),
                    ),
                    _DialogSwitch(
                      label: 'استفرغ',
                      value: vomited,
                      onChanged: (value) =>
                          setDialogState(() => vomited = value),
                    ),
                  ] else if (event.eventType == 'diaper') ...[
                    _DialogDropdown(
                      label: 'نوع الحفاضة',
                      value: diaperType,
                      items: const {
                        'wet': 'مبللة',
                        'dirty': 'متسخة',
                        'both': 'مبللة ومتسخة',
                      },
                      onChanged: (value) =>
                          setDialogState(() => diaperType = value),
                    ),
                  ] else if (event.eventType == 'food') ...[
                    _DialogTextField(controller: food, label: 'اسم الطعام'),
                    _DialogTextField(
                      controller: foodAmount,
                      label: 'الكمية أو الوصف',
                    ),
                  ] else if (event.eventType == 'medicine') ...[
                    _DialogTextField(controller: medicine, label: 'اسم الدواء'),
                    _DialogTextField(controller: dose, label: 'الجرعة'),
                  ] else if (event.eventType == 'temperature') ...[
                    _DialogTextField(
                      controller: temp,
                      label: 'درجة الحرارة',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  _DialogTextField(
                    controller: notes,
                    label: 'الملاحظات',
                    minLines: 3,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
    if (saved != true) {
      for (final controller in [
        notes,
        amount,
        medicine,
        dose,
        temp,
        food,
        foodAmount,
      ]) {
        controller.dispose();
      }
      return;
    }
    try {
      final metadata = Map<String, dynamic>.from(
        event.metadata ?? <String, dynamic>{},
      );
      if (event.eventType == 'food') {
        metadata['food_name'] = food.text.trim();
        metadata['description'] = foodAmount.text.trim();
      }
      if (event.eventType == 'feeding') {
        metadata['feeding_methods'] = [feedingMethod];
      }
      final updated = await _careRepo.update(
        id: event.id,
        side: event.eventType == 'feeding' ? side : null,
        feedingMethod: event.eventType == 'feeding' ? feedingMethod : null,
        amountMl: event.eventType == 'feeding'
            ? double.tryParse(amount.text.trim().replaceAll(',', '.'))
            : null,
        burped: event.eventType == 'feeding' ? burped : null,
        vomited: event.eventType == 'feeding' ? vomited : null,
        diaperWet: event.eventType == 'diaper' ? diaperType != 'dirty' : null,
        diaperDirty: event.eventType == 'diaper' ? diaperType != 'wet' : null,
        medicineName: event.eventType == 'medicine' ? medicine.text : null,
        medicineDose: event.eventType == 'medicine' ? dose.text : null,
        temperatureC: event.eventType == 'temperature'
            ? double.tryParse(temp.text.trim().replaceAll(',', '.'))
            : null,
        notes: notes.text,
        metadata: metadata,
      );
      final updatedEvents = summary.recentEvents
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      setState(() {
        _future = Future.value(summary.copyWith(recentEvents: updatedEvents));
      });
      AppEvents.instance.careEventsChanged();
      if (mounted) Navigator.pop(context);
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
      }
    } finally {
      for (final controller in [
        notes,
        amount,
        medicine,
        dose,
        temp,
        food,
        foodAmount,
      ]) {
        controller.dispose();
      }
    }
  }

  Future<void> _editPumpingEvent(
    DashboardSummary summary,
    CareEvent event,
  ) async {
    final notes = TextEditingController(text: event.notes ?? '');
    final total = TextEditingController(
      text: event.pumpedAmountMl == null
          ? ''
          : event.pumpedAmountMl!.round().toString(),
    );
    final left = TextEditingController(
      text: event.leftPumpedAmountMl == null
          ? ''
          : event.leftPumpedAmountMl!.round().toString(),
    );
    final right = TextEditingController(
      text: event.rightPumpedAmountMl == null
          ? ''
          : event.rightPumpedAmountMl!.round().toString(),
    );
    var side = event.side ?? 'both';
    var split = event.hasSplitPumpingQuantity;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            void recalculate() {
              final sum =
                  (_parseAmount(left.text) ?? 0) +
                  (_parseAmount(right.text) ?? 0);
              total.text = sum <= 0 ? '' : sum.round().toString();
              setDialogState(() {});
            }

            return AlertDialog(
              title: const Text('تعديل جلسة الشفط'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogDropdown(
                      label: 'الجهة',
                      value: side,
                      items: const {
                        'left': 'اليسار',
                        'right': 'اليمين',
                        'both': 'الجانبان',
                      },
                      onChanged: (value) => setDialogState(() => side = value),
                    ),
                    _DialogTextField(
                      controller: total,
                      label: 'إجمالي الكمية مل',
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('تقسيم الكمية بين الجانبين'),
                      value: split,
                      onChanged: (value) => setDialogState(() => split = value),
                    ),
                    if (split) ...[
                      _DialogTextField(
                        controller: left,
                        label: 'كمية اليسار',
                        keyboardType: TextInputType.number,
                      ),
                      _DialogTextField(
                        controller: right,
                        label: 'كمية اليمين',
                        keyboardType: TextInputType.number,
                      ),
                      TextButton(
                        onPressed: recalculate,
                        child: const Text('تحديث الإجمالي'),
                      ),
                    ],
                    _DialogTextField(
                      controller: notes,
                      label: 'الملاحظات',
                      minLines: 3,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        ),
      ),
    );
    if (saved != true) {
      for (final controller in [notes, total, left, right]) {
        controller.dispose();
      }
      return;
    }
    try {
      final metadata = Map<String, dynamic>.from(
        event.metadata ?? <String, dynamic>{},
      );
      final leftAmount = _parseAmount(left.text);
      final rightAmount = _parseAmount(right.text);
      final totalAmount = split
          ? ((leftAmount ?? 0) + (rightAmount ?? 0))
          : _parseAmount(total.text);
      if (totalAmount == null || totalAmount <= 0) {
        throw const FormatException('invalid pumping amount');
      }
      metadata['quantity_mode'] = split ? 'split' : 'total';
      if (split && leftAmount != null) metadata['left_amount_ml'] = leftAmount;
      if (split && rightAmount != null) {
        metadata['right_amount_ml'] = rightAmount;
      }
      if (!split) {
        metadata.remove('left_amount_ml');
        metadata.remove('right_amount_ml');
      }
      final updated = await NumuwAppState.instance.updateCareEventFields(
        event: event,
        values: {
          'side': side,
          'amount_ml': totalAmount,
          'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
          'metadata': metadata,
        },
      );
      final updatedEvents = summary.recentEvents
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      setState(() {
        _future = Future.value(summary.copyWith(recentEvents: updatedEvents));
      });
      if (mounted) Navigator.pop(context);
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تعديل جلسة الشفط. حاولي مرة أخرى.'),
          ),
        );
      }
    } finally {
      for (final controller in [notes, total, left, right]) {
        controller.dispose();
      }
    }
  }

  void _showEventDetails(DashboardSummary summary, CareEvent event) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: numuwSurfaceColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                    icon: _eventIcon(event.eventType),
                    background: _eventBg(event.eventType),
                    size: 46,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ArabicFormatters.eventType(event.eventType),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: numuwTextColor(),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._eventDetails(event).map((detail) => _DetailRow(detail)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'تعديل',
                      onPressed: () => _editEvent(summary, event),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'حذف',
                      color: AppColors.danger,
                      onPressed: () => _deleteEvent(summary, event),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: 'مرحباً ماما 💚',
                subtitle: 'أنتِ تقومين بعمل رائع اليوم 🧡',
                trailing: AppIconButton(
                  icon: Icons.refresh_rounded,
                  onPressed: _refresh,
                ),
              ),
              const SizedBox(height: 18),
              FutureBuilder<DashboardSummary?>(
                future:
                    _future ??
                    NumuwAppState.instance.refreshDashboard(force: false),
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
                  final summary =
                      NumuwAppState.instance.dashboard ?? snapshot.data!;
                  if (numuwNightMode()) {
                    return _NightHome(childName: child.name, summary: summary);
                  }
                  final dailyProgress =
                      [
                        summary.latestFeeding != null,
                        summary.latestDiaper != null,
                        summary.sleepToday.inMinutes > 0,
                        summary.nextVaccination != null,
                        summary.incompleteTasks.isEmpty,
                      ].where((value) => value).length /
                      5.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NumuwAppBar(
                        title: 'مرحباً ماما 💚',
                        subtitle: 'أنتِ تقومين بعمل رائع اليوم 🧡',
                        trailing: AppIconButton(
                          icon: Icons.refresh_rounded,
                          onPressed: _refresh,
                        ),
                      ),
                      const SizedBox(height: 14),
                      NumuwPlantProgress(
                        progress: dailyProgress == 0 ? .22 : dailyProgress,
                        label: dailyProgress == 0
                            ? 'البذرة الأولى'
                            : dailyProgress < .6
                            ? 'السجل ينمو'
                            : 'يوم متوازن',
                      ),
                      const SizedBox(height: 16),
            …4047 tokens truncated…ration(
      color: background,
      borderRadius: BorderRadius.circular(size * .34),
    ),
    child: NumuwOrganicIcon(icon, size: size * .82),
  );
}

class _NightHome extends StatelessWidget {
  const _NightHome({required this.childName, required this.summary});

  final String childName;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.all(18),
    decoration: BoxDecoration(
      color: AppColors.nightBackground,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'وضع الليل الهادئ',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.nightText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.nightGold.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'نهاري ☀️',
                style: TextStyle(
                  color: AppColors.nightGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'مرحباً ماما، أنتِ تقومين بعمل رائع 💛',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: AppColors.nightSecondaryText,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        _NightChildCard(childName: childName),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _NightMetric(
                title: 'آخر رضعة',
                value: summary.latestFeeding == null
                    ? 'لا توجد'
                    : ArabicFormatters.time(summary.latestFeeding!.startedAt),
                icon: '🍼',
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _NightMetric(
                title: 'حفاضة',
                value: summary.latestDiaper == null
                    ? 'لا توجد'
                    : ArabicFormatters.time(summary.latestDiaper!.startedAt),
                icon: '🧷',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'تسجيل سريع',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: AppColors.nightText,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const _NightAction(icon: '🍼', label: 'بدء رضاعة جديدة'),
        const SizedBox(height: 8),
        const _NightAction(icon: '🧷', label: 'تغيير حفاضة'),
        const SizedBox(height: 8),
        const _NightAction(icon: '🌙', label: 'بدء جلسة نوم'),
      ],
    ),
  );
}

class _NightChildCard extends StatelessWidget {
  const _NightChildCard({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.all(16),
    decoration: BoxDecoration(
      color: AppColors.nightSurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.nightBorder),
    ),
    child: Row(
      children: [
        const IconBadge(
          icon: '👶',
          background: AppColors.nightSurfaceSoft,
          size: 54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            childName,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: AppColors.nightText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _NightMetric extends StatelessWidget {
  const _NightMetric({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(14),
    decoration: BoxDecoration(
      color: AppColors.nightSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.nightBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: AppColors.nightSecondaryText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: AppColors.nightGold,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _NightAction extends StatelessWidget {
  const _NightAction({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: AppColors.nightSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.nightBorder),
    ),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: AppColors.nightText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _InsightGrid extends StatelessWidget {
  const _InsightGrid({required this.child});

  final ChildProfile child;

  int get _ageDays {
    final birth = child.birthDate;
    if (birth == null) return 0;
    return DateTime.now()
        .difference(DateTime(birth.year, birth.month, birth.day))
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tipFor(child, _ageDays);
    final activities = _activitiesFor(child, _ageDays);
    final activity = activities.first;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 11,
      crossAxisSpacing: 11,
      childAspectRatio: 1.18,
      children: [
        _InfoMiniCard(
          title: 'نصيحة اليوم',
          icon: NumuwOrganicIconName.tips,
          iconBackground: AppColors.mintLight,
          body: tip.summary,
          action: 'اقرئي المزيد ‹',
          actionColor: AppColors.mint,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => _TipDetailScreen(tip: tip)),
          ),
        ),
        _InfoMiniCard(
          title: 'نشاط مناسب',
          icon: NumuwOrganicIconName.milestones,
          iconBackground: AppColors.yellowLight,
          body: '${activity.title}\n${activity.duration}',
          action: 'عرض الأنشطة ‹',
          actionColor: AppColors.peach,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ActivitiesScreen(activities: activities),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoMiniCard extends StatelessWidget {
  const _InfoMiniCard({
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.body,
    required this.action,
    required this.actionColor,
    this.onTap,
  });

  final String title;
  final NumuwOrganicIconName icon;
  final Color iconBackground;
  final String body;
  final String action;
  final Color actionColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    padding: const EdgeInsetsDirectional.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            _OrganicBadge(icon: icon, background: iconBackground, size: 30),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwSecondaryTextColor(),
            fontSize: 12,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          action,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: actionColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    ),
  );
}

class _TrustedTip {
  const _TrustedTip({
    required this.title,
    required this.summary,
    required this.body,
    required this.points,
    required this.source,
    required this.reviewedAt,
  });

  final String title;
  final String summary;
  final String body;
  final List<String> points;
  final String source;
  final String reviewedAt;
}

class _AgeActivity {
  const _AgeActivity({
    required this.title,
    required this.duration,
    required this.tools,
    required this.steps,
    required this.benefit,
    this.warning,
  });

  final String title;
  final String duration;
  final String tools;
  final List<String> steps;
  final String benefit;
  final String? warning;
}

_TrustedTip _tipFor(ChildProfile child, int ageDays) {
  if (child.stage == 'pregnancy') {
    return const _TrustedTip(
      title: 'متابعة الحركة والراحة',
      summary: 'راقبي نمط الحركة ودوّني أي تغير واضح لمناقشته مع الطبيب.',
      body:
          'خلال الحمل، يساعد تدوين الملاحظات اليومية على تذكر الأسئلة المهمة في الزيارة القادمة. لا تستخدمي التطبيق للحكم على سلامة الحمل؛ عند أي عرض مقلق تواصلي مع الطبيب.',
      points: [
        'دوّني الأسئلة فور ظهورها',
        'تابعي مواعيد الزيارات',
        'راجعي الطبيب عند أي عرض غير معتاد',
      ],
      source: 'إرشادات عامة للصحة الأمومية',
      reviewedAt: '2026-06-30',
    );
  }
  if (ageDays >= 150) {
    return const _TrustedTip(
      title: 'بداية الطعام التكميلي',
      summary:
          'عند العمر المناسب، قدمي أطعمة بسيطة واحدة في كل مرة حسب إرشاد الطبيب.',
      body:
          'ابدئي بكميات صغيرة وقوام مناسب، وراقبي أي تفاعل غير معتاد. لا تستبدلي الرضاعة أو تعليمات الطبيب بنصائح عامة داخل التطبيق.',
      points: [
        'ابدئي بنوع واحد',
        'راقبي التفاعل',
        'تجنبي القطع الصلبة أو خطر الاختناق',
      ],
      source: 'إرشادات عامة للتغذية التكميلية',
      reviewedAt: '2026-06-30',
    );
  }
  return const _TrustedTip(
    title: 'الارتباط أثناء الرضاعة',
    summary:
        'التواصل البصري والهدوء أثناء الرضاعة يساعدان على بناء روتين مريح.',
    body:
        'حاولي جعل وقت الرضاعة هادئاً قدر الإمكان، مع ملاحظة مدة الرضعة والكمية عند الحاجة. هذه معلومات تنظيمية وليست تقييماً طبياً.',
    points: [
      'اختاري مكاناً هادئاً',
      'سجلي الملاحظات المهمة',
      'راجعي الطبيب عند صعوبة الرضاعة أو الخمول',
    ],
    source: 'إرشادات عامة لرعاية الرضيع',
    reviewedAt: '2026-06-30',
  );
}

List<_AgeActivity> _activitiesFor(ChildProfile child, int ageDays) {
  if (child.stage == 'pregnancy') {
    return const [
      _AgeActivity(
        title: 'تحضير أسئلة الزيارة',
        duration: '5 دقائق',
        tools: 'ملاحظاتك داخل التطبيق',
        steps: [
          'اكتبي 3 أسئلة للطبيب',
          'راجعي آخر الأعراض أو الملاحظات',
          'احفظيها في أسئلة الطبيب',
        ],
        benefit: 'يساعدك على زيارة منظمة وواضحة.',
      ),
    ];
  }
  if (ageDays < 90) {
    return const [
      _AgeActivity(
        title: 'وقت البطن',
        duration: '3-5 دقائق',
        tools: 'بطانية آمنة وسطح ثابت',
        steps: [
          'ضعي الطفل على بطنه وهو مستيقظ',
          'ابقي بجانبه طوال الوقت',
          'أوقفي النشاط إذا ظهر انزعاج واضح',
        ],
        benefit: 'يساعد على تقوية الرقبة والكتفين بشكل عام.',
        warning: 'لا يترك الطفل على بطنه أثناء النوم.',
      ),
      _AgeActivity(
        title: 'تتبع لعبة بالعين',
        duration: '2-3 دقائق',
        tools: 'لعبة آمنة عالية التباين',
        steps: [
          'أمسكي اللعبة أمام الطفل',
          'حركيها ببطء يميناً ويساراً',
          'راقبي انتباه الطفل بدون إجهاد',
        ],
        benefit: 'يدعم الانتباه البصري المبكر.',
      ),
    ];
  }
  return const [
    _AgeActivity(
      title: 'لمس خامات آمنة',
      duration: '5-10 دقائق',
      tools: 'قماش ناعم وخامة آمنة كبيرة الحجم',
      steps: [
        'قدمي خامة واحدة في كل مرة',
        'صفي الإحساس بكلمات بسيطة',
        'أبعدي أي قطعة صغيرة',
      ],
      benefit: 'يساعد على الاستكشاف الحسي الآمن.',
      warning: 'تجنبي أي أدوات صغيرة أو قابلة للبلع.',
    ),
    _AgeActivity(
      title: 'قراءة قصة قصيرة',
      duration: '5 دقائق',
      tools: 'كتاب قماشي أو كرتوني',
      steps: ['اقرئي بصوت هادئ', 'أشيري للصور', 'اتركي وقتاً لاستجابة الطفل'],
      benefit: 'يدعم اللغة والروتين الهادئ.',
    ),
  ];
}

class _TipDetailScreen extends StatelessWidget {
  const _TipDetailScreen({required this.tip});

  final _TrustedTip tip;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwHeader(
            title: tip.title,
            subtitle: 'محتوى عام مراجع داخل التطبيق',
            leading: AppIconButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.pop(context),
              badge: false,
            ),
          ),
          const SizedBox(height: 18),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.body,
                  textAlign: TextAlign.start,
                  style: const TextStyle(height: 1.7),
                ),
                const SizedBox(height: 14),
                ...tip.points.map(
                  (point) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8),
                    child: Text('• $point', textAlign: TextAlign.start),
                  ),
                ),
                const SizedBox(height: 10),
                Text('المصدر: ${tip.source}', textAlign: TextAlign.start),
                Text(
                  'آخر مراجعة: ${tip.reviewedAt}',
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ActivitiesScreen extends StatelessWidget {
  const _ActivitiesScreen({required this.activities});

  final List<_AgeActivity> activities;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwHeader(
            title: 'أنشطة مناسبة',
            subtitle: 'اختاري نشاطاً بسيطاً وآمناً لعمر الطفل',
            leading: AppIconButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.pop(context),
              badge: false,
            ),
          ),
          const SizedBox(height: 18),
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: numuwTextColor(),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'المدة: ${activity.duration}',
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'الأدوات: ${activity.tools}',
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 10),
                    ...activity.steps.map(
                      (step) => Text('• $step', textAlign: TextAlign.start),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الفائدة: ${activity.benefit}',
                      textAlign: TextAlign.start,
                    ),
                    if (activity.warning != null) ...[
                      const SizedBox(height: 10),
                      WarningBanner(message: activity.warning!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.summary, required this.onComplete});

  final DashboardSummary summary;
  final ValueChanged<FamilyTask> onComplete;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsetsDirectional.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: NumuwSectionHeader(
                  title: 'مهام لم تكتمل',
                  icon: Icons.assignment_rounded,
                ),
              ),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(7),
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
          const SizedBox(height: 14),
          if (summary.incompleteTasks.isEmpty)
            Text(
              'لا توجد مهام معلقة',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 14,
                height: 1.45,
              ),
            )
          else
            ...summary.incompleteTasks
                .take(3)
                .map(
                  (task) => InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onComplete(task),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(top: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              task.title,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: numuwTextColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
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
  'pumping' => '🍼',
  'sleep' => '🌙',
  'diaper' => '🧷',
  'food' => '🥣',
  'medicine' => '💊',
  'temperature' => '🌡️',
  _ => '📝',
};

Color _eventBg(String type) => switch (type) {
  'feeding' => AppColors.mintLight,
  'pumping' => AppColors.mintSoft,
  'sleep' => AppColors.mintLight,
  'diaper' => AppColors.purpleLight,
  'food' => AppColors.yellowLight,
  'medicine' => AppColors.blueLight,
  'temperature' => AppColors.peachLight,
  _ => AppColors.mintLight,
};
