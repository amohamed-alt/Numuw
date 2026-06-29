import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../repositories/child_repository.dart';
import '../../widgets/app_widgets.dart';

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.createChild(
        name: _name.text,
        stage: _stage,
        birthDate: _stage == 'born' ? _parseDate(_birthDate.text) : null,
        dueDate: _stage == 'pregnancy' ? _parseDate(_dueDate.text) : null,
        gender: _gender,
        feedingType: _feeding,
        bloodType: _bloodType.text,
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
    return Scaffold(
      body: AppPage(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProgressHeader(),
              const SizedBox(height: 28),
              const Text(
                'هل ما زالت الأم حامل أم الطفل وُلد؟',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'أضيفي أول ملف لطفلك لبدء المتابعة',
                textAlign: TextAlign.start,
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 24),
              SoftCard(
                radius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoicePill(
                            label: 'الطفل وُلد',
                            icon: '👶',
                            selected: _stage == 'born',
                            onTap: () => setState(() => _stage = 'born'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoicePill(
                            label: 'الأم حامل',
                            icon: '🤰',
                            selected: _stage == 'pregnancy',
                            onTap: () => setState(() => _stage = 'pregnancy'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _name,
                      label: 'اسم الطفل',
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'اسم الطفل مطلوب.' : null,
                    ),
                    const SizedBox(height: 12),
                    if (_stage == 'born')
                      AppTextField(
                        controller: _birthDate,
                        label: 'تاريخ الميلاد',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.cake_outlined,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.datetime,
                        validator: _birthDateValidator,
                      )
                    else
                      AppTextField(
                        controller: _dueDate,
                        label: 'موعد الولادة المتوقع',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.event_available_outlined,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.datetime,
                        validator: _dueDateValidator,
                      ),
                    const SizedBox(height: 18),
                    const _FieldLabel('الجنس'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoicePill(
                          label: 'ذكر',
                          icon: '👦',
                          selected: _gender == 'male',
                          onTap: () => setState(() => _gender = 'male'),
                        ),
                        ChoicePill(
                          label: 'أنثى',
                          icon: '👧',
                          selected: _gender == 'female',
                          onTap: () => setState(() => _gender = 'female'),
                        ),
                        ChoicePill(
                          label: 'غير محدد',
                          selected: _gender == 'unspecified',
                          onTap: () => setState(() => _gender = 'unspecified'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('نوع الرضاعة'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoicePill(
                          label: 'طبيعية',
                          selected: _feeding == 'breast',
                          onTap: () => setState(() => _feeding = 'breast'),
                        ),
                        ChoicePill(
                          label: 'صناعية',
                          selected: _feeding == 'formula',
                          onTap: () => setState(() => _feeding = 'formula'),
                        ),
                        ChoicePill(
                          label: 'مختلطة',
                          selected: _feeding == 'mixed',
                          onTap: () => setState(() => _feeding = 'mixed'),
                        ),
                        ChoicePill(
                          label: 'غير محدد',
                          selected: _feeding == 'not_set',
                          onTap: () => setState(() => _feeding = 'not_set'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _bloodType,
                      label: 'فصيلة الدم اختياري',
                      icon: Icons.water_drop_outlined,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _weight,
                      label: 'وزن الولادة اختياري',
                      hint: '3.2',
                      icon: Icons.monitor_weight_outlined,
                      textDirection: TextDirection.ltr,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _weightValidator,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      InfoBanner(
                        message: _error!,
                        color: AppColors.danger,
                        background: AppColors.peachLight,
                        icon: Icons.error_outline_rounded,
                      ),
                    ],
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'حفظ وبدء المتابعة',
                      loading: _loading,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 6),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'إضافة طفلك',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.start,
    style: const TextStyle(fontWeight: FontWeight.w900),
  );
}

String? _birthDateValidator(String? value) {
  final date = _parseDate(value);
  if (date == null) return 'اكتبي تاريخ الميلاد بصيغة YYYY-MM-DD.';
  if (date.isAfter(DateTime.now())) {
    return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل.';
  }
  return null;
}

String? _dueDateValidator(String? value) => _parseDate(value) == null
    ? 'موعد الولادة المتوقع مطلوب بصيغة YYYY-MM-DD.'
    : null;

String? _weightValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final n = _parseDouble(text);
  if (n == null || n <= 0) return 'اكتبي وزنًا صحيحًا بالكيلوجرام.';
  return null;
}

DateTime? _parseDate(String? value) {
  final text = value?.trim() ?? '';
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (match == null) return null;
  final y = int.parse(match.group(1)!);
  final m = int.parse(match.group(2)!);
  final d = int.parse(match.group(3)!);
  final date = DateTime(y, m, d);
  return date.year == y && date.month == m && date.day == d ? date : null;
}

double? _parseDouble(String? value) =>
    double.tryParse((value ?? '').trim().replaceAll(',', '.'));
