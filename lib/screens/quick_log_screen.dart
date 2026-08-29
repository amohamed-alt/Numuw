import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../design/numuw_motion_widgets.dart';
import '../design/numuw_organic_icons.dart';
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
  int _recentRequest = 0;

  @override
  void initState() {
    super.initState();
    _reload();
    ChildSession.instance.addListener(_onChildChanged);
    AppEvents.instance.addListener(_onExternalChanged);
    LogTimerState.instance.addListener(_onTimerChanged);
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
    ChildSession.instance.removeListener(_onChildChanged);
    AppEvents.instance.removeListener(_onExternalChanged);
    LogTimerState.instance.removeListener(_onTimerChanged);
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
    if (child == null) return;
    final request = ++_recentRequest;
    _recent = _repo.fetchRecent(child.id, limit: 12).then((events) {
      if (request != _recentRequest ||
          ChildSession.instance.selectedChild?.id != child.id) {
        return const <CareEvent>[];
      }
      return events;
    });
  }

  void _onChildChanged() {
    if (!mounted) return;
    setState(() {
      _mode = 'log';
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

  void _back() => setState(() {
    _mode = 'log';
    _error = null;
  });

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
      await NumuwAppState.instance.saveCareEvent(
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

      if (type == 'sleep') await LogTimerState.instance.finishSleep(child.id);
      if (type == 'feeding') {
        await LogTimerState.instance.finishFeeding(child.id);
      }

      _clear(type);
      setState(() {
        _success = 'تم حفظ التسجيل';
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
      if (value == null || value < 30 || value > 45) {
        return 'اكتبي درجة حرارة صحيحة بين 30 و45.';
      }
    }
    if (type == 'medicine' && _food.text.trim().isEmpty) {
      return 'اكتبي اسم الدواء.';
    }
    if (type == 'food' && _food.text.trim().isEmpty) {
      return 'اكتبي اسم الطعام.';
    }
    if (type == 'note' && _notes.text.trim().isEmpty) {
      return 'اكتبي الملاحظة أولًا.';
    }
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
    if (parsed == null || parsed < 0) return;
    _amountMl = parsed.clamp(0, 990).toInt();
    if (_amount.text.trim() != _amountMl.toString()) {
      _amount.text = _amountMl == 0 ? '' : _amountMl.toString();
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
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final activeStart = LogTimerState.instance.pendingFeedingStart(child.id);
    if (activeStart == null) {
      await LogTimerState.instance.startFeeding(child.id);
      if (mounted) setState(() {});
      return;
    }
    await _saveEvent(
      'feeding',
      startedAt: activeStart,
      endedAt: DateTime.now(),
    );
  }

  Future<void> _sleepToggle() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final activeStart = LogTimerState.instance.pendingSleepStart(child.id);
    if (activeStart == null) {
      await LogTimerState.instance.startSleep(child.id);
      NumuwAppState.instance.refreshDashboard(force: true);
      if (mounted) setState(() {});
      return;
    }
    await _saveEvent('sleep', startedAt: activeStart, endedAt: DateTime.now());
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

    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final content = switch (_mode) {
      'feeding' => _feedingScreen(child.name),
      'pumping' => PumpingLogPane(onBack: _back, onChanged: _reload),
      'sleep' => _sleepScreen(),
      'diaper' => _diaperScreen(),
      'food' => _genericScreen('food'),
      'medicine' => _genericScreen('medicine'),
      'temperature' => _temperatureScreen(),
      'note' => _genericScreen('note'),
      _ => _mainScreen(child.name),
    };

    return Stack(
      children: [
        NumuwSuccessPulse(
          trigger: _success,
          child: AppPage(
            child: AnimatedSwitcher(
              duration: reducedMotion ? Duration.zero : NumuwMotionSpec.quick,
              switchInCurve: NumuwMotionSpec.standard,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(_mode), child: content),
            ),
          ),
        ),
        if (_success != null) SuccessToast(message: _success!),
      ],
    );
  }

  Widget _mainScreen(String childName) {
    final actions = <_QuickAction>[
      _QuickAction('feeding', 'رضاعة', NumuwOrganicIconName.breastfeeding, AppColors.mint, AppColors.mintLight),
      _QuickAction('pumping', 'شفط', NumuwOrganicIconName.bottle, AppColors.mintDark, AppColors.mintSoft),
      _QuickAction('sleep', 'نوم', NumuwOrganicIconName.sleep, AppColors.purple, AppColors.purpleLight),
      _QuickAction('diaper', 'حفاضة', NumuwOrganicIconName.diaper, AppColors.purple, AppColors.purpleLight),
      _QuickAction('food', 'طعام', NumuwOrganicIconName.food, AppColors.yellow, AppColors.yellowLight),
      _QuickAction('medicine', 'دواء', NumuwOrganicIconName.medicine, AppColors.blue, AppColors.blueLight),
      _QuickAction('temperature', 'حرارة', NumuwOrganicIconName.temperature, AppColors.danger, AppColors.peachLight),
      _QuickAction('note', 'ملاحظة', NumuwOrganicIconName.edit, AppColors.mutedText, AppColors.neutralSoft),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumuwAppBar(
          title: 'تسجيل سريع',
          subtitle: 'سجّلي أحداث $childName اليومية بأقل عدد من الخطوات',
          trailing: const NumuwStatusBadge(label: 'جاهزة', color: AppColors.mint),
        ),
        const SizedBox(height: 16),
        NumuwCard(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ماذا تريدين تسجيله؟',
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اختاري الحدث وسيحتفظ نُمُوّ بباقي التفاصيل في مكان واحد.',
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 360 ? 4 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .82,
                    ),
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return _OrganicQuickActionCard(
                        action: action,
                        onTap: () => _open(action.mode),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const NumuwOrganicIcon(
              NumuwOrganicIconName.calendar,
              size: 34,
              semanticLabel: 'سجل اليوم',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'سجل اليوم',
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _recentList(),
      ],
    );
  }

  Widget _feedingScreen(String childName) {
    final active = LogTimerState.instance.feedingActive;
    final duration = _durationSince(LogTimerState.instance.feedingStart);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailHeader(
          title: 'رضاعة',
          subtitle: 'سجّلي رضعة $childName بسرعة ووضوح',
          icon: NumuwOrganicIconName.breastfeeding,
          status: active ? 'مستمرة' : 'جاهزة',
          statusColor: active ? AppColors.peach : AppColors.mint,
        ),
        const SizedBox(height: 14),
        TimerCard(
          time: _timerText(duration),
          status: active ? 'جارية الآن' : 'جاهزة للبدء',
          color: AppColors.mint,
          active: active,
          buttonLabel: active ? 'إيقاف وحفظ' : 'بدء الرضاعة',
          onPressed: _loading ? null : _feedingToggle,
        ),
        const SizedBox(height: 14),
        _choiceCard(
          'الثدي',
          _equalSegmented(
            value: _side,
            items: const {'right': 'يمين', 'left': 'يسار', 'both': 'كلاهما'},
            onChanged: (value) => setState(() => _side = value),
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
              _toggleRow('تجشّأ', _burped, (value) => setState(() => _burped = value)),
              const SizedBox(height: 13),
              _toggleRow('استفرغ', _vomited, (value) => setState(() => _vomited = value)),
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
    final child = ChildSession.instance.selectedChild;
    final start = child == null ? null : LogTimerState.instance.sleepStartForChild(child.id);
    final active = start != null;
    final duration = _durationSince(start);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailHeader(
          title: 'نوم',
          subtitle: 'ابدئي أو أوقفي النوم مع أقل عدد من الخطوات',
          icon: NumuwOrganicIconName.sleep,
          status: active ? 'نائم الآن' : 'جاهز',
          statusColor: active ? AppColors.purple : AppColors.mint,
        ),
        const SizedBox(height: 14),
        _sleepTimerCard(active, duration),
        const SizedBox(height: 12),
        _eventTimeCard(),
        const SizedBox(height: 12),
        NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
        _messages(),
      ],
    );
  }

  Widget _diaperScreen() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _detailHeader(
        title: 'حفاضة',
        subtitle: 'اختيار سريع يركّز على النظافة والوضوح',
        icon: NumuwOrganicIconName.diaper,
        status: 'سريع',
        statusColor: AppColors.purple,
      ),
      const SizedBox(height: 14),
      _eventTimeCard(),
      const SizedBox(height: 12),
      _diaperCard('wet', NumuwOrganicIconName.water, 'مبللة', 'بول فقط', AppColors.mint, AppColors.mintLight),
      const SizedBox(height: 12),
      _diaperCard('dirty', NumuwOrganicIconName.diaper, 'متسخة', 'براز فقط', AppColors.peach, AppColors.peachLight),
      const SizedBox(height: 12),
      _diaperCard('both', NumuwOrganicIconName.diaper, 'مبللة ومتسخة', 'بول وبراز معًا', AppColors.purple, AppColors.purpleLight),
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
        _detailHeader(
          title: spec.title,
          subtitle: 'سجّلي التفاصيل بدون ازدحام بصري',
          icon: _organicIconForType(type),
          status: spec.title,
          statusColor: spec.color,
        ),
        const SizedBox(height: 14),
        _genericIntroCard(type),
        const SizedBox(height: 14),
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
          const WarningBanner(
            message: 'لا يقدّم نُمُوّ جرعات أو وصفات دوائية. اتبعي تعليمات الطبيب فقط.',
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
      _detailHeader(
        title: 'حرارة',
        subtitle: 'ادخلي القراءة بوضوح مع تذكير مسؤول',
        icon: NumuwOrganicIconName.temperature,
        status: 'تنبيه صحي',
        statusColor: AppColors.danger,
      ),
      const SizedBox(height: 14),
      _eventTimeCard(),
      const SizedBox(height: 12),
      SoftCard(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 20, 18, 18),
        child: Column(
          children: [
            const NumuwOrganicIcon(
              NumuwOrganicIconName.temperature,
              size: 62,
              semanticLabel: 'درجة الحرارة',
            ),
            const SizedBox(height: 12),
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
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            NumuwNumberField(controller: _temp, label: 'درجة الحرارة', hint: '37.2'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const WarningBanner(
        message: 'هذا التسجيل لا يمثل تشخيصًا. إذا كانت الحرارة عالية أو الحالة مقلقة تواصلي مع الطبيب.',
      ),
      const SizedBox(height: 12),
      NumuwTextArea(controller: _notes, label: 'ملاحظات اختيارية'),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'حفظ التسجيل',
        color: AppColors.danger,
        loading: _loading,
        onPressed: () => _saveEvent('temperature'),
      ),
      _messages(),
    ],
  );

  Widget _detailHeader({
    required String title,
    required String subtitle,
    required NumuwOrganicIconName icon,
    required String status,
    required Color statusColor,
  }) => NumuwCard(
    padding: const EdgeInsetsDirectional.all(15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NumuwPressable(
          onTap: _back,
          semanticLabel: 'العودة للتسجيل السريع',
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: NumuwOrganicIcon(
                NumuwOrganicIconName.cancel,
                size: 34,
                semanticLabel: 'رجوع',
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        NumuwOrganicIcon(icon, size: 48, semanticLabel: title),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        NumuwStatusBadge(label: status, color: statusColor),
      ],
    ),
  );

  Widget _genericIntroCard(String type) {
    final spec = _spec(type);
    final title = switch (type) {
      'food' => 'تسجيل الوجبة',
      'medicine' => 'تنبيه دوائي',
      _ => 'ملاحظة سريعة',
    };
    final subtitle = switch (type) {
      'food' => 'اكتبي الاسم والكمية أو الوصف ثم أضيفي أي تفاعل لاحظتيه بعد الوجبة.',
      'medicine' => 'التوثيق هنا فقط. لا تغيّري الجرعة أو التوقيت إلا حسب تعليمات الطبيب.',
      _ => 'اكتبي أي تفصيل مهم بشكل واضح ثم احفظيه للرجوع إليه لاحقًا.',
    };
    final tags = switch (type) {
      'food' => const ['اسم الوجبة', 'الكمية', 'التفاعل'],
      'medicine' => const ['الاسم', 'الجرعة', 'الوقت'],
      _ => const ['سريع', 'واضح', 'قابل للرجوع'],
    };

    return NumuwCard(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 15, 16, 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwOrganicIcon(_organicIconForType(type), size: 50, semanticLabel: title),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 12.8,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in tags) NumuwStatusBadge(label: tag, color: spec.color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedingMethodCard() => SoftCard(
    padding: const EdgeInsetsDirectional.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الرضعة',
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
            _feedingChip('mixed', 'مختلطة'),
          ],
        ),
      ],
    ),
  );

  Widget _feedingChip(String value, String label) {
    final selected = _feedingMethods.contains(value);
    return ChoicePill(
      label: label,
      selected: selected,
      onTap: () {
        setState(() {
          if (selected) {
            _feedingMethods.remove(value);
          } else {
            _feedingMethods.add(value);
          }
        });
      },
    );
  }

  Widget _eventTimeCard() => NumuwPressable(
    onTap: _pickEventDateTime,
    semanticLabel: 'تعديل وقت التسجيل',
    child: SoftCard(
      padding: const EdgeInsetsDirectional.all(15),
      child: Row(
        children: [
          const NumuwOrganicIcon(
            NumuwOrganicIconName.calendar,
            size: 42,
            semanticLabel: 'وقت التسجيل',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وقت التسجيل',
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${ArabicFormatters.date(_eventStartedAt)} · ${ArabicFormatters.time(_eventStartedAt)}',
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const NumuwOrganicIcon(
            NumuwOrganicIconName.edit,
            size: 30,
            semanticLabel: 'تعديل',
          ),
        ],
      ),
    ),
  );

  Widget _amountCard() => SoftCard(
    padding: const EdgeInsetsDirectional.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كمية الحليب (مل)',
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
            contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
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

  Widget _sleepTimerCard(bool active, Duration duration) => SoftCard(
    radius: 24,
    padding: const EdgeInsetsDirectional.fromSTEB(18, 28, 18, 18),
    child: Column(
      children: [
        const NumuwOrganicIcon(
          NumuwOrganicIconName.sleep,
          size: 76,
          semanticLabel: 'النوم',
        ),
        const SizedBox(height: 14),
        Text(
          active ? 'ينام الآن' : 'جاهز للنوم',
          style: const TextStyle(
            color: AppColors.purple,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
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
          label: active ? 'استيقظ — حفظ النوم' : 'بدء النوم',
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
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
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
              padding: EdgeInsetsDirectional.only(end: entry.key == items.keys.last ? 0 : 9),
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

  Widget _toggleRow(String title, bool value, ValueChanged<bool> onChanged) => Row(
    children: [
      Expanded(
        child: Text(
          title,
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
    NumuwOrganicIconName icon,
    String title,
    String subtitle,
    Color color,
    Color background,
  ) {
    final selected = _diaperType == value;
    return NumuwPressable(
      onTap: () => setState(() => _diaperType = value),
      semanticLabel: '$title، $subtitle',
      child: AnimatedContainer(
        duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
            ? Duration.zero
            : NumuwMotionSpec.quick,
        minHeight: 66,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? background : numuwSurfaceColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : numuwBorderColor(),
            width: selected ? 2.2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            NumuwOrganicIcon(icon, size: 44, semanticLabel: title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? color : numuwTextColor(),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const NumuwOrganicIcon(
                NumuwOrganicIconName.done,
                size: 30,
                semanticLabel: 'محدد',
              ),
          ],
        ),
      ),
    );
  }

  Widget _recentList() => FutureBuilder<List<CareEvent>>(
    future: _recent,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const LoadingSkeleton(height: 120);
      }
      if (snapshot.hasError) {
        return ErrorMessageCard(message: readableError(snapshot.error!));
      }
      final events = snapshot.data ?? const <CareEvent>[];
      if (events.isEmpty) {
        return const EmptyState(message: 'لا توجد تسجيلات بعد.');
      }
      return SoftCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < events.length; i++) ...[
              _OrganicActivityTile(event: events[i]),
              if (i != events.length - 1) Divider(height: 1, color: numuwBorderColor()),
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

  String _timerText(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _QuickAction {
  const _QuickAction(
    this.mode,
    this.label,
    this.icon,
    this.color,
    this.background,
  );

  final String mode;
  final String label;
  final NumuwOrganicIconName icon;
  final Color color;
  final Color background;
}

class _OrganicQuickActionCard extends StatelessWidget {
  const _OrganicQuickActionCard({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    onTap: onTap,
    semanticLabel: action.label,
    child: Container(
      decoration: BoxDecoration(
        color: action.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: action.color.withValues(alpha: .35), width: 1.3),
        boxShadow: numuwNightMode()
            ? const []
            : [
                BoxShadow(
                  color: action.color.withValues(alpha: .10),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 8, 9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NumuwOrganicIcon(action.icon, size: 48, semanticLabel: action.label),
          const SizedBox(height: 6),
          Text(
            action.label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class _OrganicActivityTile extends StatelessWidget {
  const _OrganicActivityTile({required this.event});

  final CareEvent event;

  @override
  Widget build(BuildContext context) {
    final type = event.isPumping ? 'pumping' : event.eventType;
    final title = event.isPumping
        ? ArabicFormatters.eventType('pumping')
        : ArabicFormatters.eventType(event.eventType);
    final subtitle = event.isPumping
        ? pumpingSubtitle(event)
        : '${ArabicFormatters.time(event.startedAt)}${event.notes == null ? '' : ' · ${event.notes}'}';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Row(
        children: [
          NumuwOrganicIcon(
            _organicIconForType(type),
            size: 42,
            semanticLabel: title,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountQuickButton extends StatelessWidget {
  const _AmountQuickButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    onTap: onTap,
    semanticLabel: label,
    child: Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
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

NumuwOrganicIconName _organicIconForType(String type) => switch (type) {
  'feeding' => NumuwOrganicIconName.breastfeeding,
  'pumping' => NumuwOrganicIconName.bottle,
  'sleep' => NumuwOrganicIconName.sleep,
  'diaper' => NumuwOrganicIconName.diaper,
  'food' => NumuwOrganicIconName.food,
  'medicine' => NumuwOrganicIconName.medicine,
  'temperature' => NumuwOrganicIconName.temperature,
  _ => NumuwOrganicIconName.edit,
};
