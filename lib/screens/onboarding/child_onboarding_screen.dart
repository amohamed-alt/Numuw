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
            children: [
              const AppHeader(
                title: 'بيانات الطفل',
                subtitle: 'أضيفي أول ملف لطفلك لبدء المتابعة',
                showNotification: false,
              ),
              const SizedBox(height: 24),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'هل ما زالت الأم حامل أم الطفل وُلد؟',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Chips(
                      value: _stage,
                      items: const {
                        'born': 'الطفل وُلد',
                        'pregnancy': 'الأم حامل',
                      },
                      onChanged: (v) => setState(() => _stage = v),
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      controller: _name,
                      label: 'اسم الطفل',
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'اسم الطفل مطلوب.' : null,
                    ),
                    const SizedBox(height: 12),
                    if (_stage == 'born')
                      _Field(
                        controller: _birthDate,
                        label: 'تاريخ الميلاد',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.cake_outlined,
                        textDirection: TextDirection.ltr,
                        validator: _birthDateValidator,
                      )
                    else
                      _Field(
                        controller: _dueDate,
                        label: 'موعد الولادة المتوقع',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.event_available_outlined,
                        textDirection: TextDirection.ltr,
                        validator: _dueDateValidator,
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'الجنس',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    _Chips(
                      value: _gender,
                      items: const {
                        'male': 'ذكر',
                        'female': 'أنثى',
                        'unspecified': 'غير محدد',
                      },
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'نوع الرضاعة',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    _Chips(
                      value: _feeding,
                      items: const {
                        'breast': 'طبيعية',
                        'formula': 'صناعية',
                        'mixed': 'مختلطة',
                        'not_set': 'غير محدد',
                      },
                      onChanged: (v) => setState(() => _feeding = v),
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      controller: _bloodType,
                      label: 'فصيلة الدم اختياري',
                      icon: Icons.water_drop_outlined,
                    ),
                    const SizedBox(height: 12),
                    _Field(
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
                      _Message(_error!),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _loading ? null : _save,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('حفظ وبدء المتابعة'),
                      ),
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

String? _birthDateValidator(String? value) {
  final date = _parseDate(value);
  if (date == null) return 'اكتبي تاريخ الميلاد بصيغة YYYY-MM-DD.';
  if (date.isAfter(DateTime.now()))
    return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل.';
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

class _Chips extends StatelessWidget {
  const _Chips({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items.entries
        .map(
          (entry) => ChoiceChip(
            selected: entry.key == value,
            label: Text(entry.value),
            selectedColor: AppColors.mintLight,
            side: BorderSide(
              color: entry.key == value ? AppColors.mint : AppColors.border,
            ),
            onSelected: (_) => onChanged(entry.key),
          ),
        )
        .toList(),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
    this.textDirection,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextDirection? textDirection;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    textAlign: TextAlign.start,
    textDirection: textDirection,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.mint),
      filled: true,
      fillColor: AppColors.mintLight.withValues(alpha: 0.35),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.peachLight,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.peach,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
