import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../models/care_event.dart';
import '../repositories/care_event_repository.dart';
import '../state/child_session.dart';
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
  String _type = 'feeding';
  String _side = 'both';
  String _feedingMethod = 'breast';
  bool _burped = false;
  bool _vomited = false;
  bool _wet = true;
  bool _dirty = false;
  bool _loading = false;
  String? _message;
  String? _error;
  DateTime? _activeFeedingStart;
  DateTime? _activeSleepStart;
  Future<List<CareEvent>>? _recent;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
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

  Future<void> _save() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    try {
      final now = DateTime.now();
      DateTime started = now;
      DateTime? ended;
      if (_type == 'feeding' && _activeFeedingStart != null) {
        started = _activeFeedingStart!;
        ended = now;
      }
      if (_type == 'sleep' && _activeSleepStart != null) {
        started = _activeSleepStart!;
        ended = now;
      }
      if (ended != null && ended.isBefore(started))
        throw const AppException('لا يمكن حفظ مدة سالبة.');
      await _repo.insert(
        childId: child.id,
        eventType: _type,
        startedAt: started,
        endedAt: ended,
        side: _type == 'feeding' ? _side : null,
        feedingMethod: _type == 'feeding' ? _feedingMethod : null,
        amountMl: _type == 'feeding' ? _double(_amount.text) : null,
        burped: _type == 'feeding' ? _burped : null,
        vomited: _type == 'feeding' ? _vomited : null,
        diaperWet: _type == 'diaper' ? _wet : null,
        diaperDirty: _type == 'diaper' ? _dirty : null,
        temperatureC: _type == 'temperature' ? _double(_temp.text) : null,
        medicineName: _type == 'medicine' ? _food.text : null,
        medicineDose: _type == 'medicine' ? _dose.text : null,
        notes: _buildNotes(),
        metadata: _metadata(),
      );
      _clearAfterSave();
      setState(() {
        _message = 'تم حفظ التسجيل بنجاح.';
        _reload();
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _buildNotes() {
    final note = _notes.text.trim();
    if (_type == 'food') {
      final food = _food.text.trim();
      if (food.isEmpty) return note.isEmpty ? null : note;
      return note.isEmpty ? food : '$food - $note';
    }
    return note.isEmpty ? null : note;
  }

  Map<String, dynamic>? _metadata() {
    if (_type == 'food')
      return {'food_name': _food.text.trim(), 'description': _dose.text.trim()};
    if (_type == 'diaper') return {'details': _dose.text.trim()};
    return null;
  }

  void _clearAfterSave() {
    _notes.clear();
    _amount.clear();
    _food.clear();
    _dose.clear();
    _temp.clear();
    if (_type == 'feeding') _activeFeedingStart = null;
    if (_type == 'sleep') _activeSleepStart = null;
  }

  double? _double(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null)
      return const Scaffold(
        body: AppPage(
          child: EmptyState(message: 'اختاري طفلًا أولًا للتسجيل.'),
        ),
      );
    return Scaffold(
      body: AppPage(
        child: Column(
          children: [
            AppHeader(
              title: 'التسجيل',
              subtitle: 'سجّلي أحداث ${child.name} اليومية',
            ),
            const SizedBox(height: 22),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypeChips(
                    value: _type,
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  const SizedBox(height: 16),
                  _timerControls(),
                  _fields(),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    _Info(_message!, AppColors.mint, AppColors.mintLight),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _Info(_error!, AppColors.peach, AppColors.peachLight),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ التسجيل'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle(
              title: 'آخر التسجيلات',
              icon: Icons.history_rounded,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<CareEvent>>(
              future: _recent,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done)
                  return const SoftCard(
                    child: Center(child: CircularProgressIndicator()),
                  );
                final events = snapshot.data ?? const <CareEvent>[];
                if (events.isEmpty)
                  return const EmptyState(message: 'لا توجد تسجيلات بعد.');
                return SoftCard(
                  child: Column(
                    children: events
                        .map(
                          (e) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              ArabicFormatters.eventType(e.eventType),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              '${ArabicFormatters.time(e.startedAt)}${e.notes == null ? '' : ' · ${e.notes}'}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerControls() {
    if (_type == 'feeding')
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _activeFeedingStart == null
                  ? () => setState(() => _activeFeedingStart = DateTime.now())
                  : null,
              child: const Text('بدء الرضاعة'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _activeFeedingStart != null ? _save : null,
              child: const Text('إيقاف وحفظ'),
            ),
          ),
        ],
      );
    if (_type == 'sleep')
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _activeSleepStart == null
                  ? () => setState(() => _activeSleepStart = DateTime.now())
                  : null,
              child: const Text('بدء النوم'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _activeSleepStart != null ? _save : null,
              child: const Text('استيقظ وحفظ'),
            ),
          ),
        ],
      );
    return const SizedBox.shrink();
  }

  Widget _fields() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (_type == 'feeding') ...[
        const SizedBox(height: 12),
        _Choice(
          value: _side,
          items: const {'right': 'يمين', 'left': 'يسار', 'both': 'كلاهما'},
          onChanged: (v) => setState(() => _side = v),
        ),
        const SizedBox(height: 8),
        _Choice(
          value: _feedingMethod,
          items: const {
            'breast': 'طبيعية',
            'bottle': 'زجاجة',
            'formula': 'صناعية',
            'mixed': 'مختلطة',
            'pumping': 'شفط',
          },
          onChanged: (v) => setState(() => _feedingMethod = v),
        ),
        _Field(_amount, 'الكمية بالمل اختياري', TextInputType.number),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _burped,
          onChanged: (v) => setState(() => _burped = v),
          title: const Text('تجشأ'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _vomited,
          onChanged: (v) => setState(() => _vomited = v),
          title: const Text('استفرغ'),
        ),
      ],
      if (_type == 'diaper') ...[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _wet,
          onChanged: (v) => setState(() => _wet = v),
          title: const Text('مبللة'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _dirty,
          onChanged: (v) => setState(() => _dirty = v),
          title: const Text('متسخة'),
        ),
        _Field(_dose, 'تفاصيل اختيارية'),
      ],
      if (_type == 'food') ...[
        _Field(_food, 'اسم الطعام'),
        _Field(_dose, 'الكمية أو الوصف'),
      ],
      if (_type == 'medicine') ...[
        _Field(_food, 'اسم الدواء'),
        _Field(_dose, 'الجرعة'),
      ],
      if (_type == 'temperature')
        _Field(_temp, 'درجة الحرارة °C', TextInputType.number),
      const SizedBox(height: 8),
      _Field(_notes, 'ملاحظات اختيارية'),
    ],
  );
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => _Choice(
    value: value,
    items: const {
      'feeding': 'رضاعة',
      'sleep': 'نوم',
      'diaper': 'حفاضة',
      'food': 'طعام',
      'medicine': 'دواء',
      'temperature': 'حرارة',
      'note': 'ملاحظة',
    },
    onChanged: onChanged,
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
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
          (e) => ChoiceChip(
            selected: e.key == value,
            label: Text(e.value),
            selectedColor: AppColors.mintLight,
            onSelected: (_) => onChanged(e.key),
          ),
        )
        .toList(),
  );
}

class _Field extends StatelessWidget {
  const _Field(this.controller, this.label, [this.keyboardType]);
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.start,
      textDirection: keyboardType == TextInputType.number
          ? TextDirection.ltr
          : TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.mintLight.withValues(alpha: .25),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.text, this.color, this.bg);
  final String text;
  final Color color;
  final Color bg;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w800),
    ),
  );
}
