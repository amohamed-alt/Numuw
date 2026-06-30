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
import '../widgets/app_widgets.dart';

class QuickLogScreen extends StatefulWidget {
  const QuickLogScreen({super.key});

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen> {
  final _repo = CareEventRepository();
  final _notes = TextEditingController();
  final _amount = TextEditingController();
  final _food = TextEditingController();
  final _dose = TextEditingController();
  final _temp = TextEditingController();
  String _mode = 'log';
  String _side = 'right';
  final Set<String> _feedingMethods = {'breast'};
  String _diaperType = 'wet';
  int _amountMl = 0;
  bool _burped = false;
  bool _vomited = false;
  bool _loading = false;
  String? _error;
  String? _success;
  DateTime _eventStartedAt = DateTime.now();
  Timer? _tick;
  Future<List<CareEvent>>? _recent;

  @override
  void initState() {
    super.initState();
    _reload();
    _temp.addListener(_onTemperatureChanged);
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
    _temp.removeListener(_onTemperatureChanged);
    _notes.dispose();
    _amount.dispose();
    _food.dispose();
    _dose.dispose();
    _temp.dispose();
    super.dispose();
  }

  void _reload() {
    final child = ChildSession.instance.selectedChild;
    if (child != null) _recent = _repo.fetchRecent(child.id, limit: 12);
  }

  void _onTemperatureChanged() {
    if (_mode == 'temperature' && mounted) setState(() {});
  }

  void _open(String mode) {
    setState(() {
      _mode = mode;
      _error = null;
      _success = null;
    });
  }

  void _back() => setState(() => _mode = 'log');

  Future<void> _saveEvent(
    String type, {
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _loading) return;
    _syncAmountFromText();
    final validation = _validate(type);
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await _repo.insert(
        childId: child.id,
        eventType: type,
        startedAt: startedAt ?? _eventStartedAt,
        endedAt: endedAt,
        side: type == 'feeding' ? _side : null,
        feedingMethod: type == 'feeding' ? _primaryFeedingMethod : null,
        amountMl: type == 'feeding' && _amountMl > 0
            ? _amountMl.toDouble()
            : null,
        burped: type == 'feeding' ? _burped : null,
        vomited: type == 'feeding' ? _vomited : null,
        diaperWet: type == 'diaper' ? _diaperType != 'dirty' : null,
        diaperDirty: type == 'diaper' ? _diaperType != 'wet' : null,
        temperatureC: type == 'temperature' ? _double(_temp.text) : null,
        medicineName: type == 'medicine' ? _food.text : null,
        medicineDose: type == 'medicine' ? _dose.text : null,
        notes: _notesFor(type),
        metadata: _metadataFor(type),
      );
      _clear(type);
      AppEvents.instance.careEventsChanged();
      setState(() {
        _success = '✓ تم حفظ التسجيل';
        _reload();
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

  String? _validate(String type) {
    if (type == 'feeding' && _feedingMethods.isEmpty) {
      return 'اختاري طريقة رضاعة واحدة على الأقل.';
    }
    if (type == 'temperature') {
      final value = _double(_temp.text);
      if (value == null || value < 30 || value > 45)
        return 'اكتبي درجة حرارة صحيحة بين 30 و45.';
    }
    if (type == 'medicine' && _food.text.trim().isEmpty)
      return 'اكتبي اسم الدواء.';
    if (type == 'food' && _food.text.trim().isEmpty) return 'اكتبي اسم الطعام.';
    if (type == 'note' && _notes.text.trim().isEmpty)
      return 'اكتبي الملاحظة أولًا.';
    return null;
  }

  String? _notesFor(String type) {
    final note = _notes.text.trim();
    if (type == 'food') {
      final food = _food.text.trim();
      if (food.isEmpty) return note.isEmpty ? null : note;
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
    _amount.clear();
    _food.clear();
    _dose.clear();
    _temp.clear();
    _amountMl = 0;
    _eventStartedAt = DateTime.now();
    if (type == 'feeding') {
      _feedingMethods
        ..clear()
        ..add('breast');
      _burped = false;
      _vomited = false;
    }
  }

  double? _double(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  String get _primaryFeedingMethod =>
      _feedingMethods.isEmpty ? 'breast' : _feedingMethods.first;

  void _syncAmountFromText() {
    final parsed = int.tryParse(_amount.text.trim().replaceAll(',', ''));
    if (parsed != null && parsed >= 0) {
      _amountMl = parsed.clamp(0, 990).toInt();
      if (_amount.text.trim() != _amountMl.toString()) {
        _amount.text = _amountMl == 0 ? '' : _amountMl.toString();
      }
    }
  }

  void _setAmount(int value) {
    _amountMl = value.clamp(0, 990).toInt();
    _amount.text = _amountMl == 0 ? '' : _amountMl.toString();
    setState(() {});
  }

  void _adjustAmount(int delta) {
    _syncAmountFromText();
    _setAmount(_amountMl + delta);
  }

  Future<void> _feedingToggle() async {
    if (!LogTimerState.instance.feedingActive) {
      await LogTimerState.instance.startFeeding();
      setState(() {});
      return;
    }
    final start = await LogTimerState.instance.stopFeeding();
    if (start == null) return;
    await _saveEvent('feeding', startedAt: start, endedAt: DateTime.now());
  }

  Future<void> _sleepToggle() async {
    if (!LogTimerState.instance.sleepActive) {
      await LogTimerState.instance.startSleep();
      setState(() {});
      return;
    }
    final start = await LogTimerState.instance.stopSleep();
    if (start == null) return;
    await _saveEvent('sleep', startedAt: start, endedAt: DateTime.now());
  }

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
        body: AppPage(
          child: EmptyState(message: 'اختاري طفلًا أولًا للتسجيل.'),
        ),
      );
    }
    return Stack(
      children: [
        AppPage(
          child: switch (_mode) {
            'feeding' => _feedingScreen(child.name),
            'sleep' => _sleepScreen(),
            'diaper' => _diaperScreen(),
            'food' => _genericScreen('food'),
            'medicine' => _genericScreen('medicine'),
            'temperature' => _temperatureScreen(),
            'note' => _genericScreen('note'),
            _ => _mainScreen(child.name),
          },
        ),
        if (_success != null) SuccessToast(message: _success!),
      ],
    );
  }

  Widget _mainScreen(String childName) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppHeader(
        title: 'تسجيل سريع ✏️',
        subtitle: 'سجّلي أحداث $childName اليومية',
        showNotification: false,
      ),
      const SizedBox(height: 22),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
        childAspectRatio: .78,
        children: [
          Center(
            child: QuickLogTypeButton(
              label: 'رضاعة',
              icon: '🍼',
              background: AppColors.mintLight,
              border: AppColors.mint,
              onTap: () => _open('feeding'),
            ),
          ),
          Center(
            child: QuickLogTypeButton(
              label: 'نوم',
              icon: '🌙',
              background: AppColors.mintLight,
              border: AppColors.mint,
              onTap: () => _open('sleep'),
            ),
          ),
          Center(
            child: QuickLogTypeButton(
              label: 'حفاضة',
              icon: '🧷',
              background: AppColors.purpleLight,
              border: AppColors.purple,
              onTap: () => _open('diaper'),
            ),
          ),
          Center(
            child: QuickLogTypeButton(
              label: 'طعام',
              icon: '🥣',
              background: AppColors.yellowLight,
              border: AppColors.yellow,
              onTap: () => _open('food'),
            ),
          ),
          Center(
            child: QuickLogTypeButton(
              label: 'دواء',
              icon: '💊',
              background: AppColors.blueLight,
              border: AppColors.blue,
              onTap: () => _open('medicine'),
            ),
          ),
          Center(
            child: QuickLogTypeButton(
              label: 'حرارة',
              icon: '🌡️',
              background: AppColors.peachLight,
              border: AppColors.danger,
              onTap: () => _open('temperature'),
            ),
          ),
          Center(
            child: QuickLogTypeButton(
              label: 'ملاحظة',
              icon: '📝',
              background: AppColors.neutralSoft,
              border: AppColors.mutedText,
              onTap: () => _open('note'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const SectionTitle(
        title: 'سجل اليوم',
        icon: Icons.calendar_month_outlined,
      ),
      const SizedBox(height: 12),
      _recentList(),
    ],
  );

  Widget _screenHeader(String title) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 16),
    child: Row(
      children: [
        AppIconButton(
          icon: Icons.arrow_forward_rounded,
          onPressed: _back,
          badge: false,
          size: 42,
          radius: 13,
          iconSize: 20,
          borderWidth: 1.5,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$title ${_iconForMode(_mode)}',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _feedingScreen(String childName) {
    final active = LogTimerState.instance.feedingActive;
    final duration = _durationSince(LogTimerState.instance.feedingStart);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _screenHeader('رضاعة'),
        TimerCard(
          time: _timerText(duration),
          status: active ? 'جارية الآن' : 'جاهزة للبدء',
          color: AppColors.mint,
          active: active,
          buttonLabel: active ? '⏹ إيقاف وحفظ' : '▶ بدء الرضاعة',
          onPressed: _loading ? null : _feedingToggle,
        ),
        const SizedBox(height: 14),
        _choiceCard(
          'الثدي',
          _equalSegmented(
            value: _side,
            items: const {'right': 'يمين', 'left': 'يسار', 'both': 'كلاهما'},
            onChanged: (v) => setState(() => _side = v),
          ),
        ),
        const SizedBox(height: 12),
        _feedingMethodCard(),
        const SizedBox(height: 12),
        _amountCard(),
        const SizedBox(height: 12),
        SoftCard(
          padding: const EdgeInsetsDirectional.all(15),
          child: Column(
            children: [
              _toggleRow(
                'تجشّأ',
                _burped,
                (value) => setState(() => _burped = value),
              ),
              const SizedBox(height: 13),
              _toggleRow(
                'استفرغ',
                _vomited,
                (value) => setState(() => _vomited = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        _messages(),
      ],
    );
  }

  Widget _sleepScreen() {
    final active = LogTimerState.instance.sleepActive;
    final duration = _durationSince(LogTimerState.instance.sleepStart);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _screenHeader('نوم'),
        _sleepTimerCard(active, duration),
        const SizedBox(height: 12),
        SoftCard(
          child: Text(
            'وقت البدء: ${ArabicFormatters.time(LogTimerState.instance.sleepStart)}',
            textAlign: TextAlign.start,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        _messages(),
      ],
    );
  }

  Widget _diaperScreen() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _screenHeader('حفاضة'),
      _eventTimeCard(),
      const SizedBox(height: 12),
      _diaperCard(
        'wet',
        '💧',
        'مبللة',
        'بول فقط',
        AppColors.mint,
        AppColors.mintLight,
      ),
      const SizedBox(height: 12),
      _diaperCard(
        'dirty',
        '💩',
        'متسخة',
        'براز فقط',
        AppColors.peach,
        AppColors.peachLight,
      ),
      const SizedBox(height: 12),
      _diaperCard(
        'both',
        '🧷',
        'مبللة ومتسخة',
        'بول وبراز معاً',
        AppColors.purple,
        AppColors.purpleLight,
      ),
      const SizedBox(height: 16),
      NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'حفظ الحفاضة',
        color: AppColors.purple,
        loading: _loading,
        onPressed: () => _saveEvent('diaper'),
      ),
      _messages(),
    ],
  );

  Widget _genericScreen(String type) {
    final spec = _spec(type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _screenHeader(spec.title),
        _eventTimeCard(),
        const SizedBox(height: 12),
        if (type == 'food') ...[
          NumuwTextField(controller: _food, label: 'اسم الطعام'),
          const SizedBox(height: 12),
          NumuwTextField(controller: _dose, label: 'الكمية أو الوصف'),
          const SizedBox(height: 12),
          NumuwTextArea(controller: _notes, label: 'ملاحظات التفاعل'),
        ] else if (type == 'medicine') ...[
          NumuwTextField(controller: _food, label: 'اسم الدواء'),
          const SizedBox(height: 12),
          NumuwTextField(controller: _dose, label: 'الجرعة'),
          const SizedBox(height: 12),
          WarningBanner(
            message:
                'لا يقدّم نُمُوّ جرعات أو وصفات دوائية. اتبعي تعليمات الطبيب فقط.',
          ),
          const SizedBox(height: 12),
          NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        ] else ...[
          NumuwTextArea(controller: _notes, label: 'الملاحظة'),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: spec.button,
          color: spec.color,
          loading: _loading,
          onPressed: () => _saveEvent(type),
        ),
        _messages(),
      ],
    );
  }

  Widget _temperatureScreen() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _screenHeader('حرارة'),
      _eventTimeCard(),
      const SizedBox(height: 12),
      SoftCard(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 22, 18, 18),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                _temp.text.trim().isEmpty ? '37.2' : _temp.text.trim(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'درجة مئوية',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            NumuwNumberField(
              controller: _temp,
              label: 'درجة الحرارة',
              hint: '37.2',
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      WarningBanner(
        message:
            'هذا التسجيل لا يمثل تشخيصًا. إذا كانت الحرارة عالية أو الحالة مقلقة تواصلي مع الطبيب.',
      ),
      const SizedBox(height: 12),
      NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'حفظ التسجيل ✓',
        color: AppColors.danger,
        loading: _loading,
        onPressed: () => _saveEvent('temperature'),
      ),
      _messages(),
    ],
  );

  Widget _feedingMethodCard() => SoftCard(
    padding: const EdgeInsetsDirectional.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الرضعة',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _feedingChip('breast', 'طبيعية'),
            _feedingChip('bottle', 'زجاجة'),
            _feedingChip('formula', 'صناعية'),
            _feedingChip('pumping', 'شفط'),
            _feedingChip('mixed', 'مختلطة'),
          ],
        ),
      ],
    ),
  );

  Widget _eventTimeCard() => SoftCard(
    padding: const EdgeInsetsDirectional.all(15),
    onTap: _pickEventDateTime,
    child: Row(
      children: [
        const IconBadge(icon: '🕒', background: AppColors.mintLight, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'وقت التسجيل',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${ArabicFormatters.date(_eventStartedAt)} · ${ArabicFormatters.time(_eventStartedAt)}',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.edit_calendar_outlined,
          color: numuwSecondaryTextColor(),
          size: 20,
        ),
      ],
    ),
  );

  Widget _amountCard() => SoftCard(
    padding: const EdgeInsetsDirectional.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كمية الحليب (مل)',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          onChanged: (_) => _syncAmountFromText(),
          decoration: InputDecoration(
            hintText: 'مثال: 25',
            suffixText: 'مل',
            filled: true,
            fillColor: numuwSurfaceColor(),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: numuwBorderColor()),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: numuwBorderColor()),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.mint, width: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _AmountQuickButton(label: '-10', onTap: () => _adjustAmount(-10)),
            _AmountQuickButton(label: '-5', onTap: () => _adjustAmount(-5)),
            _AmountQuickButton(label: '+5', onTap: () => _adjustAmount(5)),
            _AmountQuickButton(label: '+10', onTap: () => _adjustAmount(10)),
            _AmountQuickButton(label: '30 مل', onTap: () => _setAmount(30)),
            _AmountQuickButton(label: '60 مل', onTap: () => _setAmount(60)),
            _AmountQuickButton(label: '90 مل', onTap: () => _setAmount(90)),
            _AmountQuickButton(label: '120 مل', onTap: () => _setAmount(120)),
          ],
        ),
      ],
    ),
  );
  Widget _feedingChip(String value, String label) {
    final selected = _feedingMethods.contains(value);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          if (selected) {
            _feedingMethods.remove(value);
          } else {
            _feedingMethods.add(value);
          }
        });
      },
      child: AnimatedContainer(
        duration: NumuwMotion.fast,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 13,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintLight : numuwSurfaceColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.mint : numuwBorderColor(),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.mintDark : numuwTextColor(),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _sleepTimerCard(bool active, Duration duration) => SoftCard(
    radius: 24,
    padding: const EdgeInsetsDirectional.fromSTEB(18, 32, 18, 18),
    child: Column(
      children: [
        const IconBadge(icon: '🌙', background: AppColors.mintLight, size: 72),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppColors.purple : AppColors.mutedText,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              active ? 'ينام الآن' : 'جاهز للنوم',
              style: const TextStyle(
                color: AppColors.purple,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            _timerText(duration),
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 54,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: active ? '⏹ استيقظ — حفظ النوم' : '▶ بدء النوم',
          color: active ? AppColors.danger : AppColors.purple,
          onPressed: _loading ? null : _sleepToggle,
        ),
      ],
    ),
  );

  Widget _choiceCard(String title, Widget child) => SoftCard(
    padding: const EdgeInsetsDirectional.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );

  Widget _equalSegmented({
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) => Row(
    children: items.entries
        .map(
          (entry) => Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: entry.key == items.keys.last ? 0 : 9,
              ),
              child: ChoicePill(
                label: entry.value,
                selected: entry.key == value,
                onTap: () => onChanged(entry.key),
              ),
            ),
          ),
        )
        .toList(),
  );

  Widget _toggleRow(String title, bool value, ValueChanged<bool> onChanged) =>
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          NumuwSwitch(value: value, onChanged: onChanged),
        ],
      );

  Widget _diaperCard(
    String value,
    String icon,
    String title,
    String subtitle,
    Color color,
    Color background,
  ) {
    final selected = _diaperType == value;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _diaperType = value),
      child: AnimatedContainer(
        duration: NumuwMotion.fast,
        height: 60,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? background : numuwSurfaceColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : numuwBorderColor(),
            width: 2.5,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: selected ? color : numuwTextColor(),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 12,
                      height: 1.25,
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

  Widget _recentList() => FutureBuilder<List<CareEvent>>(
    future: _recent,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const LoadingSkeleton(height: 120);
      if (snapshot.hasError)
        return ErrorMessageCard(message: readableError(snapshot.error!));
      final events = snapshot.data ?? const <CareEvent>[];
      if (events.isEmpty)
        return const EmptyState(message: 'لا توجد تسجيلات بعد.');
      return SoftCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < events.length; i++) ...[
              ActivityListItem(
                icon: _eventIcon(events[i].eventType),
                background: _eventBg(events[i].eventType),
                title: ArabicFormatters.eventType(events[i].eventType),
                subtitle:
                    '${ArabicFormatters.time(events[i].startedAt)}${events[i].notes == null ? '' : ' · ${events[i].notes}'}',
              ),
              if (i != events.length - 1)
                Divider(height: 1, color: numuwBorderColor()),
            ],
          ],
        ),
      );
    },
  );

  Widget _messages() => Column(
    children: [
      if (_error != null) ...[
        const SizedBox(height: 12),
        ErrorMessageCard(message: _error!),
      ],
    ],
  );

  Duration _durationSince(DateTime? start) =>
      start == null ? Duration.zero : DateTime.now().difference(start);
  String _timerText(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0)
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _AmountQuickButton extends StatelessWidget {
  const _AmountQuickButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mint.withValues(alpha: .28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.mintDark,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _EventSpec {
  const _EventSpec(this.title, this.button, this.color);
  final String title;
  final String button;
  final Color color;
}

_EventSpec _spec(String type) => switch (type) {
  'food' => const _EventSpec('طعام', 'حفظ الطعام', AppColors.yellow),
  'medicine' => const _EventSpec('دواء', 'حفظ الدواء', AppColors.blue),
  _ => const _EventSpec('ملاحظة', 'حفظ الملاحظة', AppColors.text),
};

String _iconForMode(String mode) => switch (mode) {
  'feeding' => '🍼',
  'sleep' => '🌙',
  'diaper' => '🧷',
  'food' => '🥣',
  'medicine' => '💊',
  'temperature' => '🌡️',
  _ => '📝',
};

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
  'feeding' => AppColors.mintLight,
  'sleep' => AppColors.mintLight,
  'diaper' => AppColors.purpleLight,
  'food' => AppColors.yellowLight,
  'medicine' => AppColors.blueLight,
  'temperature' => AppColors.peachLight,
  _ => AppColors.mintLight,
};
