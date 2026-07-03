import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../models/care_event.dart';
import '../models/pumping_analytics.dart';
import '../repositories/care_event_repository.dart';
import '../state/child_session.dart';
import '../state/log_timer_state.dart';
import '../state/numuw_app_state.dart';
import '../widgets/app_widgets.dart';

class PumpingLogPane extends StatefulWidget {
  const PumpingLogPane({super.key, required this.onBack, this.onChanged});

  final VoidCallback onBack;
  final VoidCallback? onChanged;

  @override
  State<PumpingLogPane> createState() => _PumpingLogPaneState();
}

class _PumpingLogPaneState extends State<PumpingLogPane> {
  final _total = TextEditingController();
  final _left = TextEditingController();
  final _right = TextEditingController();
  final _notes = TextEditingController();
  DateTime _startedAt = DateTime.now();
  String _side = 'both';
  bool _split = false;
  bool _saving = false;
  String? _error;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _left.addListener(_onSplitChanged);
    _right.addListener(_onSplitChanged);
    _reload();
    NumuwAppState.instance.refreshPumpingComparison(force: true);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final child = ChildSession.instance.selectedChild;
      if (mounted &&
          child != null &&
          LogTimerState.instance.pendingPumpingStart(child.id) != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _left.removeListener(_onSplitChanged);
    _right.removeListener(_onSplitChanged);
    _total.dispose();
    _left.dispose();
    _right.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _reload() {
    NumuwAppState.instance.refreshPumpingComparison(force: true);
  }

  void _onSplitChanged() {
    if (!_split) return;
    final total = (_amount(_left.text) ?? 0) + (_amount(_right.text) ?? 0);
    final text = total <= 0 ? '' : total.round().toString();
    if (_total.text != text) _total.text = text;
    if (mounted) setState(() {});
  }

  Future<void> _toggleTimer() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final active = LogTimerState.instance.pendingPumpingStart(child.id);
    if (active == null) {
      await LogTimerState.instance.startPumping(child.id, _startedAt);
    } else {
      setState(() => _startedAt = active);
    }
  }

  Future<void> _pickStartedAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startedAt.isAfter(now) ? now : _startedAt,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(minutes: 5)),
      locale: const Locale('ar'),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startedAt),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (time == null) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (selected.isAfter(now.add(const Duration(minutes: 5)))) {
      setState(() => _error = 'لا يمكن تسجيل وقت مستقبلي.');
      return;
    }
    setState(() {
      _startedAt = selected;
      _error = null;
    });
  }

  Future<void> _save() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _saving) return;
    final validation = _validate();
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    final timerStart = LogTimerState.instance.pendingPumpingStart(child.id);
    final startedAt = timerStart ?? _startedAt;
    final endedAt = timerStart == null ? null : DateTime.now();
    final left = _amount(_left.text);
    final right = _amount(_right.text);
    final total = _effectiveTotal();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await NumuwAppState.instance.saveCareEvent(
        eventType: 'pumping',
        startedAt: startedAt,
        endedAt: endedAt,
        side: _side,
        amountMl: total,
        notes: _notes.text,
        metadata: {
          'quantity_mode': _split ? 'split' : 'total',
          if (_split && left != null) 'left_amount_ml': left,
          if (_split && right != null) 'right_amount_ml': right,
        },
      );
      await LogTimerState.instance.finishPumping(child.id);
      _clear();
      widget.onChanged?.call();
      setState(_reload);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ جلسة الشفط')));
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) {
        setState(() => _error = 'تعذر حفظ جلسة الشفط. حاولي مرة أخرى.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validate() {
    final total = _effectiveTotal();
    if (total == null || total <= 0) return 'اكتبي كمية شفط أكبر من صفر.';
    if (total > 1500) return 'راجعي الكمية، الحد الأقصى للتسجيل 1500 مل.';
    if (_split) {
      final left = _amount(_left.text);
      final right = _amount(_right.text);
      if (_side == 'left' && (left == null || left <= 0)) {
        return 'اكتبي كمية اليسار.';
      }
      if (_side == 'right' && (right == null || right <= 0)) {
        return 'اكتبي كمية اليمين.';
      }
      if (_side == 'both' &&
          ((left == null || left <= 0) || (right == null || right <= 0))) {
        return 'اكتبي كمية اليسار واليمين أو استخدمي إجمالي الكمية فقط.';
      }
    }
    return null;
  }

  double? _effectiveTotal() {
    if (!_split) return _amount(_total.text);
    final left = _amount(_left.text) ?? 0;
    final right = _amount(_right.text) ?? 0;
    final total = left + right;
    return total > 0 ? total : _amount(_total.text);
  }

  void _clear() {
    _total.clear();
    _left.clear();
    _right.clear();
    _notes.clear();
    _startedAt = DateTime.now();
    _side = 'both';
    _split = false;
    _error = null;
  }

  void _setTotal(double value) {
    _split = false;
    _total.text = value <= 0 ? '' : value.round().toString();
    setState(() {});
  }

  void _adjust(double delta) {
    final current = _effectiveTotal() ?? 0;
    _setTotal((current + delta).clamp(0, 1500));
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    final timerStart = child == null
        ? null
        : LogTimerState.instance.pendingPumpingStart(child.id);
    final duration = timerStart == null
        ? Duration.zero
        : DateTime.now().difference(timerStart);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        TimerCard(
          time: _timerText(duration),
          status: timerStart == null ? 'جاهزة للبدء' : 'جارية الآن',
          color: AppColors.mintDark,
          active: timerStart != null,
          buttonLabel: timerStart == null
              ? 'بدء مؤقت الشفط'
              : 'استخدام وقت المؤقت',
          onPressed: _saving ? null : _toggleTimer,
        ),
        const SizedBox(height: 12),
        _timeCard(),
        const SizedBox(height: 12),
        _sideCard(),
        const SizedBox(height: 12),
        _quantityCard(),
        const SizedBox(height: 12),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'حفظ جلسة الشفط',
          color: AppColors.mintDark,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          ErrorMessageCard(message: _error!),
        ],
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: NumuwAppState.instance,
          builder: (context, _) => PumpingSummaryCard(
            comparison: NumuwAppState.instance.pumpingComparison,
            loading: NumuwAppState.instance.pumpingLoading,
            error: NumuwAppState.instance.pumpingError,
            onOpenFull: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PumpingAnalyticsScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 16),
    child: Row(
      children: [
        AppIconButton(
          icon: Icons.arrow_forward_rounded,
          onPressed: widget.onBack,
          badge: false,
          size: 42,
          radius: 13,
          iconSize: 20,
          borderWidth: 1.5,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'شفط',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _timeCard() => SoftCard(
    onTap: _pickStartedAt,
    child: Row(
      children: [
        const Icon(Icons.schedule_rounded, color: AppColors.mintDark),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${ArabicFormatters.date(_startedAt)} · ${ArabicFormatters.time(_startedAt)}',
            textAlign: TextAlign.start,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Icon(Icons.edit_calendar_outlined, color: numuwSecondaryTextColor()),
      ],
    ),
  );

  Widget _sideCard() => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الجهة', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Row(
          children: [
            _sidePill('left', 'اليسار'),
            const SizedBox(width: 8),
            _sidePill('right', 'اليمين'),
            const SizedBox(width: 8),
            _sidePill('both', 'الجانبان'),
          ],
        ),
      ],
    ),
  );

  Widget _sidePill(String value, String label) => Expanded(
    child: ChoicePill(
      label: label,
      selected: _side == value,
      onTap: () => setState(() => _side = value),
    ),
  );

  Widget _quantityCard() => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('كمية الشفط', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        NumuwTextField(
          controller: _total,
          label: 'إجمالي الكمية',
          hint: '75',
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniAmount(label: '-10', onTap: () => _adjust(-10)),
            _MiniAmount(label: '-5', onTap: () => _adjust(-5)),
            _MiniAmount(label: '+5', onTap: () => _adjust(5)),
            _MiniAmount(label: '+10', onTap: () => _adjust(10)),
            _MiniAmount(label: '30 مل', onTap: () => _setTotal(30)),
            _MiniAmount(label: '60 مل', onTap: () => _setTotal(60)),
            _MiniAmount(label: '90 مل', onTap: () => _setTotal(90)),
            _MiniAmount(label: '120 مل', onTap: () => _setTotal(120)),
          ],
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('تقسيم الكمية بين الجانبين'),
          value: _split,
          onChanged: (value) => setState(() {
            _split = value;
            if (value) _onSplitChanged();
          }),
        ),
        if (_split) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: NumuwTextField(
                  controller: _left,
                  label: 'كمية اليسار',
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NumuwTextField(
                  controller: _right,
                  label: 'كمية اليمين',
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الإجمالي: ${(_effectiveTotal() ?? 0).round()} مل',
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: AppColors.mintDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    ),
  );

  String _timerText(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class PumpingSummaryCard extends StatelessWidget {
  const PumpingSummaryCard({
    super.key,
    required this.comparison,
    required this.loading,
    required this.error,
    this.onOpenFull,
  });

  final PumpingComparison? comparison;
  final bool loading;
  final Object? error;
  final VoidCallback? onOpenFull;

  @override
  Widget build(BuildContext context) {
    final data = comparison;
    if (data == null && loading) return const LoadingSkeleton(height: 150);
    if (data == null && error != null) {
      return const ErrorMessageCard(
        message: 'تعذر تحميل بيانات الشفط. حاولي مرة أخرى.',
      );
    }
    if (data == null || data.currentPeriod.sessionCount == 0) {
      return const EmptyState(
        message:
            'لم يتم تسجيل جلسات شفط بعد\nسجّلي أول جلسة لتظهر لكِ المقارنة الأسبوعية',
      );
    }
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ملخص الشفط — آخر 7 أيام',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _StatsRow(data: data),
          const SizedBox(height: 12),
          _PumpingBars(stats: data.currentPeriod),
          const SizedBox(height: 10),
          Text(
            _trendText(data),
            textAlign: TextAlign.start,
            style: TextStyle(
              color: _trendColor(data.trend),
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هذه مقارنة للسجلات وليست تقييمًا طبيًا لإدرار الحليب.',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: numuwSecondaryTextColor(),
              fontSize: 11,
              height: 1.45,
            ),
          ),
          if (onOpenFull != null) ...[
            const SizedBox(height: 10),
            SecondaryButton(label: 'عرض التحليل الكامل', onPressed: onOpenFull),
          ],
        ],
      ),
    );
  }
}

class PumpingAnalyticsScreen extends StatefulWidget {
  const PumpingAnalyticsScreen({super.key});

  @override
  State<PumpingAnalyticsScreen> createState() => _PumpingAnalyticsScreenState();
}

class _PumpingAnalyticsScreenState extends State<PumpingAnalyticsScreen> {
  final _repo = CareEventRepository();
  Future<List<CareEvent>>? _sessions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    _sessions = _repo.fetchPumpingForComparison(child.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwHeader(
            title: 'تحليل الشفط',
            subtitle: 'آخر 7 أيام مقارنة بالـ7 أيام السابقة',
            leading: AppIconButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.pop(context),
              badge: false,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: NumuwAppState.instance,
            builder: (context, _) => PumpingSummaryCard(
              comparison: NumuwAppState.instance.pumpingComparison,
              loading: NumuwAppState.instance.pumpingLoading,
              error: NumuwAppState.instance.pumpingError,
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<CareEvent>>(
            future: _sessions,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingSkeleton(height: 120);
              }
              final events = snapshot.data ?? const <CareEvent>[];
              if (events.isEmpty) {
                return const EmptyState(
                  message: 'لا توجد جلسات في هذه الفترة.',
                );
              }
              return SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < events.length; i++) ...[
                      ActivityListItem(
                        icon: '🍼',
                        background: AppColors.mintLight,
                        title: 'شفط',
                        subtitle: pumpingSubtitle(events[i]),
                      ),
                      if (i != events.length - 1)
                        Divider(height: 1, color: numuwBorderColor()),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final PumpingComparison data;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Stat(
        label: 'إجمالي الكمية',
        value: '${data.currentPeriod.totalMl.round()} مل',
      ),
      const SizedBox(width: 8),
      _Stat(label: 'عدد الجلسات', value: '${data.currentPeriod.sessionCount}'),
      const SizedBox(width: 8),
      _Stat(
        label: 'متوسط الجلسة',
        value: '${data.currentPeriod.averagePerSessionMl.round()} مل',
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsetsDirectional.all(10),
      decoration: BoxDecoration(
        color: numuwNightMode()
            ? AppColors.nightSurfaceSoft
            : AppColors.mintLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    ),
  );
}

class _PumpingBars extends StatelessWidget {
  const _PumpingBars({required this.stats});

  final PumpingPeriodStats stats;

  @override
  Widget build(BuildContext context) {
    final entries = stats.dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final max = entries.fold<double>(
      0,
      (value, entry) => entry.value > value ? entry.value : value,
    );
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((entry) {
          final today = _isSameDay(entry.key, DateTime.now());
          final height = max <= 0 ? 6.0 : 8 + (entry.value / max) * 62;
          return Expanded(
            child: Semantics(
              label: '${_dayLabel(entry.key)} ${entry.value.round()} مل',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: NumuwMotion.fast,
                    height: height,
                    width: 18,
                    decoration: BoxDecoration(
                      color: today ? AppColors.mintDark : AppColors.mint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dayLabel(entry.key),
                    style: TextStyle(
                      color: today
                          ? AppColors.mintDark
                          : numuwSecondaryTextColor(),
                      fontSize: 10,
                      fontWeight: today ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MiniAmount extends StatelessWidget {
  const _MiniAmount({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(label),
    onPressed: onTap,
    backgroundColor: AppColors.mintLight,
    labelStyle: const TextStyle(
      color: AppColors.mintDark,
      fontWeight: FontWeight.w800,
    ),
  );
}

String pumpingSubtitle(CareEvent event) {
  final amount = event.pumpedAmountMl?.round();
  final parts = <String>[
    if (amount != null) 'شفط $amount مل' else 'شفط',
    _sideLabel(event.side),
    if (event.duration != null) ArabicFormatters.duration(event.duration!),
  ];
  return parts.where((part) => part.trim().isNotEmpty).join(' · ');
}

String pumpingDetailsText(CareEvent event) {
  final parts = <String>[pumpingSubtitle(event)];
  if (event.leftPumpedAmountMl != null) {
    parts.add('اليسار ${event.leftPumpedAmountMl!.round()} مل');
  }
  if (event.rightPumpedAmountMl != null) {
    parts.add('اليمين ${event.rightPumpedAmountMl!.round()} مل');
  }
  return parts.join(' · ');
}

String _sideLabel(String? side) => switch (side) {
  'left' => 'اليسار',
  'right' => 'اليمين',
  'both' => 'الجانبان',
  _ => '',
};

String _trendText(PumpingComparison data) {
  if (data.previousPeriod.totalMl == 0 && data.currentPeriod.totalMl > 0) {
    return 'بدأتِ تسجيل جلسات الشفط خلال آخر 7 أيام';
  }
  if (data.trend == PumpingTrend.insufficientData) {
    return 'سجّلي جلسات أكثر للحصول على مقارنة أدق';
  }
  if (data.trend == PumpingTrend.stable) {
    return 'الكمية المسجلة قريبة من الفترة السابقة';
  }
  final pct = data.percentageChange?.abs().round() ?? 0;
  if (data.trend == PumpingTrend.increased) {
    return 'زادت الكمية المسجلة بنسبة $pct٪ مقارنة بالـ7 أيام السابقة';
  }
  return 'انخفضت الكمية المسجلة بنسبة $pct٪ مقارنة بالـ7 أيام السابقة';
}

Color _trendColor(PumpingTrend trend) => switch (trend) {
  PumpingTrend.increased => AppColors.mintDark,
  PumpingTrend.decreased => AppColors.yellow,
  PumpingTrend.stable => AppColors.blue,
  PumpingTrend.insufficientData => AppColors.mutedText,
};

String _dayLabel(DateTime date) {
  const labels = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
  return labels[date.weekday - 1];
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

double? _amount(String value) {
  final normalized = value
      .trim()
      .replaceAll('٫', '.')
      .replaceAll(',', '.')
      .replaceAll('٠', '0')
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9');
  return double.tryParse(normalized);
}
