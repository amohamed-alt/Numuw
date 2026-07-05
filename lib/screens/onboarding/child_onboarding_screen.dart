import 'package:flutter/material.dart';

import '../../core/errors/app_error.dart';
import '../../repositories/child_repository.dart';
import '../../widgets/app_widgets.dart';

class ChildOnboardingScreen extends StatefulWidget {
  const ChildOnboardingScreen({super.key, required this.onSaved});

  final Future<void> Function() onSaved;

  @override
  State<ChildOnboardingScreen> createState() =>
      _ChildOnboardingScreenState();
}

class _ChildOnboardingScreenState extends State<ChildOnboardingScreen> {
  final _repo = ChildRepository();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _birthDate = TextEditingController();
  final _dueDate = TextEditingController();
  final _country = TextEditingController(text: 'مصر');

  int _step = 1;
  String? _stage;
  String _gender = 'unspecified';
  String _feeding = 'breast';
  String? _share;
  bool _firstChild = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _birthDate.dispose();
    _dueDate.dispose();
    _country.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_step == 1) return _stage != null;
    if (_step == 2) return true;
    return _share != null;
  }

  void _next() {
    if (!_canContinue) return;
    if (_step == 2 && !_formKey.currentState!.validate()) return;
    if (_step < 3) {
      setState(() {
        _step++;
        _error = null;
      });
      return;
    }
    _save();
  }

  void _back() {
    if (_step <= 1) return;
    setState(() {
      _step--;
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _loading || _stage == null) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.createChild(
        name: _stage == 'pregnancy' && _name.text.trim().isEmpty
            ? 'طفلي القادم'
            : _name.text.trim(),
        stage: _stage!,
        birthDate: _stage == 'born' ? _parseDate(_birthDate.text) : null,
        dueDate: _stage == 'pregnancy' ? _parseDate(_dueDate.text) : null,
        gender: _stage == 'born' ? _gender : 'unspecified',
        feedingType: _stage == 'born' ? _feeding : 'not_set',
        bloodType: null,
        birthWeightKg: null,
      );
      await widget.onSaved();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final current = _parseDate(controller.text);
    final selected = await showDatePicker(
      context: context,
      initialDate: current ??
          (_stage == 'pregnancy'
              ? now.add(const Duration(days: 120))
              : now),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ar'),
    );
    if (selected == null) return;
    controller.text = _dateOnly(selected);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Progress(step: _step),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      child: switch (_step) {
                        1 => _stageStep(),
                        2 => _detailsStep(),
                        _ => _sharingStep(),
                      },
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  ErrorMessageCard(message: _error!),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (_step > 1) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : _back,
                          child: const Text('رجوع'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: _step == 3 ? 'إنهاء الإعداد' : 'التالي',
                        loading: _loading,
                        onPressed: _canContinue ? _next : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stageStep() => Column(
        key: const ValueKey('stage'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أنتِ الآن…',
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          _BigChoice(
            icon: Icons.favorite_rounded,
            active: _stage == 'pregnancy',
            title: 'ما زلت حاملًا',
            description: 'سنجهّز معكِ كل شيء لاستقبال طفلك.',
            onTap: () => setState(() => _stage = 'pregnancy'),
          ),
          const SizedBox(height: 14),
          _BigChoice(
            icon: Icons.child_care_rounded,
            active: _stage == 'born',
            title: 'طفلي وُلد بالفعل',
            description: 'لنبدأ متابعة يوم طفلك خطوة بخطوة.',
            onTap: () => setState(() => _stage = 'born'),
          ),
        ],
      );

  Widget _detailsStep() => Column(
        key: const ValueKey('details'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stage == 'pregnancy' ? 'تفاصيل الحمل' : 'معلومات طفلك',
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          if (_stage == 'pregnancy') ...[
            _DateField(
              label: 'موعد الولادة المتوقع',
              controller: _dueDate,
              onTap: () => _pickDate(_dueDate),
              validator: _dueDateValidator,
            ),
            const SizedBox(height: 16),
            NumuwTextField(
              controller: _country,
              label: 'الدولة',
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'اختاري الدولة.'
                  : null,
            ),
            const SizedBox(height: 17),
            _BooleanChoice(
              title: 'هل هو حملك الأول؟',
              value: _firstChild,
              onChanged: (value) => setState(() => _firstChild = value),
            ),
          ] else ...[
            NumuwTextField(
              controller: _name,
              label: 'اسم الطفل',
              hint: 'اسم طفلك',
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'اسم الطفل مطلوب.'
                  : null,
            ),
            const SizedBox(height: 16),
            _DateField(
              label: 'تاريخ الميلاد',
              controller: _birthDate,
              onTap: () => _pickDate(_birthDate),
              validator: _birthDateValidator,
            ),
            const SizedBox(height: 17),
            Text(
              'النوع (اختياري)',
              style: TextStyle(
                color: numuwTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: ChoicePill(
                    label: 'ولد',
                    selected: _gender == 'male',
                    onTap: () => setState(() => _gender = 'male'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoicePill(
                    label: 'بنت',
                    selected: _gender == 'female',
                    onTap: () => setState(() => _gender = 'female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ChoicePill(
              label: 'لا أريد التحديد',
              selected: _gender == 'unspecified',
              onTap: () => setState(() => _gender = 'unspecified'),
            ),
            const SizedBox(height: 16),
            NumuwTextField(
              controller: _country,
              label: 'الدولة',
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'اختاري الدولة.'
                  : null,
            ),
            const SizedBox(height: 17),
            Text(
              'نوع الرضاعة',
              style: TextStyle(
                color: numuwTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const {
                'breast': 'رضاعة طبيعية',
                'formula': 'رضاعة صناعية',
                'mixed': 'رضاعة مختلطة',
              }.entries
                  .map(
                    (entry) => ChoicePill(
                      label: entry.value,
                      selected: _feeding == entry.key,
                      onTap: () => setState(() => _feeding = entry.key),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 17),
            _BooleanChoice(
              title: 'هل هو طفلك الأول؟',
              value: _firstChild,
              onChanged: (value) => setState(() => _firstChild = value),
            ),
          ],
        ],
      );

  Widget _sharingStep() => Column(
        key: const ValueKey('sharing'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هل تريدين مشاركة الحساب مع الأب؟',
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 27,
              height: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنكما معًا تسجيل يوم طفلك ومتابعة المهام والمواعيد.',
            style: TextStyle(
              color: numuwSecondaryTextColor(),
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          _BigChoice(
            active: _share == 'yes',
            title: 'نعم، أرسل له دعوة',
            description: 'يمكنك إرسال رابط الدعوة بعد إنهاء الإعداد.',
            onTap: () => setState(() => _share = 'yes'),
          ),
          const SizedBox(height: 14),
          _BigChoice(
            active: _share == 'no',
            title: 'ليس الآن',
            description: 'يمكنك إضافة أفراد الأسرة لاحقًا من الإعدادات.',
            onTap: () => setState(() => _share = 'no'),
          ),
        ],
      );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخطوة $step من 3',
            style: TextStyle(
              color: numuwAccentColor(),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 6,
                  margin: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index < step
                        ? numuwAccentColor()
                        : numuwBorderColor(),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

class _BigChoice extends StatelessWidget {
  const _BigChoice({
    this.icon,
    required this.active,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData? icon;
  final bool active;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(18),
            decoration: BoxDecoration(
              color: active
                  ? numuwAccentColor().withValues(alpha: .12)
                  : numuwSurfaceColor(),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active ? numuwAccentColor() : numuwBorderColor(),
                width: active ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: active
                          ? numuwAccentColor()
                          : numuwAccentColor().withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: active
                          ? (numuwNightMode()
                                ? const Color(0xFF0F1923)
                                : Colors.white)
                          : numuwAccentColor(),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: numuwSecondaryTextColor(),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (active)
                  Icon(Icons.check_circle_rounded, color: numuwAccentColor()),
              ],
            ),
          ),
        ),
      );
}

class _BooleanChoice extends StatelessWidget {
  const _BooleanChoice({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: numuwTextColor(),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: ChoicePill(
                  label: 'نعم',
                  selected: value,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoicePill(
                  label: 'لا',
                  selected: !value,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: numuwTextColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            validator: validator,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: 'YYYY-MM-DD',
              suffixIcon: Icon(Icons.calendar_month_outlined),
            ),
          ),
        ],
      );
}

String? _birthDateValidator(String? value) {
  final date = _parseDate(value);
  if (date == null) {
    return 'اكتبي تاريخ الميلاد بصيغة YYYY-MM-DD.';
  }
  if (date.isAfter(DateTime.now())) {
    return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل.';
  }
  return null;
}

String? _dueDateValidator(String? value) => _parseDate(value) == null
    ? 'موعد الولادة المتوقع مطلوب بصيغة YYYY-MM-DD.'
    : null;

DateTime? _parseDate(String? value) {
  final text = value?.trim() ?? '';
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
