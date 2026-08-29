import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../design/numuw_motion_widgets.dart';
import '../../design/numuw_organic_icons.dart';
import '../../repositories/child_repository.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/numuw_components.dart';

class ChildOnboardingScreen extends StatefulWidget {
  const ChildOnboardingScreen({super.key, required this.onSaved});

  final Future<void> Function() onSaved;

  @override
  State<ChildOnboardingScreen> createState() => _ChildOnboardingScreenState();
}

class _ChildOnboardingScreenState extends State<ChildOnboardingScreen> {
  final _repo = ChildRepository();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _birthDate = TextEditingController();
  final _dueDate = TextEditingController();
  final _bloodType = TextEditingController();
  final _weight = TextEditingController();

  int _step = 0;
  String _stage = 'born';
  String _gender = 'unspecified';
  String _feeding = 'not_set';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _birthDate.dispose();
    _dueDate.dispose();
    _bloodType.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1 && !_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _step = (_step + 1).clamp(0, 2);
    });
  }

  void _back() {
    if (_loading) return;
    setState(() {
      _error = null;
      _step = (_step - 1).clamp(0, 2);
    });
  }

  Future<void> _save() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _step = 1);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _repo.createChild(
        name: _name.text.trim(),
        stage: _stage,
        birthDate: _stage == 'born' ? _parseDate(_birthDate.text) : null,
        dueDate: _stage == 'pregnancy' ? _parseDate(_dueDate.text) : null,
        gender: _gender,
        feedingType: _feeding,
        bloodType: _bloodType.text.trim(),
        birthWeightKg: _parseDouble(_weight.text),
      );
      await widget.onSaved();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Scaffold(
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 56, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Progress(step: _step),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : NumuwMotionSpec.enter,
                switchInCurve: NumuwMotionSpec.standard,
                switchOutCurve: NumuwMotionSpec.standard,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .025),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: switch (_step) {
                  0 => _stageStep(),
                  1 => _detailsStep(),
                  _ => _optionalStep(),
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                ErrorMessageCard(message: _error!),
              ],
            ],
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
        'أين أنتم الآن في الرحلة؟',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: numuwTextColor(),
          fontSize: 25,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        'اختاري المرحلة المناسبة لنجهز نمو بما يناسبكِ.',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: numuwSecondaryTextColor(),
          fontSize: 14,
          height: 1.55,
        ),
      ),
      const SizedBox(height: 26),
      _OrganicChoiceCard(
        selected: _stage == 'born',
        icon: NumuwOrganicIconName.newborn,
        semanticLabel: 'الطفل وُلد',
        title: 'الطفل وُلد',
        subtitle: 'سجّلي الرضاعة والنوم والحفاضات والنمو يومًا بيوم.',
        onTap: () => setState(() => _stage = 'born'),
      ),
      const SizedBox(height: 14),
      _OrganicChoiceCard(
        selected: _stage == 'pregnancy',
        icon: NumuwOrganicIconName.pregnancy,
        semanticLabel: 'الأم حامل',
        title: 'الأم حامل',
        subtitle: 'تابعي موعد الولادة والاستعدادات والأسئلة المهمة للطبيب.',
        onTap: () => setState(() => _stage = 'pregnancy'),
      ),
      const SizedBox(height: 28),
      NumuwPrimaryButton(label: 'التالي', onPressed: _next),
    ],
  );

  Widget _detailsStep() => Column(
    key: const ValueKey('details'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwOrganicIcon(
            _stage == 'pregnancy'
                ? NumuwOrganicIconName.pregnancy
                : NumuwOrganicIconName.newborn,
            size: 42,
            semanticLabel: _stage == 'pregnancy' ? 'الحمل' : 'الطفل',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stage == 'pregnancy'
                      ? 'أخبريني عن رحلة الحمل'
                      : 'أخبريني عن طفلكِ',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'يمكنكِ تعديل هذه البيانات لاحقًا من ملف الطفل.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      NumuwTextField(
        controller: _name,
        label: _stage == 'pregnancy' ? 'اسم الطفل المتوقع' : 'اسم الطفل',
        validator: (value) => (value ?? '').trim().isEmpty
            ? 'اسم الطفل مطلوب.'
            : (value ?? '').trim().length > 80
            ? 'الاسم طويل جدًا.'
            : null,
      ),
      const SizedBox(height: 14),
      if (_stage == 'born')
        NumuwTextField(
          controller: _birthDate,
          label: 'تاريخ الميلاد',
          hint: 'YYYY-MM-DD',
          keyboardType: TextInputType.datetime,
          textDirection: TextDirection.ltr,
          validator: _birthDateValidator,
        )
      else
        NumuwTextField(
          controller: _dueDate,
          label: 'موعد الولادة المتوقع',
          hint: 'YYYY-MM-DD',
          keyboardType: TextInputType.datetime,
          textDirection: TextDirection.ltr,
          validator: _dueDateValidator,
        ),
      const SizedBox(height: 20),
      const _Label('الجنس'),
      const SizedBox(height: 9),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _CompactChoice(
            label: 'بنت',
            selected: _gender == 'female',
            icon: NumuwOrganicIconName.favorite,
            onTap: () => setState(() => _gender = 'female'),
          ),
          _CompactChoice(
            label: 'ولد',
            selected: _gender == 'male',
            icon: NumuwOrganicIconName.newborn,
            onTap: () => setState(() => _gender = 'male'),
          ),
          _CompactChoice(
            label: 'غير محدد',
            selected: _gender == 'unspecified',
            icon: NumuwOrganicIconName.help,
            onTap: () => setState(() => _gender = 'unspecified'),
          ),
        ],
      ),
      if (_stage == 'born') ...[
        const SizedBox(height: 20),
        const _Label('نوع الرضاعة'),
        const SizedBox(height: 9),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CompactChoice(
              label: 'طبيعية',
              selected: _feeding == 'breast',
              icon: NumuwOrganicIconName.breastfeeding,
              onTap: () => setState(() => _feeding = 'breast'),
            ),
            _CompactChoice(
              label: 'صناعية',
              selected: _feeding == 'formula',
              icon: NumuwOrganicIconName.bottle,
              onTap: () => setState(() => _feeding = 'formula'),
            ),
            _CompactChoice(
              label: 'مختلطة',
              selected: _feeding == 'mixed',
              icon: NumuwOrganicIconName.nutrition,
              onTap: () => setState(() => _feeding = 'mixed'),
            ),
            _CompactChoice(
              label: 'غير محدد',
              selected: _feeding == 'not_set',
              icon: NumuwOrganicIconName.help,
              onTap: () => setState(() => _feeding = 'not_set'),
            ),
          ],
        ),
      ],
      const SizedBox(height: 26),
      NumuwPrimaryButton(label: 'التالي', onPressed: _next),
      const SizedBox(height: 10),
      NumuwSecondaryButton(label: 'رجوع', onPressed: _back),
    ],
  );

  Widget _optionalStep() => Column(
    key: const ValueKey('optional'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const NumuwOrganicIcon(
            NumuwOrganicIconName.documents,
            size: 42,
            semanticLabel: 'تفاصيل إضافية',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تفاصيل إضافية',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'هذه البيانات اختيارية ويمكنكِ إضافتها أو تعديلها لاحقًا.',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: numuwSecondaryTextColor(),
          fontSize: 14,
          height: 1.55,
        ),
      ),
      if (_stage == 'born') ...[
        const SizedBox(height: 24),
        const _Label('فصيلة الدم'),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(
          initialValue: _bloodType.text.isEmpty ? 'none' : _bloodType.text,
          decoration: const InputDecoration(labelText: 'فصيلة الدم'),
          items: const {
            'none': 'غير محدد',
            'A+': 'A+',
            'A-': 'A-',
            'B+': 'B+',
            'B-': 'B-',
            'O+': 'O+',
            'O-': 'O-',
            'AB+': 'AB+',
            'AB-': 'AB-',
          }
              .entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _bloodType.text = value == null || value == 'none' ? '' : value;
            });
          },
        ),
        const SizedBox(height: 16),
        NumuwNumberField(
          controller: _weight,
          label: 'وزن الولادة بالكيلوغرام',
          hint: '3.2',
          validator: _weightValidator,
        ),
      ],
      const SizedBox(height: 18),
      Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(20),
        decoration: BoxDecoration(
          color: numuwSurfaceColor(),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: numuwBorderColor()),
        ),
        child: Row(
          children: [
            const NumuwOrganicIcon(
              NumuwOrganicIconName.camera,
              size: 48,
              semanticLabel: 'صورة الطفل',
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'صورة الطفل',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'يمكن إضافتها لاحقًا من الملف الشخصي.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      NumuwPrimaryButton(
        label: 'ابدئي مع نمو',
        loading: _loading,
        onPressed: _save,
      ),
      const SizedBox(height: 10),
      NumuwSecondaryButton(
        label: 'تخطي التفاصيل الاختيارية',
        onPressed: _loading ? null : _save,
      ),
      const SizedBox(height: 8),
      Center(
        child: TextButton(
          onPressed: _loading ? null : _back,
          child: const Text('رجوع'),
        ),
      ),
    ],
  );

  String? _birthDateValidator(String? value) {
    final date = _parseDate(value ?? '');
    if (date == null) return 'أدخلي تاريخ ميلاد صحيحًا بصيغة YYYY-MM-DD.';
    final today = DateUtils.dateOnly(DateTime.now());
    if (date.isAfter(today)) return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل.';
    if (date.isBefore(DateTime(today.year - 18, today.month, today.day))) {
      return 'راجعي تاريخ الميلاد المدخل.';
    }
    return null;
  }

  String? _dueDateValidator(String? value) {
    final date = _parseDate(value ?? '');
    if (date == null) return 'أدخلي موعدًا صحيحًا بصيغة YYYY-MM-DD.';
    final today = DateUtils.dateOnly(DateTime.now());
    if (date.isBefore(today.subtract(const Duration(days: 21))) ||
        date.isAfter(today.add(const Duration(days: 310)))) {
      return 'راجعي موعد الولادة المتوقع.';
    }
    return null;
  }

  String? _weightValidator(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    final parsed = _parseDouble(value!);
    if (parsed == null) return 'أدخلي وزنًا صحيحًا.';
    if (parsed < 0.3 || parsed > 10) return 'راجعي وزن الولادة المدخل.';
    return null;
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumuwPlantProgress(progress: progress, label: 'الخطوة ${step + 1} من 3'),
        const SizedBox(height: 11),
        Semantics(
          label: 'تقدم الإعداد: الخطوة ${step + 1} من 3',
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
                      ? Duration.zero
                      : NumuwMotionSpec.quick,
                  height: 5,
                  margin: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index <= step ? AppColors.mint : numuwBorderColor(),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrganicChoiceCard extends StatelessWidget {
  const _OrganicChoiceCard({
    required this.selected,
    required this.icon,
    required this.semanticLabel,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final NumuwOrganicIconName icon;
  final String semanticLabel;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    semanticLabel: title,
    onTap: onTap,
    child: AnimatedContainer(
      duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
          ? Duration.zero
          : NumuwMotionSpec.quick,
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        color: selected ? AppColors.mintLight : numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? AppColors.mint : numuwBorderColor(),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          NumuwOrganicIcon(icon, size: 58, semanticLabel: semanticLabel),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedSwitcher(
            duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
                ? Duration.zero
                : NumuwMotionSpec.quick,
            child: selected
                ? const NumuwOrganicIcon(
                    NumuwOrganicIconName.done,
                    key: ValueKey('selected'),
                    size: 28,
                    semanticLabel: 'محدد',
                  )
                : const SizedBox(key: ValueKey('unselected'), width: 28),
          ),
        ],
      ),
    ),
  );
}

class _CompactChoice extends StatelessWidget {
  const _CompactChoice({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final NumuwOrganicIconName icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NumuwPressable(
    semanticLabel: label,
    onTap: onTap,
    child: AnimatedContainer(
      duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
          ? Duration.zero
          : NumuwMotionSpec.quick,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 9, 14, 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.mintLight : numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.mint : numuwBorderColor(),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumuwOrganicIcon(icon, size: 28),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.start,
    style: TextStyle(
      color: numuwTextColor(),
      fontSize: 13,
      fontWeight: FontWeight.w800,
    ),
  );
}

DateTime? _parseDate(String value) {
  final normalized = value
      .trim()
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
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) return null;
  return DateUtils.dateOnly(parsed);
}

double? _parseDouble(String value) => double.tryParse(
  value
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
      .replaceAll('٩', '9'),
);
