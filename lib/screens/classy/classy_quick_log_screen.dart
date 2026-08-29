import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../core/formatters/arabic_formatters.dart';
import '../../models/care_event.dart';
import '../../repositories/care_event_repository.dart';
import '../../state/app_events.dart';
import '../../state/child_session.dart';
import '../../state/log_timer_state.dart';
import '../../state/numuw_app_state.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/classy/reference_feeding_pane.dart';
import '../../widgets/icons/numuw_icon.dart';
import '../../widgets/numuw_classy_components.dart';
import '../../widgets/numuw_motion_widgets.dart';
import '../pumping_screen.dart';

/// Production Quick Log migration. Real timers/repositories/state are preserved;
/// only the presentation has moved to the shared classy Numuw system.
class ClassyQuickLogScreen extends StatefulWidget {
  const ClassyQuickLogScreen({super.key});

  @override
  State<ClassyQuickLogScreen> createState() => _ClassyQuickLogScreenState();
}

class _ClassyQuickLogScreenState extends State<ClassyQuickLogScreen> {
  final _repo = CareEventRepository();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  final _food = TextEditingController();
  final _dose = TextEditingController();
  final _temperature = TextEditingController();

  String _mode = 'log';
  String _side = 'right';
  String _diaperType = 'wet';
  final Set<String> _feedingMethods = {'breast'};
  int _amountMl = 0;
  bool _burped = false;
  bool _vomited = false;
  bool _loading = false;
  String? _error;
  String? _success;
  DateTime _eventStartedAt = DateTime.now();
  Future<List<CareEvent>>? _recent;
  int _recentRequest = 0;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _reload();
    ChildSession.instance.addListener(_onExternalChanged);
    AppEvents.instance.addListener(_onExternalChanged);
    LogTimerState.instance.addListener(_onTimerChanged);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (LogTimerState.instance.feedingActive ||
          LogTimerState.instance.sleepActive) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    ChildSession.instance.removeListener(_onExternalChanged);
    AppEvents.instance.removeListener(_onExternalChanged);
    LogTimerState.instance.removeListener(_onTimerChanged);
    _amount.dispose();
    _notes.dispose();
    _food.dispose();
    _dose.dispose();
    _temperature.dispose();
    super.dispose();
  }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _text => _dark ? AppColors.nightText : AppColors.text;
  Color get _secondary =>
      _dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
  Color get _accent =>
      _dark ? AppColors.nightPrimaryStrong : AppColors.plum;
  Color get _border => _dark ? AppColors.nightBorder : AppColors.border;
  Color get _raised =>
      _dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised;

  void _onExternalChanged() {
    if (!mounted) return;
    setState(_reload);
  }

  void _onTimerChanged() {
    if (mounted) setState(() {});
  }

  void _reload() {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      _recent = Future.value(const <CareEvent>[]);
      return;
    }
    final request = ++_recentRequest;
    _recent = _repo.fetchRecent(child.id, limit: 12).then((events) {
      if (request != _recentRequest ||
          ChildSession.instance.selectedChild?.id != child.id) {
        return const <CareEvent>[];
      }
      return events;
    });
  }

  void _open(String mode) => setState(() {
        _mode = mode;
        _error = null;
        _success = null;
        _eventStartedAt = DateTime.now();
      });

  void _back() => setState(() {
        _mode = 'log';
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      return const Scaffold(
        body: AppPage(
          child: EmptyState(message: 'اختاري طفلًا أولًا للتسجيل.'),
        ),
      );
    }

    final content = switch (_mode) {
      'feeding' => _feedingPane(child.id),
      'pumping' => PumpingLogPane(onBack: _back, onChanged: _reload),
      'sleep' => _sleepPane(child.id),
      'diaper' => _diaperPane(),
      'food' => _genericPane('food'),
      'medicine' => _genericPane('medicine'),
      'temperature' => _temperaturePane(),
      'note' => _genericPane('note'),
      _ => _landing(child.name),
    };

    return Scaffold(
      body: Stack(
        children: [
          AppPage(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 28),
            child: content,
          ),
          if (_success != null) SuccessToast(message: _success!),
        ],
      ),
    );
  }

  Widget _landing(String childName) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            title: 'تسجيل سريع',
            subtitle: 'كل تفاصيل يوم $childName في ثواني وبيد واحدة',
            asset: NumuwIcons.quickLog,
          ),
          const SizedBox(height: 18),
          NumuwClassySurface(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 16, 12, 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 350 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 8,
                  childAspectRatio: .77,
                  children: [
                    _QuickAction(label: 'رضاعة', asset: NumuwIcons.feeding, onTap: () => _open('feeding')),
                    _QuickAction(label: 'شفط', asset: NumuwIcons.pumping, onTap: () => _open('pumping')),
                    _QuickAction(label: 'نوم', asset: NumuwIcons.sleep, onTap: () => _open('sleep')),
                    _QuickAction(label: 'حفاضة', asset: NumuwIcons.diaper, onTap: () => _open('diaper')),
                    _QuickAction(label: 'طعام', asset: NumuwIcons.food, onTap: () => _open('food')),
                    _QuickAction(label: 'دواء', asset: NumuwIcons.medicine, onTap: () => _open('medicine')),
                    _QuickAction(label: 'حرارة', asset: NumuwIcons.temperature, onTap: () => _open('temperature')),
                    _QuickAction(label: 'ملاحظة', asset: NumuwIcons.note, onTap: () => _open('note')),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              NumuwIcon(NumuwIcons.history, size: 20, color: _accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text('آخر التسجيلات', style: TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _recentList(),
        ],
      );

  Widget _feedingPane(String childId) {
    final start = LogTimerState.instance.feedingStartForChild(childId);
    final active = start != null;
    return NumuwReferenceFeedingPane(
      active: active,
      timerText: _timerText(_durationSince(start)),
      side: _side,
      feedingMethods: _feedingMethods,
      amountController: _amount,
      notesController: _notes,
      amountMl: _amountMl,
      burped: _burped,
      vomited: _vomited,
      loading: _loading,
      onBack: _back,
      onTimerPressed: _feedingToggle,
      onSideChanged: (value) => setState(() => _side = value),
      onPrimaryMethodChanged: (value) => setState(() {
        _feedingMethods
          ..clear()
          ..add(value);
      }),
      onMethodToggled: (value) => setState(() {
        if (_feedingMethods.contains(value)) {
          if (_feedingMethods.length > 1) _feedingMethods.remove(value);
        } else {
          _feedingMethods.add(value);
        }
      }),
      onAmountChanged: (value) => setState(() {
        _amountMl = (int.tryParse(value.trim()) ?? 0).clamp(0, 990).toInt();
      }),
      onAmountDelta: (delta) => setState(() {
        _amountMl = (_amountMl + delta).clamp(0, 990).toInt();
        _amount.text = _amountMl == 0 ? '' : _amountMl.toString();
      }),
      onBurpedChanged: (value) => setState(() => _burped = value),
      onVomitedChanged: (value) => setState(() => _vomited = value),
    );
  }

  Widget _sleepPane(String childId) {
    final start = LogTimerState.instance.sleepStartForChild(childId);
    final active = start != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BackHeader(title: 'تسجيل النوم', asset: NumuwIcons.sleep, onBack: _back),
        const SizedBox(height: 20),
        NumuwClassySurface(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 20),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _accent.withValues(alpha: .10)),
                child: NumuwIcon(active ? NumuwIcons.sleep : NumuwIcons.moon, size: 38, color: _accent),
              ),
              const SizedBox(height: 14),
              Text(active ? 'نائم الآن' : 'جاهز لبدء النوم', style: TextStyle(color: _secondary, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(_timerText(_durationSince(start)), style: TextStyle(color: _text, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
              ),
              const SizedBox(height: 18),
              NumuwClassyButton(
                label: active ? 'استيقظ — حفظ النوم' : 'بدء النوم',
                variant: active ? NumuwButtonVariant.danger : NumuwButtonVariant.primary,
                onPressed: _loading ? null : _sleepToggle,
                loading: _loading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        _errorWidget(),
      ],
    );
  }

  Widget _diaperPane() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackHeader(title: 'تسجيل حفاضة', asset: NumuwIcons.diaper, onBack: _back),
          const SizedBox(height: 16),
          _eventTimeCard(),
          const SizedBox(height: 14),
          _SelectionRow(
            selected: _diaperType == 'wet',
            asset: NumuwIcons.diaperWet,
            title: 'مبللة',
            subtitle: 'بول فقط',
            onTap: () => setState(() => _diaperType = 'wet'),
          ),
          const SizedBox(height: 10),
          _SelectionRow(
            selected: _diaperType == 'dirty',
            asset: NumuwIcons.diaperDirty,
            title: 'متسخة',
            subtitle: 'براز فقط',
            onTap: () => setState(() => _diaperType = 'dirty'),
          ),
          const SizedBox(height: 10),
          _SelectionRow(
            selected: _diaperType == 'both',
            asset: NumuwIcons.diaper,
            title: 'مبللة ومتسخة',
            subtitle: 'بول وبراز',
            onTap: () => setState(() => _diaperType = 'both'),
          ),
          const SizedBox(height: 14),
          NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
          const SizedBox(height: 16),
          NumuwClassyButton(label: 'حفظ الحفاضة', loading: _loading, onPressed: _loading ? null : () => _saveEvent('diaper')),
          _errorWidget(),
        ],
      );

  Widget _genericPane(String type) {
    final spec = _spec(type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BackHeader(title: spec.title, asset: spec.asset, onBack: _back),
        const SizedBox(height: 16),
        _eventTimeCard(),
        const SizedBox(height: 14),
        if (type == 'food') ...[
          NumuwTextField(controller: _food, label: 'اسم الطعام'),
          const SizedBox(height: 12),
          NumuwTextField(controller: _dose, label: 'الكمية أو الوصف'),
          const SizedBox(height: 12),
          NumuwTextArea(controller: _notes, label: 'ملاحظات التفاعل'),
        ] else if (type == 'medicine') ...[
          NumuwTextField(controller: _food, label: 'اسم الدواء'),
          const SizedBox(height: 12),
          NumuwTextField(controller: _dose, label: 'الجرعة حسب وصف الطبيب'),
          const SizedBox(height: 12),
          _SafetyCard(
            asset: NumuwIcons.prescription,
            message: 'نُمُوّ ينظم الجرعة المسجلة فقط ولا يصف دواءً أو يغيّر جرعة الطبيب.',
          ),
          const SizedBox(height: 12),
          NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        ] else ...[
          NumuwTextArea(controller: _notes, label: 'الملاحظة'),
        ],
        const SizedBox(height: 16),
        NumuwClassyButton(label: spec.button, loading: _loading, onPressed: _loading ? null : () => _saveEvent(type)),
        _errorWidget(),
      ],
    );
  }

  Widget _temperaturePane() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackHeader(title: 'تسجيل الحرارة', asset: NumuwIcons.temperature, onBack: _back),
          const SizedBox(height: 16),
          _eventTimeCard(),
          const SizedBox(height: 14),
          NumuwClassySurface(
            child: Column(
              children: [
                NumuwIcon(NumuwIcons.temperature, size: 34, color: AppColors.danger),
                const SizedBox(height: 10),
                NumuwNumberField(controller: _temperature, label: 'درجة الحرارة', hint: '37.2'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SafetyCard(
            asset: NumuwIcons.emergency,
            message: 'هذا تسجيل للقراءة وليس تشخيصًا. عند القلق أو علامات الخطر تواصلي مع الطبيب أو الطوارئ.',
          ),
          const SizedBox(height: 12),
          NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
          const SizedBox(height: 16),
          NumuwClassyButton(label: 'حفظ القراءة', loading: _loading, onPressed: _loading ? null : () => _saveEvent('temperature')),
          _errorWidget(),
        ],
      );

  Widget _eventTimeCard() => NumuwClassySurface(
        onTap: _pickEventDateTime,
        padding: const EdgeInsetsDirectional.all(14),
        child: Row(
          children: [
            NumuwIcon(NumuwIcons.calendar, size: 21, color: _accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('وقت التسجيل', style: TextStyle(color: _text, fontSize: 12.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('${ArabicFormatters.date(_eventStartedAt)} · ${ArabicFormatters.time(_eventStartedAt)}', style: TextStyle(color: _secondary, fontSize: 11.5)),
                ],
              ),
            ),
            NumuwIcon(NumuwIcons.edit, size: 18, color: _secondary),
          ],
        ),
      );

  Widget _recentList() => FutureBuilder<List<CareEvent>>(
        future: _recent,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return NumuwClassySurface(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
            );
          }
          if (snapshot.hasError) {
            return _SafetyCard(asset: NumuwIcons.info, message: readableError(snapshot.error!));
          }
          final events = snapshot.data ?? const <CareEvent>[];
          if (events.isEmpty) {
            return NumuwClassySurface(
              child: Row(
                children: [
                  NumuwIcon(NumuwIcons.logoMark, size: 28, color: _secondary),
                  const SizedBox(width: 10),
                  Expanded(child: Text('أول تسجيل هيظهر هنا تلقائيًا.', style: TextStyle(color: _secondary, fontWeight: FontWeight.w600))),
                ],
              ),
            );
          }
          return NumuwClassySurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < events.take(6).length; i++) ...[
                  _RecentEventRow(event: events[i]),
                  if (i != events.take(6).length - 1) Divider(height: 1, color: _border),
                ],
              ],
            ),
          );
        },
      );

  Future<void> _feedingToggle() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _loading) return;
    final start = LogTimerState.instance.pendingFeedingStart(child.id);
    if (start == null) {
      await LogTimerState.instance.startFeeding(child.id);
      if (mounted) setState(() {});
      return;
    }
    await _saveEvent('feeding', startedAt: start, endedAt: DateTime.now());
  }

  Future<void> _sleepToggle() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _loading) return;
    final start = LogTimerState.instance.pendingSleepStart(child.id);
    if (start == null) {
      await LogTimerState.instance.startSleep(child.id);
      if (mounted) setState(() {});
      return;
    }
    await _saveEvent('sleep', startedAt: start, endedAt: DateTime.now());
  }

  Future<void> _saveEvent(String type, {DateTime? startedAt, DateTime? endedAt}) async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _loading) return;
    final validation = _validate(type);
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await NumuwAppState.instance.saveCareEvent(
        eventType: type,
        startedAt: startedAt ?? _eventStartedAt,
        endedAt: endedAt,
        side: type == 'feeding' ? _side : null,
        feedingMethod: type == 'feeding' ? _feedingMethods.first : null,
        amountMl: type == 'feeding' && _amountMl > 0 ? _amountMl.toDouble() : null,
        burped: type == 'feeding' ? _burped : null,
        vomited: type == 'feeding' ? _vomited : null,
        diaperWet: type == 'diaper' ? _diaperType != 'dirty' : null,
        diaperDirty: type == 'diaper' ? _diaperType != 'wet' : null,
        temperatureC: type == 'temperature' ? _parseDouble(_temperature.text) : null,
        medicineName: type == 'medicine' ? _food.text.trim() : null,
        medicineDose: type == 'medicine' ? _dose.text.trim() : null,
        notes: _notesFor(type),
        metadata: _metadataFor(type),
      );
      if (type == 'feeding') await LogTimerState.instance.finishFeeding(child.id);
      if (type == 'sleep') await LogTimerState.instance.finishSleep(child.id);
      _clear(type);
      if (!mounted) return;
      setState(() {
        _success = 'تم حفظ التسجيل';
        _reload();
        if (type != 'feeding' && type != 'sleep') _mode = 'log';
      });
      Future<void>.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) setState(() => _success = null);
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validate(String type) {
    if (type == 'feeding' && _feedingMethods.isEmpty) return 'اختاري طريقة رضاعة.';
    if (type == 'food' && _food.text.trim().isEmpty) return 'اكتبي اسم الطعام.';
    if (type == 'medicine' && _food.text.trim().isEmpty) return 'اكتبي اسم الدواء.';
    if (type == 'note' && _notes.text.trim().isEmpty) return 'اكتبي الملاحظة أولًا.';
    if (type == 'temperature') {
      final value = _parseDouble(_temperature.text);
      if (value == null || value < 30 || value > 45) {
        return 'اكتبي درجة حرارة صحيحة بين 30 و45.';
      }
    }
    return null;
  }

  String? _notesFor(String type) {
    final note = _notes.text.trim();
    if (type == 'food') {
      final food = _food.text.trim();
      return note.isEmpty ? food : '$food - $note';
    }
    return note.isEmpty ? null : note;
  }

  Map<String, dynamic> _metadataFor(String type) {
    if (type == 'feeding') {
      return {'feeding_methods': _feedingMethods.toList(growable: false)};
    }
    if (type == 'food') {
      return {'food_name': _food.text.trim(), 'description': _dose.text.trim()};
    }
    if (type == 'diaper') return {'details': _notes.text.trim()};
    return <String, dynamic>{};
  }

  void _clear(String type) {
    _notes.clear();
    _food.clear();
    _dose.clear();
    _temperature.clear();
    _eventStartedAt = DateTime.now();
    if (type == 'feeding') {
      _amount.clear();
      _amountMl = 0;
      _burped = false;
      _vomited = false;
      _feedingMethods
        ..clear()
        ..add('breast');
    }
  }

  double? _parseDouble(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

  Future<void> _pickEventDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventStartedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventStartedAt),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox.shrink()),
    );
    if (time == null) return;
    setState(() {
      _eventStartedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Widget _errorWidget() => _error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsetsDirectional.only(top: 12),
          child: _SafetyCard(asset: NumuwIcons.info, message: _error!, danger: true),
        );

  Duration _durationSince(DateTime? start) => start == null ? Duration.zero : DateTime.now().difference(start);

  String _timerText(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle, required this.asset});
  final String title;
  final String subtitle;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(2, 4, 2, 0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .10)),
            child: NumuwIcon(asset, size: 24, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: secondary, fontSize: 11.5, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackHeader extends StatelessWidget {
  const _BackHeader({required this.title, required this.asset, required this.onBack});
  final String title;
  final String asset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NumuwPressable(
              onTap: onBack,
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(width: 44, height: 44, child: Center(child: NumuwIcon(NumuwIcons.back, size: 20, color: text))),
            ),
          ),
          Text(title, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w800)),
          Align(alignment: AlignmentDirectional.centerEnd, child: NumuwIcon(asset, size: 21, color: accent)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.asset, required this.onTap});
  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Semantics(
      button: true,
      label: label,
      child: NumuwPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: dark ? .13 : .08)),
              child: NumuwIcon(asset, size: 27, color: accent),
            ),
            const SizedBox(height: 7),
            Text(label, maxLines: 1, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({required this.selected, required this.asset, required this.title, required this.subtitle, required this.onTap});
  final bool selected;
  final String asset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    final surface = dark ? AppColors.nightSurface : AppColors.surface;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsetsDirectional.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selected ? accent : border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            NumuwIcon(asset, size: 28, color: selected ? accent : secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: secondary, fontSize: 11.5)),
                ],
              ),
            ),
            if (selected) NumuwIcon(NumuwIcons.check, size: 18, color: accent),
          ],
        ),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.asset, required this.message, this.danger = false});
  final String asset;
  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = danger ? AppColors.danger : (dark ? AppColors.nightPrimaryStrong : AppColors.plum);
    final text = dark ? AppColors.nightText : AppColors.text;
    return Container(
      padding: const EdgeInsetsDirectional.all(13),
      decoration: BoxDecoration(color: accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(16), border: Border.all(color: accent.withValues(alpha: .18))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwIcon(asset, size: 20, color: accent),
          const SizedBox(width: 9),
          Expanded(child: Text(message, style: TextStyle(color: text, fontSize: 11.5, height: 1.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _RecentEventRow extends StatelessWidget {
  const _RecentEventRow({required this.event});
  final CareEvent event;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final type = event.isPumping ? 'pumping' : event.eventType;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .08)),
            child: NumuwIcon(_eventAsset(type), size: 19, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ArabicFormatters.eventType(type), style: TextStyle(color: text, fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(ArabicFormatters.time(event.startedAt), style: TextStyle(color: secondary, fontSize: 10.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogSpec {
  const _LogSpec(this.title, this.button, this.asset);
  final String title;
  final String button;
  final String asset;
}

_LogSpec _spec(String type) => switch (type) {
      'food' => const _LogSpec('تسجيل الطعام', 'حفظ الطعام', NumuwIcons.food),
      'medicine' => const _LogSpec('تسجيل الدواء', 'حفظ الدواء', NumuwIcons.medicine),
      _ => const _LogSpec('إضافة ملاحظة', 'حفظ الملاحظة', NumuwIcons.note),
    };

String _eventAsset(String type) => switch (type) {
      'feeding' => NumuwIcons.feeding,
      'pumping' => NumuwIcons.pumping,
      'sleep' => NumuwIcons.sleep,
      'diaper' => NumuwIcons.diaper,
      'food' => NumuwIcons.food,
      'medicine' => NumuwIcons.medicine,
      'temperature' => NumuwIcons.temperature,
      _ => NumuwIcons.note,
    };
