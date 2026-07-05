import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../models/care_event.dart';
import '../repositories/care_event_repository.dart';
import '../state/app_events.dart';
import '../state/child_session.dart';
import '../state/log_timer_state.dart';
import '../state/numuw_app_state.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';
import 'pumping_screen.dart';

class QuickLogScreen extends StatefulWidget {
  const QuickLogScreen({super.key, this.initialMode = 'log'});

  final String initialMode;

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen> {
  final _repo = CareEventRepository();
  final _notes = TextEditingController();
  final _amount = TextEditingController();
  final _name = TextEditingController();
  final _detail = TextEditingController();
  final _temperature = TextEditingController();

  late String _mode = widget.initialMode;
  String _side = 'right';
  String _feedingMethod = 'breast';
  String _diaperType = 'wet';
  String _diaperColor = 'أصفر';
  String _temperatureMethod = 'تحت الإبط';
  String _noteCategory = 'عامة';
  String _foodReaction = 'تقبّله';
  String _medicineUnit = 'مل';
  String _medicineRepeat = 'مرة واحدة';
  bool _triedBefore = false;
  bool _burped = false;
  bool _vomited = false;
  bool _loading = false;
  String? _error;
  String? _success;
  DateTime _eventStartedAt = DateTime.now();
  Timer? _tick;
  Future<List<CareEvent>>? _recent;
  int _recentRequest = 0;

  @override
  void initState() {
    super.initState();
    _reload();
    ChildSession.instance.addListener(_onChildChanged);
    AppEvents.instance.addListener(_onExternalChanged);
    LogTimerState.instance.addListener(_onTimerChanged);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted &&
          (LogTimerState.instance.feedingActive ||
              LogTimerState.instance.sleepActive)) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    ChildSession.instance.removeListener(_onChildChanged);
    AppEvents.instance.removeListener(_onExternalChanged);
    LogTimerState.instance.removeListener(_onTimerChanged);
    _notes.dispose();
    _amount.dispose();
    _name.dispose();
    _detail.dispose();
    _temperature.dispose();
    super.dispose();
  }

  void _reload() {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final request = ++_recentRequest;
    _recent = _repo.fetchRecent(child.id, limit: 16).then((items) {
      if (request != _recentRequest ||
          ChildSession.instance.selectedChild?.id != child.id) {
        return const <CareEvent>[];
      }
      return items;
    });
  }

  void _onChildChanged() {
    if (!mounted) return;
    setState(() {
      _mode = widget.initialMode;
      _error = null;
      _success = null;
      _reload();
    });
  }

  void _onExternalChanged() {
    if (mounted) setState(_reload);
  }

  void _onTimerChanged() {
    if (mounted) setState(() {});
  }

  void _open(String value) {
    setState(() {
      _mode = value;
      _error = null;
      _success = null;
      _eventStartedAt = DateTime.now();
    });
  }

  void _back() {
    if (Navigator.of(context).canPop() && widget.initialMode != 'log') {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _mode = 'log');
  }

  Future<void> _saveEvent(
    String type, {
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
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
        feedingMethod: type == 'feeding' ? _feedingMethod : null,
        amountMl: type == 'feeding'
            ? double.tryParse(_amount.text.trim().replaceAll(',', '.'))
            : null,
        diaperWet: type == 'diaper' ? _diaperType != 'dirty' : null,
        diaperDirty: type == 'diaper' ? _diaperType != 'wet' : null,
        temperatureC: type == 'temperature'
            ? double.tryParse(_temperature.text.trim().replaceAll(',', '.'))
            : null,
        medicineName: type == 'medicine' ? _name.text.trim() : null,
        medicineDose: type == 'medicine' ? _detail.text.trim() : null,
        burped: type == 'feeding' ? _burped : null,
        vomited: type == 'feeding' ? _vomited : null,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        metadata: _metadata(type),
      );

      if (type == 'feeding') {
        await LogTimerState.instance.finishFeeding(child.id);
      }
      if (type == 'sleep') {
        await LogTimerState.instance.finishSleep(child.id);
      }

      _clear();
      setState(() {
        _success = 'تم الحفظ بنجاح';
        _reload();
        if (widget.initialMode == 'log') _mode = 'log';
      });
      Future<void>.delayed(NumuwMotion.toast, () {
        if (mounted) setState(() => _success = null);
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _metadata(String type) {
    switch (type) {
      case 'feeding':
        return {'feeding_methods': [_feedingMethod]};
      case 'diaper':
        return {'color': _diaperColor};
      case 'temperature':
        return {'measurement_method': _temperatureMethod};
      case 'medicine':
        return {
          'unit': _medicineUnit,
          'repeat': _medicineRepeat,
        };
      case 'food':
        return {
          'food_name': _name.text.trim(),
          'description': _detail.text.trim(),
          'tried_before': _triedBefore,
          'reaction': _foodReaction,
        };
      case 'note':
        return {'category': _noteCategory};
      default:
        return <String, dynamic>{};
    }
  }

  String? _validate(String type) {
    if (type == 'temperature') {
      final value = double.tryParse(_temperature.text.replaceAll(',', '.'));
      if (value == null || value < 30 || value > 45) {
        return 'أدخلي درجة حرارة صحيحة بين 30 و45.';
      }
    }
    if (type == 'medicine' && _name.text.trim().isEmpty) {
      return 'أدخلي اسم الدواء أو الفيتامين.';
    }
    if (type == 'food' && _name.text.trim().isEmpty) {
      return 'أدخلي اسم الطعام أو الوجبة.';
    }
    if (type == 'note' && _notes.text.trim().isEmpty) {
      return 'اكتبي الملاحظة أولًا.';
    }
    return null;
  }

  void _clear() {
    _notes.clear();
    _amount.clear();
    _name.clear();
    _detail.clear();
    _temperature.clear();
    _burped = false;
    _vomited = false;
    _eventStartedAt = DateTime.now();
  }

  Future<void> _feedingToggle() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final start = LogTimerState.instance.pendingFeedingStart(child.id);
    if (start == null) {
      await LogTimerState.instance.startFeeding(child.id);
      if (mounted) setState(() {});
    } else {
      await _saveEvent('feeding', startedAt: start, endedAt: DateTime.now());
    }
  }

  Future<void> _sleepToggle() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final start = LogTimerState.instance.pendingSleepStart(child.id);
    if (start == null) {
      await LogTimerState.instance.startSleep(child.id);
      if (mounted) setState(() {});
    } else {
      await _saveEvent('sleep', startedAt: start, endedAt: DateTime.now());
    }
  }

  Future<void> _pickDateTime() async {
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
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (time == null) return;
    setState(() {
      _eventStartedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      return const Scaffold(
        body: AppPage(child: EmptyState(message: 'اختاري طفلًا أولًا للتسجيل.')),
      );
    }

    final content = switch (_mode) {
      'feeding' => _feedingScreen(child.name),
      'pumping' => PumpingLogPane(onBack: _back, onChanged: _reload),
      'sleep' => _sleepScreen(child.name),
      'diaper' => _diaperScreen(),
      'food' => _foodScreen(),
      'medicine' => _medicineScreen(),
      'temperature' => _temperatureScreen(),
      'note' => _noteScreen(),
      _ => _mainScreen(child.name),
    };

    return Stack(
      children: [
        AppPage(child: content),
        if (_success != null) SuccessToast(message: _success!),
      ],
    );
  }

  Widget _mainScreen(String childName) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwAppBar(
            title: 'التسجيل',
            subtitle: 'ماذا تريدين أن تسجّلي لـ $childName؟',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              final actions = [
                _Action('feeding', 'رضاعة', Icons.local_drink_outlined, AppColors.mint),
                _Action('sleep', 'نوم', Icons.dark_mode_outlined, AppColors.blue),
                _Action('diaper', 'حفاضة', Icons.opacity_rounded, AppColors.success),
                _Action('medicine', 'دواء', Icons.medication_outlined, AppColors.peach),
                _Action('temperature', 'حرارة', Icons.thermostat_rounded, AppColors.danger),
                _Action('food', 'وجبة', Icons.restaurant_rounded, AppColors.mint),
                _Action('note', 'ملاحظة', Icons.note_alt_outlined, AppColors.blue),
                _Action('pumping', 'شفط', Icons.water_drop_outlined, AppColors.purple),
              ];
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: actions
                    .map((item) => SizedBox(
                          width: width,
                          child: _QuickActionTile(
                            item: item,
                            onTap: () => _open(item.mode),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 22),
          const NumuwSectionHeader(
            title: 'سجل اليوم',
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 12),
          _recentList(),
        ],
      );

  Widget _feedingScreen(String childName) {
    final child = ChildSession.instance.selectedChild;
    final start = child == null
        ? null
        : LogTimerState.instance.pendingFeedingStart(child.id);
    final active = start != null;
    final duration = _durationSince(start);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('تسجيل الرضاعة', 'بدأت الساعة ${ArabicFormatters.time(start ?? _eventStartedAt)}'),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('رضاعة طبيعية', _feedingMethod == 'breast', () => setState(() => _feedingMethod = 'breast')),
              const SizedBox(width: 8),
              _chip('رضاعة صناعية', _feedingMethod == 'formula', () => setState(() => _feedingMethod = 'formula')),
              const SizedBox(width: 8),
              _chip('رضاعة مختلطة', _feedingMethod == 'mixed', () => setState(() => _feedingMethod = 'mixed')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _timerCard(
          label: _side == 'right' ? 'الجهة اليمنى' : 'الجهة اليسرى',
          time: _timerText(duration),
          subtitle: 'الإجمالي ${_timerText(duration)}',
          active: active,
          onToggle: _feedingToggle,
          sideSelector: Row(
            children: [
              Expanded(child: _sideButton('الجهة اليسرى', _side == 'left', () => setState(() => _side = 'left'))),
              const SizedBox(width: 10),
              Expanded(child: _sideButton('الجهة اليمنى', _side == 'right', () => setState(() => _side = 'right'))),
            ],
          ),
        ),
        if (_feedingMethod != 'breast') ...[
          const SizedBox(height: 14),
          _formCard([NumuwNumberField(controller: _amount, label: 'الكمية (مل)', hint: '120')]),
        ],
        const SizedBox(height: 14),
        _formCard([
          _toggle('هل تجشأ الطفل؟', _burped, (value) => setState(() => _burped = value)),
          Divider(color: numuwBorderColor()),
          _toggle('هل حدث ترجيع؟', _vomited, (value) => setState(() => _vomited = value)),
        ]),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => setState(() => _error = 'التسجيل الصوتي يحتاج إذن الميكروفون.'),
          icon: const Icon(Icons.mic_none_rounded),
          label: const Text('سجّلي بصوتك'),
        ),
        const SizedBox(height: 7),
        Center(
          child: Text(
            'مثال: «رضع 15 دقيقة من اليمين و10 دقائق من الشمال»',
            style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5),
          ),
        ),
        const SizedBox(height: 14),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        _messages(),
      ],
    );
  }

  Widget _sleepScreen(String childName) {
    final child = ChildSession.instance.selectedChild;
    final start = child == null
        ? null
        : LogTimerState.instance.pendingSleepStart(child.id);
    final active = start != null;
    final duration = _durationSince(start);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('النوم', active ? 'جلسة نوم جارية' : '$childName مستيقظ الآن'),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(22),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient(numuwNightMode()),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: numuwBorderColor()),
          ),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: .12), shape: BoxShape.circle),
                child: const Icon(Icons.bedtime_rounded, color: AppColors.blue, size: 44),
              ),
              const SizedBox(height: 12),
              Text(active ? _timerText(duration) : '$childName مستيقظ الآن',
                  style: TextStyle(color: numuwTextColor(), fontSize: active ? 46 : 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              PrimaryButton(
                label: active ? 'استيقظ الآن' : 'نام الآن',
                color: active ? AppColors.danger : AppColors.blue,
                loading: _loading,
                onPressed: _sleepToggle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final width = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(width: width, child: _stat('إجمالي نوم اليوم', _timerText(duration))),
              SizedBox(width: width, child: _stat('نوم نهاري', '—')),
              SizedBox(width: width, child: _stat('نوم ليلي', '—')),
              SizedBox(width: width, child: _stat('مرات الاستيقاظ', '—')),
            ],
          );
        }),
        const SizedBox(height: 14),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        _messages(),
      ],
    );
  }

  Widget _diaperScreen() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('تسجيل الحفاضة', 'اختاري النوع ثم احفظي التسجيل'),
          const SizedBox(height: 14),
          ...[
            _diaperOption('wet', 'حفاضة مبللة', Icons.water_drop_outlined, AppColors.blue),
            _diaperOption('dirty', 'حفاضة متسخة', Icons.circle_outlined, AppColors.peach),
            _diaperOption('both', 'كلاهما', Icons.baby_changing_station_outlined, AppColors.success),
          ].expand((widget) => [widget, const SizedBox(height: 12)]),
          if (_diaperType != 'wet') ...[
            _formCard([
              Text('اللون', style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['أصفر', 'بني', 'أخضر', 'آخر']
                    .map((value) => _chip(value, _diaperColor == value, () => setState(() => _diaperColor = value)))
                    .toList(),
              ),
            ]),
            const SizedBox(height: 14),
          ],
          _eventTimeCard(),
          const SizedBox(height: 14),
          NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
          const SizedBox(height: 16),
          PrimaryButton(label: 'حفظ التسجيل', loading: _loading, color: AppColors.success, onPressed: () => _saveEvent('diaper')),
          _messages(),
        ],
      );

  Widget _temperatureScreen() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('تسجيل درجة الحرارة', 'سجّلي القياس كما ظهر على الجهاز'),
          const SizedBox(height: 14),
          _formCard([
            NumuwNumberField(controller: _temperature, label: 'درجة الحرارة (°C)', hint: '37.1'),
            const SizedBox(height: 14),
            Text('طريقة القياس', style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['تحت الإبط', 'الفم', 'الأذن', 'الجبهة', 'أخرى']
                  .map((value) => _chip(value, _temperatureMethod == value, () => setState(() => _temperatureMethod = value)))
                  .toList(),
            ),
          ]),
          const SizedBox(height: 14),
          _eventTimeCard(),
          const SizedBox(height: 14),
          NumuwTextArea(controller: _notes, label: 'ملاحظات'),
          const SizedBox(height: 14),
          InfoBanner(
            message: 'يعرض نُمُوّ القياس المسجّل فقط. إذا كنتِ قلقة بشأن حالة طفلك، تواصلي مع الطبيب.',
            color: AppColors.blue,
            background: AppColors.blueLight,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'حفظ القياس', loading: _loading, onPressed: () => _saveEvent('temperature')),
          _messages(),
        ],
      );

  Widget _medicineScreen() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('تسجيل دواء أو فيتامين', 'أدخلي فقط تعليمات الطبيب أو الصيدلي'),
          const SizedBox(height: 14),
          _formCard([
            NumuwTextField(controller: _name, label: 'اسم الدواء أو الفيتامين'),
            const SizedBox(height: 12),
            NumuwTextField(controller: _detail, label: 'الجرعة كما وصفها الطبيب'),
            const SizedBox(height: 12),
            Text('الوحدة', style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              children: ['مل', 'مجم', 'نقطة', 'قرص']
                  .map((value) => _chip(value, _medicineUnit == value, () => setState(() => _medicineUnit = value)))
                  .toList(),
            ),
            const SizedBox(height: 14),
            Text('التكرار', style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['مرة واحدة', 'يوميًا', 'كل 8 ساعات', 'حسب الحاجة']
                  .map((value) => _chip(value, _medicineRepeat == value, () => setState(() => _medicineRepeat = value)))
                  .toList(),
            ),
          ]),
          const SizedBox(height: 14),
          _eventTimeCard(),
          const SizedBox(height: 14),
          NumuwTextArea(controller: _notes, label: 'ملاحظات'),
          const SizedBox(height: 14),
          WarningBanner(message: 'نُمُوّ لا يحدد الجرعات ولا يقترح أدوية. اتبعي تعليمات الطبيب أو الصيدلي فقط.'),
          const SizedBox(height: 16),
          PrimaryButton(label: 'حفظ الجرعة', loading: _loading, onPressed: () => _saveEvent('medicine')),
          _messages(),
        ],
      );

  Widget _foodScreen() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('تسجيل وجبة', 'سجّلي الطعام والكمية ورد فعل الطفل'),
          const SizedBox(height: 14),
          _formCard([
            NumuwTextField(controller: _name, label: 'اسم الطعام أو الوجبة'),
            const SizedBox(height: 12),
            NumuwTextField(controller: _detail, label: 'الكمية التقريبية'),
            const SizedBox(height: 12),
            _toggle('هل جرب الطفل هذا الطعام من قبل؟', _triedBefore, (value) => setState(() => _triedBefore = value)),
            const SizedBox(height: 12),
            Text('رد فعل الطفل', style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['تقبّله', 'لم يتقبله', 'غير واضح']
                  .map((value) => _chip(value, _foodReaction == value, () => setState(() => _foodReaction = value)))
                  .toList(),
            ),
          ]),
          const SizedBox(height: 14),
          _eventTimeCard(),
          const SizedBox(height: 14),
          NumuwTextArea(controller: _notes, label: 'ملاحظات بعد الأكل'),
          const SizedBox(height: 16),
          PrimaryButton(label: 'حفظ الوجبة', loading: _loading, color: AppColors.success, onPressed: () => _saveEvent('food')),
          _messages(),
        ],
      );

  Widget _noteScreen() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header('إضافة ملاحظة', 'احفظي أي شيء تريدين تذكره'),
          const SizedBox(height: 14),
          _formCard([
            Text('الفئة', style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['عامة', 'رضاعة', 'نوم', 'حفاضة', 'طعام', 'دواء', 'للطبيب']
                  .map((value) => _chip(value, _noteCategory == value, () => setState(() => _noteCategory = value)))
                  .toList(),
            ),
            const SizedBox(height: 14),
            NumuwTextArea(controller: _notes, label: 'نص الملاحظة'),
          ]),
          const SizedBox(height: 14),
          _eventTimeCard(),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: () => setState(() => _error = 'إضافة المرفقات ستتاح بعد تفعيل إذن الملفات.'), icon: const Icon(Icons.attach_file_rounded), label: const Text('إرفاق صورة أو مستند')),
          const SizedBox(height: 16),
          PrimaryButton(label: 'حفظ الملاحظة', loading: _loading, onPressed: () => _saveEvent('note')),
          _messages(),
        ],
      );

  Widget _header(String title, String subtitle) => NumuwAppBar(
        title: title,
        subtitle: subtitle,
        leading: AppIconButton(
          icon: Icons.arrow_forward_rounded,
          onPressed: _back,
          badge: false,
          size: 42,
          radius: 13,
          iconSize: 20,
        ),
      );

  Widget _timerCard({
    required String label,
    required String time,
    required String subtitle,
    required bool active,
    required VoidCallback onToggle,
    required Widget sideSelector,
  }) => Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 22),
        decoration: BoxDecoration(
          color: numuwSurfaceColor(),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: numuwAccentColor().withValues(alpha: .22)),
          boxShadow: numuwNightMode() ? const [] : [BoxShadow(color: numuwAccentColor().withValues(alpha: .12), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: Column(children: [
          Text(label, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 14)),
          const SizedBox(height: 7),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(time, style: TextStyle(color: numuwAccentColor(), fontSize: 58, fontWeight: FontWeight.w900, letterSpacing: -2)),
          ),
          Text(subtitle, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 13.5)),
          const SizedBox(height: 20),
          sideSelector,
          const SizedBox(height: 20),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: numuwAccentColor().withValues(alpha: .14), shape: BoxShape.circle, border: Border.all(color: numuwAccentColor().withValues(alpha: .30))),
              child: Icon(active ? Icons.pause_rounded : Icons.play_arrow_rounded, color: numuwAccentColor(), size: 32),
            ),
          ),
        ]),
      );

  Widget _sideButton(String label, bool selected, VoidCallback onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? numuwAccentColor() : numuwSecondaryTextColor(),
          backgroundColor: selected ? numuwAccentColor().withValues(alpha: .12) : Colors.transparent,
          side: BorderSide(color: selected ? numuwAccentColor() : numuwBorderColor()),
        ),
        child: Text(label),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoicePill(label: label, selected: selected, onTap: onTap);

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) => Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: numuwTextColor(), fontSize: 15, fontWeight: FontWeight.w700))),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      );

  Widget _formCard(List<Widget> children) => SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _eventTimeCard() => SoftCard(
        onTap: _pickDateTime,
        child: Row(children: [
          Icon(Icons.schedule_rounded, color: numuwAccentColor()),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('التاريخ والوقت', style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('${ArabicFormatters.date(_eventStartedAt)} · ${ArabicFormatters.time(_eventStartedAt)}', style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 13)),
          ])),
          Icon(Icons.edit_calendar_outlined, color: numuwSecondaryTextColor()),
        ]),
      );

  Widget _diaperOption(String value, String label, IconData icon, Color color) {
    final selected = _diaperType == value;
    return SoftCard(
      onTap: () => setState(() => _diaperType = value),
      color: selected ? color.withValues(alpha: .12) : null,
      borderColor: selected ? color : null,
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color)),
        const SizedBox(width: 13),
        Expanded(child: Text(label, style: TextStyle(color: numuwTextColor(), fontSize: 16.5, fontWeight: FontWeight.w900))),
        if (selected) Icon(Icons.check_circle_rounded, color: color),
      ]),
    );
  }

  Widget _stat(String label, String value) => SoftCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5)),
          const SizedBox(height: 7),
          Text(value, style: TextStyle(color: numuwTextColor(), fontSize: 20, fontWeight: FontWeight.w900)),
        ]),
      );

  Widget _recentList() => FutureBuilder<List<CareEvent>>(
        future: _recent,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingSkeleton(height: 120);
          }
          if (snapshot.hasError) {
            return ErrorMessageCard(message: readableError(snapshot.error!));
          }
          final items = snapshot.data ?? const <CareEvent>[];
          if (items.isEmpty) {
            return const EmptyState(message: 'لا توجد تسجيلات حتى الآن. ابدئي بأول تسجيل من الأعلى.');
          }
          return SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(items.length, (index) {
                final event = items[index];
                return Column(children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _eventColor(event.eventType).withValues(alpha: .13),
                      child: Icon(_eventIcon(event.eventType), color: _eventColor(event.eventType), size: 20),
                    ),
                    title: Text(ArabicFormatters.eventType(event.eventType), style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
                    subtitle: Text(_eventSubtitle(event), style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5)),
                    trailing: Text(ArabicFormatters.time(event.startedAt), style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12)),
                  ),
                  if (index != items.length - 1) Divider(height: 1, color: numuwBorderColor()),
                ]);
              }),
            ),
          );
        },
      );

  Widget _messages() => Column(children: [
        if (_error != null) ...[const SizedBox(height: 12), ErrorMessageCard(message: _error!)],
        const SizedBox(height: 8),
      ]);

  String _eventSubtitle(CareEvent event) {
    if (event.eventType == 'feeding' && event.duration != null) {
      return '${event.duration!.inMinutes} دقيقة';
    }
    if (event.eventType == 'temperature' && event.temperatureC != null) {
      return '${event.temperatureC}°C';
    }
    if (event.eventType == 'medicine') {
      return [event.medicineName, event.medicineDose].whereType<String>().where((value) => value.isNotEmpty).join(' · ');
    }
    if (event.notes != null && event.notes!.isNotEmpty) return event.notes!;
    return 'تم التسجيل';
  }

  Color _eventColor(String type) => switch (type) {
        'feeding' => AppColors.mint,
        'sleep' => AppColors.blue,
        'diaper' => AppColors.success,
        'medicine' => AppColors.peach,
        'temperature' => AppColors.danger,
        _ => AppColors.purple,
      };

  IconData _eventIcon(String type) => switch (type) {
        'feeding' => Icons.local_drink_outlined,
        'sleep' => Icons.dark_mode_outlined,
        'diaper' => Icons.opacity_rounded,
        'medicine' => Icons.medication_outlined,
        'temperature' => Icons.thermostat_rounded,
        'food' => Icons.restaurant_rounded,
        _ => Icons.note_alt_outlined,
      };

  Duration _durationSince(DateTime? start) => start == null ? Duration.zero : DateTime.now().difference(start);

  String _timerText(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item, required this.onTap});
  final _Action item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: numuwBorderColor())),
            child: Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: item.color.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(item.icon, color: item.color, size: 21)),
              const SizedBox(width: 11),
              Expanded(child: Text(item.label, style: TextStyle(color: numuwTextColor(), fontSize: 16, fontWeight: FontWeight.w900))),
            ]),
          ),
        ),
      );
}

class _Action {
  const _Action(this.mode, this.label, this.icon, this.color);
  final String mode;
  final String label;
  final IconData icon;
  final Color color;
}
