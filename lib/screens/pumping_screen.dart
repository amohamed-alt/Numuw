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
import '../widgets/icons/numuw_icon.dart';
import '../widgets/numuw_classy_components.dart';
import '../widgets/numuw_motion_widgets.dart';

/// Production pumping experience. Keeps the existing timer/save/analytics
/// contracts while using the Numuw vector system end-to-end.
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
    _left.addListener(_syncSplit);
    _right.addListener(_syncSplit);
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
    _left.removeListener(_syncSplit);
    _right.removeListener(_syncSplit);
    _total.dispose();
    _left.dispose();
    _right.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _text => _dark ? AppColors.nightText : AppColors.text;
  Color get _secondary =>
      _dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
  Color get _accent =>
      _dark ? AppColors.nightPrimaryStrong : AppColors.plum;
  Color get _border => _dark ? AppColors.nightBorder : AppColors.border;

  void _syncSplit() {
    if (!_split) return;
    final total = (_amount(_left.text) ?? 0) + (_amount(_right.text) ?? 0);
    final value = total <= 0 ? '' : total.round().toString();
    if (_total.text != value) _total.text = value;
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
    if (mounted) setState(() {});
  }

  Future<void> _pickStartedAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startedAt.isAfter(now) ? now : _startedAt,
      firstDate: DateTime(2020),
      lastDate: now,
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
        startedAt: timerStart ?? _startedAt,
        endedAt: timerStart == null ? null : DateTime.now(),
        side: _side,
        amountMl: total,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        metadata: {
          'quantity_mode': _split ? 'split' : 'total',
          if (_split && left != null) 'left_amount_ml': left,
          if (_split && right != null) 'right_amount_ml': right,
        },
      );
      await LogTimerState.instance.finishPumping(child.id);
      _clear();
      widget.onChanged?.call();
      await NumuwAppState.instance.refreshPumpingComparison(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ جلسة الشفط')),
      );
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
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
    _setTotal((current + delta).clamp(0, 1500).toDouble());
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        const SizedBox(height: 18),
        _timerCard(timerStart != null, duration),
        const SizedBox(height: 12),
        _timeCard(),
        const SizedBox(height: 12),
        _sideCard(),
        const SizedBox(height: 12),
        _quantityCard(),
        const SizedBox(height: 12),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        const SizedBox(height: 16),
        NumuwClassyButton(
          label: 'حفظ جلسة الشفط',
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          _ErrorCard(message: _error!),
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

  Widget _header() => SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: NumuwPressable(
                onTap: widget.onBack,
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: NumuwIcon(
                      NumuwIcons.back,
                      size: 20,
                      color: _text,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              'جلسة شفط',
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: NumuwIcon(
                NumuwIcons.pumping,
                size: 22,
                color: _accent,
              ),
            ),
          ],
        ),
      );

  Widget _timerCard(bool active, Duration duration) => NumuwClassySurface(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 24, 18, 18),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: .09),
              ),
              child: NumuwIcon(
                active ? NumuwIcons.timer : NumuwIcons.pumping,
                size: 34,
                color: _accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              active ? 'الجلسة جارية الآن' : 'جاهزة لبدء الجلسة',
              style: TextStyle(
                color: _secondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                _timerText(duration),
                style: TextStyle(
                  color: _text,
                  fontSize: 36,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 15),
            NumuwClassyButton(
              label: active ? 'استخدام وقت المؤقت' : 'بدء مؤقت الشفط',
              size: NumuwButtonSize.medium,
              variant: active
                  ? NumuwButtonVariant.tonal
                  : NumuwButtonVariant.primary,
              onPressed: _saving ? null : _toggleTimer,
            ),
          ],
        ),
      );

  Widget _timeCard() => NumuwClassySurface(
        onTap: _pickStartedAt,
        padding: const EdgeInsetsDirectional.all(14),
        child: Row(
          children: [
            NumuwIcon(NumuwIcons.calendar, size: 21, color: _accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وقت البدء',
                    style: TextStyle(
                      color: _text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ArabicFormatters.date(_startedAt)} · ${ArabicFormatters.time(_startedAt)}',
                    style: TextStyle(color: _secondary, fontSize: 11.2),
                  ),
                ],
              ),
            ),
            NumuwIcon(NumuwIcons.edit, size: 18, color: _secondary),
          ],
        ),
      );

  Widget _sideCard() => NumuwClassySurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الجهة',
              style: TextStyle(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SideChoice(
                    asset: NumuwIcons.pumpingLeft,
                    label: 'اليسار',
                    selected: _side == 'left',
                    onTap: () => setState(() => _side = 'left'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SideChoice(
                    asset: NumuwIcons.pumping,
                    label: 'الجانبان',
                    selected: _side == 'both',
                    onTap: () => setState(() => _side = 'both'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SideChoice(
                    asset: NumuwIcons.pumpingRight,
                    label: 'اليمين',
                    selected: _side == 'right',
                    onTap: () => setState(() => _side = 'right'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _quantityCard() => NumuwClassySurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                NumuwIcon(NumuwIcons.bottle, size: 20, color: _accent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'كمية الشفط',
                    style: TextStyle(
                      color: _text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _MiniSwitch(
                  value: _split,
                  onChanged: (value) => setState(() {
                    _split = value;
                    if (value) _syncSplit();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _split ? 'تسجيل كل جهة منفصلة' : 'إجمالي الكمية فقط',
              style: TextStyle(color: _secondary, fontSize: 10.5),
            ),
            const SizedBox(height: 12),
            NumuwNumberField(
              controller: _total,
              label: 'إجمالي الكمية (مل)',
              hint: '75',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _AmountChip(label: '-10', onTap: () => _adjust(-10)),
                _AmountChip(label: '+10', onTap: () => _adjust(10)),
                _AmountChip(label: '30 مل', onTap: () => _setTotal(30)),
                _AmountChip(label: '60 مل', onTap: () => _setTotal(60)),
                _AmountChip(label: '90 مل', onTap: () => _setTotal(90)),
                _AmountChip(label: '120 مل', onTap: () => _setTotal(120)),
              ],
            ),
            if (_split) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NumuwNumberField(
                      controller: _left,
                      label: 'اليسار (مل)',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NumuwNumberField(
                      controller: _right,
                      label: 'اليمين (مل)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'الإجمالي ${(_effectiveTotal() ?? 0).round()} مل',
                style: TextStyle(
                  color: _accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      );
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final data = comparison;

    if (data == null && loading) {
      return NumuwClassySurface(
        child: SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          ),
        ),
      );
    }
    if (data == null && error != null) {
      return const _ErrorCard(
        message: 'تعذر تحميل بيانات الشفط. حاولي مرة أخرى.',
      );
    }
    if (data == null || data.currentPeriod.sessionCount == 0) {
      return NumuwClassySurface(
        child: Row(
          children: [
            NumuwIcon(NumuwIcons.pumping, size: 26, color: secondary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'سجّلي أول جلسة لتظهر المقارنة الأسبوعية هنا.',
                style: TextStyle(
                  color: secondary,
                  fontSize: 11.2,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return NumuwClassySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              NumuwIcon(NumuwIcons.chart, size: 21, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ملخص الشفط — آخر 7 أيام',
                  style: TextStyle(
                    color: text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'الإجمالي',
                  value: '${data.currentPeriod.totalMl.round()} مل',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _Stat(
                  label: 'الجلسات',
                  value: '${data.currentPeriod.sessionCount}',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _Stat(
                  label: 'المتوسط',
                  value:
                      '${data.currentPeriod.averagePerSessionMl.round()} مل',
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _PumpingBars(stats: data.currentPeriod),
          const SizedBox(height: 10),
          Text(
            _trendText(data),
            style: TextStyle(
              color: _trendColor(data.trend),
              fontSize: 10.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'هذه مقارنة للسجلات وليست تقييمًا طبيًا لإدرار الحليب.',
            style: TextStyle(
              color: secondary,
              fontSize: 9.8,
              height: 1.4,
            ),
          ),
          if (onOpenFull != null) ...[
            const SizedBox(height: 11),
            NumuwClassyButton(
              label: 'عرض التحليل الكامل',
              variant: NumuwButtonVariant.secondary,
              size: NumuwButtonSize.small,
              onPressed: onOpenFull,
            ),
          ],
        ],
      ),
    );
  }
}

class PumpingAnalyticsScreen extends StatefulWidget {
  const PumpingAnalyticsScreen({super.key});

  @override
  State<PumpingAnalyticsScreen> createState() =>
      _PumpingAnalyticsScreenState();
}

class _PumpingAnalyticsScreenState extends State<PumpingAnalyticsScreen> {
  final _repo = CareEventRepository();
  Future<List<CareEvent>>? _sessions;

  @override
  void initState() {
    super.initState();
    final child = ChildSession.instance.selectedChild;
    if (child != null) _sessions = _repo.fetchPumpingForComparison(child.id);
    NumuwAppState.instance.refreshPumpingComparison(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;

    return Scaffold(
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: NumuwPressable(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: NumuwIcon(
                            NumuwIcons.back,
                            size: 20,
                            color: text,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'تحليل الشفط',
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: NumuwIcon(
                      NumuwIcons.chart,
                      size: 21,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: NumuwAppState.instance,
              builder: (context, _) => PumpingSummaryCard(
                comparison: NumuwAppState.instance.pumpingComparison,
                loading: NumuwAppState.instance.pumpingLoading,
                error: NumuwAppState.instance.pumpingError,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'الجلسات المسجلة',
              style: TextStyle(
                color: text,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<CareEvent>>(
              future: _sessions,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return NumuwClassySurface(
                    child: SizedBox(
                      height: 90,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      ),
                    ),
                  );
                }
                final events = snapshot.data ?? const <CareEvent>[];
                if (events.isEmpty) {
                  return NumuwClassySurface(
                    child: Text(
                      'لا توجد جلسات في هذه الفترة.',
                      style: TextStyle(color: secondary, fontSize: 11),
                    ),
                  );
                }
                return NumuwClassySurface(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < events.length; i++) ...[
                        _SessionRow(event: events[i]),
                        if (i != events.length - 1)
                          Divider(height: 1, color: _borderFor(context)),
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
}

class _SideChoice extends StatelessWidget {
  const _SideChoice({
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsetsDirectional.fromSTEB(4, 10, 4, 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? accent : border,
            width: selected ? 1.6 : 1,
          ),
          color: selected ? accent.withValues(alpha: .07) : Colors.transparent,
        ),
        child: Column(
          children: [
            NumuwIcon(
              asset,
              size: 25,
              color: selected ? accent : text,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? accent : text,
                fontSize: 10.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return Semantics(
      toggled: value,
      button: true,
      child: NumuwPressable(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          width: 44,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: value ? accent : border,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 170),
            alignment: value
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: accent.withValues(alpha: .07),
          border: Border.all(color: accent.withValues(alpha: .16)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: text,
            fontSize: 10.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return Container(
      padding: const EdgeInsetsDirectional.all(9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
        color: dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: secondary, fontSize: 9)),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((entry) {
          final height = max <= 0 ? 5.0 : 7 + (entry.value / max) * 56;
          return Expanded(
            child: Semantics(
              label: '${_dayLabel(entry.key)} ${entry.value.round()} مل',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: height,
                    width: 14,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .78),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _dayLabel(entry.key),
                    style: TextStyle(color: secondary, fontSize: 8.5),
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

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.event});
  final CareEvent event;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(13, 11, 13, 11),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: .08),
            ),
            child: NumuwIcon(NumuwIcons.pumping, size: 19, color: accent),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pumpingSubtitle(event),
                  style: TextStyle(
                    color: text,
                    fontSize: 11.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ArabicFormatters.date(event.startedAt)} · ${ArabicFormatters.time(event.startedAt)}',
                  style: TextStyle(color: secondary, fontSize: 9.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwIcon(
            NumuwIcons.info,
            size: 18,
            color: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: text, fontSize: 10.6, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

double? _amount(String value) {
  final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
  return parsed != null && parsed > 0 ? parsed : null;
}

String _timerText(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);
  final s = duration.inSeconds.remainder(60);
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String pumpingSubtitle(CareEvent event) {
  final amount = event.pumpedAmountMl?.round();
  final parts = <String>[
    amount == null ? 'شفط' : 'شفط $amount مل',
    _sideLabel(event.side),
    if (event.duration != null) ArabicFormatters.duration(event.duration!),
  ];
  return parts.where((part) => part.isNotEmpty).join(' · ');
}

String _sideLabel(String? side) => switch (side) {
      'left' => 'يسار',
      'right' => 'يمين',
      'both' => 'الجانبان',
      _ => '',
    };

String _dayLabel(DateTime value) {
  const labels = <int, String>{
    DateTime.monday: 'اث',
    DateTime.tuesday: 'ثل',
    DateTime.wednesday: 'أر',
    DateTime.thursday: 'خم',
    DateTime.friday: 'جم',
    DateTime.saturday: 'سب',
    DateTime.sunday: 'أح',
  };
  return labels[value.weekday] ?? '';
}

String _trendText(PumpingComparison data) => switch (data.trend) {
      PumpingTrend.increased =>
        'الإجمالي أعلى بنحو ${data.percentageChange?.abs().round() ?? 0}% من الأسبوع السابق.',
      PumpingTrend.decreased =>
        'الإجمالي أقل بنحو ${data.percentageChange?.abs().round() ?? 0}% من الأسبوع السابق.',
      PumpingTrend.stable => 'الإجمالي قريب من مستوى الأسبوع السابق.',
      PumpingTrend.insufficientData => 'نحتاج جلسات أكثر قبل إظهار اتجاه موثوق.',
    };

Color _trendColor(PumpingTrend trend) => switch (trend) {
      PumpingTrend.increased => AppColors.success,
      PumpingTrend.decreased => AppColors.warning,
      PumpingTrend.stable => AppColors.info,
      PumpingTrend.insufficientData => AppColors.secondaryText,
    };

Color _borderFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColors.nightBorder
        : AppColors.border;
