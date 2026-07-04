import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
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
    setState(() => _step = (_step + 1).clamp(0, 2));
  }

  void _back() => setState(() => _step = (_step - 1).clamp(0, 2));

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
        padding: const EdgeInsetsDirectional.fromSTEB(24, 64, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Progress(step: _step),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: NumuwMotion.screen,
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
        'Ù‡Ù„ Ù…Ø§ Ø²Ø§Ù„Øª Ø§Ù„Ø£Ù… Ø­Ø§Ù…Ù„\nØ£Ù… Ø§Ù„Ø·ÙÙ„ ÙˆÙÙ„Ø¯ØŸ',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: numuwTextColor(),
          fontSize: 24,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Ø§Ø®ØªØ§Ø±ÙŠ Ø§Ù„Ø®ÙŠØ§Ø± Ø§Ù„Ù…Ù†Ø§Ø³Ø¨ Ù„ÙƒÙ',
        style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 14),
      ),
      const SizedBox(height: 28),
      _StageCard(
        selected: _stage == 'born',
        icon: 'ðŸ‘¶',
        title: 'Ø§Ù„Ø·ÙÙ„ ÙˆÙÙ„Ø¯',
        subtitle: 'Ø³Ø¬Ù‘Ù„ÙŠ Ø£Ø­Ø¯Ø§Ø« ÙŠÙˆÙ…ÙŠØ© Ù…Ù† Ø§Ù„Ø¢Ù†',
        onTap: () => setState(() => _stage = 'born'),
      ),
      const SizedBox(height: 14),
      _StageCard(
        selected: _stage == 'pregnancy',
        icon: 'ðŸ¤°',
        title: 'Ø§Ù„Ø£Ù… Ø­Ø§Ù…Ù„',
        subtitle: 'ØªØ§Ø¨Ø¹ÙŠ Ù…ÙˆØ¹Ø¯ Ø§Ù„ÙˆÙ„Ø§Ø¯Ø© ÙˆØ§Ù„Ø§Ø³ØªØ¹Ø¯Ø§Ø¯Ø§Øª',
        onTap: () => setState(() => _stage = 'pregnancy'),
      ),
      const SizedBox(height: 28),
      NumuwPrimaryButton(label: 'Ø§Ù„ØªØ§Ù„ÙŠ â†', onPressed: _next),
    ],
  );

  Widget _detailsStep() => Column(
    key: const ValueKey('details'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Ø£Ø®Ø¨Ø±ÙŠÙ†ÙŠ Ø¹Ù† Ø·ÙÙ„ÙƒÙ ðŸ’›',
        style: TextStyle(
          color: numuwTextColor(),
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 24),
      NumuwTextField(
        controller: _name,
        label: 'Ø§Ø³Ù… Ø§Ù„Ø·ÙÙ„',
        validator: (v) =>
            (v ?? '').trim().isEmpty ? 'Ø§Ø³Ù… Ø§Ù„Ø·ÙÙ„ Ù…Ø·Ù„ÙˆØ¨.' : null,
      ),
      const SizedBox(height: 14),
      if (_stage == 'born')
        NumuwTextField(
          controller: _birthDate,
          label: 'ØªØ§Ø±ÙŠØ® Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯',
          hint: 'YYYY-MM-DD',
          keyboardType: TextInputType.datetime,
          textDirection: TextDirection.ltr,
          validator: _birthDateValidator,
        )
      else
        NumuwTextField(
          controller: _dueDate,
          label: 'Ù…ÙˆØ¹Ø¯ Ø§Ù„ÙˆÙ„Ø§Ø¯Ø© Ø§Ù„Ù…ØªÙˆÙ‚Ø¹',
          hint: 'YYYY-MM-DD',
          keyboardType: TextInputType.datetime,
          textDirection: TextDirection.ltr,
          validator: _dueDateValidator,
        ),
      const SizedBox(height: 18),
      _Label('Ø§Ù„Ø¬Ù†Ø³'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: ChoicePill(
              label: 'Ø¨Ù†Øª',
              icon: 'ðŸ‘§',
              selected: _gender == 'female',
              onTap: () => setState(() => _gender = 'female'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ChoicePill(
              label: 'ÙˆÙ„Ø¯',
              icon: 'ðŸ‘¦',
              selected: _gender == 'male',
              onTap: () => setState(() => _gender = 'male'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ChoicePill(
        label: 'ØºÙŠØ± Ù…Ø­Ø¯Ø¯',
        selected: _gender == 'unspecified',
        onTap: () => setState(() => _gender = 'unspecified'),
      ),
      const SizedBox(height: 18),
      _Label('Ù†ÙˆØ¹ Ø§Ù„Ø±Ø¶Ø§Ø¹Ø©'),
      const SizedBox(height: 8),
      SegmentedSelector(
        value: _feeding,
        items: const {
          'breast': 'Ø·Ø¨ÙŠØ¹ÙŠØ©',
          'formula': 'ØµÙ†Ø§Ø¹ÙŠØ©',
          'mixed': 'Ù…Ø®ØªÙ„Ø·Ø©',
          'not_set': 'ØºÙŠØ± Ù…Ø­Ø¯Ø¯',
        },
        onChanged: (value) => setState(() => _feeding = value),
      ),
      const SizedBox(height: 24),
      NumuwPrimaryButton(label: 'Ø§Ù„ØªØ§Ù„ÙŠ â†', onPressed: _next),
      const SizedBox(height: 10),
      NumuwSecondaryButton(label: 'Ø±Ø¬ÙˆØ¹', onPressed: _back),
    ],
  );

  Widget _optionalStep() => Column(
    key: const ValueKey('optional'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'ØªÙØ§ØµÙŠÙ„ Ø¥Ø¶Ø§ÙÙŠØ©',
        style: TextStyle(
          color: numuwTextColor(),
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'ÙŠÙ…ÙƒÙ†ÙƒÙ ØªØ®Ø·ÙŠÙ‡Ø§ ÙˆØ¥Ø¶Ø§ÙØªÙ‡Ø§ Ù„Ø§Ø­Ù‚Ø§Ù‹',
        style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 14),
      ),
      const SizedBox(height: 24),
      _Label('ÙØµÙŠÙ„Ø© Ø§Ù„Ø¯Ù…'),
      const SizedBox(height: 8),
      SegmentedSelector(
        value: _bloodType.text.isEmpty ? 'none' : _bloodType.text,
        items: const {
          'none': 'ØºÙŠØ± Ù…Ø­Ø¯Ø¯',
          'A+': 'A+',
          'A-': 'A-',
          'B+': 'B+',
          'B-': 'B-',
          'O+': 'O+',
          'O-': 'O-',
          'AB+': 'AB+',
          'AB-': 'AB-',
        },
        onChanged: (value) =>
            setState(() => _bloodType.text = value == 'none' ? '' : value),
      ),
      const SizedBox(height: 16),
      NumuwNumberField(
        controller: _weight,
        label: 'ÙˆØ²Ù† Ø§Ù„ÙˆÙ„Ø§Ø¯Ø© Ø§Ø®ØªÙŠØ§Ø±ÙŠ',
        hint: '3.2',
        validator: _weightValidator,
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(22),
        decoration: BoxDecoration(
          color: numuwSurfaceColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: numuwBorderColor(),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          children: [
            const Text('ðŸ“¸', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              'ØµÙˆØ±Ø© Ø·ÙÙ„ÙƒÙ',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Ø§Ø®ØªÙŠØ§Ø±ÙŠ',
              style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      NumuwPrimaryButton(
        label: 'Ù„Ù†Ø¨Ø¯Ø£! ðŸŽ‰',
        loading: _loading,
        onPressed: _save,
      ),
      const SizedBox(height: 10),
      NumuwSecondaryButton(
        label: 'ØªØ®Ø·ÙŠ Ø§Ù„ØªÙØ§ØµÙŠÙ„ Ø§Ù„Ø§Ø®ØªÙŠØ§Ø±ÙŠØ©',
        onPressed: _loading ? null : _save,
      ),
      const SizedBox(height: 10),
      TextButton(onPressed: _back, child: const Text('Ø±Ø¬ÙˆØ¹')),
    ],
  );
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
        NumuwPlantProgress(
          progress: progress,
          label: 'Ø§Ù„Ø®Ø·ÙˆØ© ${step + 1} Ù…Ù† 3',
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 6),
                decoration: BoxDecoration(
                  color: index <= step
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
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: onTap,
    child: AnimatedContainer(
      duration: NumuwMotion.fast,
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: selected ? numuwAccentColor() : numuwSurfaceColor(),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? numuwAccentColor() : numuwBorderColor(),
          width: 2.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: .2)
                  : AppColors.mintLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : numuwTextColor(),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: .82)
                        : numuwSecondaryTextColor(),
                    fontSize: 13,
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

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.start,
    style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w900),
  );
}

String? _birthDateValidator(String? value) {
  final date = _parseDate(value);
  if (date == null)
    return 'Ø§ÙƒØªØ¨ÙŠ ØªØ§Ø±ÙŠØ® Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯ Ø¨ØµÙŠØºØ© YYYY-MM-DD.';
  if (date.isAfter(DateTime.now()))
    return 'ØªØ§Ø±ÙŠØ® Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯ Ù„Ø§ ÙŠÙ…ÙƒÙ† Ø£Ù† ÙŠÙƒÙˆÙ† ÙÙŠ Ø§Ù„Ù…Ø³ØªÙ‚Ø¨Ù„.';
  return null;
}

String? _dueDateValidator(String? value) => _parseDate(value) == null
    ? 'Ù…ÙˆØ¹Ø¯ Ø§Ù„ÙˆÙ„Ø§Ø¯Ø© Ø§Ù„Ù…ØªÙˆÙ‚Ø¹ Ù…Ø·Ù„ÙˆØ¨ Ø¨ØµÙŠØºØ© YYYY-MM-DD.'
    : null;

String? _weightValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final n = _parseDouble(text);
  if (n == null || n <= 0)
    return 'Ø§ÙƒØªØ¨ÙŠ ÙˆØ²Ù†Ù‹Ø§ ØµØ­ÙŠØ­Ù‹Ø§ Ø¨Ø§Ù„ÙƒÙŠÙ„ÙˆØ¬Ø±Ø§Ù….';
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
