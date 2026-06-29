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
    final validation = _validate();
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
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
      if (ended != null && ended.isBefore(started)) {
        throw const AppException('لا يمكن حفظ مدة سالبة.');
      }
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

  String? _validate() {
    if (_type == 'temperature') {
      final value = _double(_temp.text);
      if (value == null || value < 30 || value > 45) {
        return 'اكتبي درجة حرارة صحيحة بين 30 و45.';
      }
    }
    if (_type == 'medicine' && _food.text.trim().isEmpty) {
      return 'اكتبي اسم الدواء.';
    }
    if (_type == 'food' && _food.text.trim().isEmpty) {
      return 'اكتبي اسم الطعام.';
    }
    if (_type == 'note' && _notes.text.trim().isEmpty) {
      return 'اكتبي الملاحظة أولًا.';
    }
    return null;
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

  Map<String, dynamic> _metadata() {
    if (_type == 'food') {
      return {'food_name': _food.text.trim(), 'description': _dose.text.trim()};
    }
    if (_type == 'diaper') return {'details': _dose.text.trim()};
    return <String, dynamic>{};
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
    if (child == null) {
      return const Scaffold(
        body: AppPage(
          child: EmptyState(message: 'اختاري طفلًا أولًا للتسجيل.'),
        ),
      );
    }
    return Scaffold(
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'تسجيل سريع ✏️',
              subtitle: 'سجّلي أحداث ${child.name} اليومية',
            ),
            const SizedBox(height: 22),
            _CategoryGrid(
              value: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 22),
            SoftCard(
              radius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _typeTitle(_type),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _timerControls(),
                  _fields(),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    InfoBanner(message: _message!),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    InfoBanner(
                      message: _error!,
                      color: AppColors.danger,
                      background: AppColors.peachLight,
                      icon: Icons.error_outline_rounded,
                    ),
                  ],
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _saveLabel(),
                    loading: _loading,
                    onPressed: _save,
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
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SoftCard(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final events = snapshot.data ?? const <CareEvent>[];
                if (events.isEmpty) {
                  return const EmptyState(message: 'لا توجد تسجيلات بعد.');
                }
                return SoftCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: events.map(_eventTile).toList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _saveLabel() {
    if (_type == 'feeding' && _activeFeedingStart != null)
      return 'إيقاف وحفظ الرضاعة';
    if (_type == 'sleep' && _activeSleepStart != null)
      return 'استيقظ وحفظ النوم';
    return 'حفظ التسجيل';
  }

  Widget _timerControls() {
    if (_type == 'feeding') {
      return _TimerCard(
        color: AppColors.mint,
        active: _activeFeedingStart != null,
        title: _activeFeedingStart == null
            ? 'لا توجد رضعة نشطة'
            : 'الرضاعة نشطة الآن',
        onStart: _activeFeedingStart == null
            ? () => setState(() => _activeFeedingStart = DateTime.now())
            : null,
        onStop: _activeFeedingStart != null ? _save : null,
        startLabel: 'بدء الرضاعة',
        stopLabel: 'إيقاف وحفظ',
      );
    }
    if (_type == 'sleep') {
      return _TimerCard(
        color: AppColors.purple,
        active: _activeSleepStart != null,
        title: _activeSleepStart == null
            ? 'لا توجد نومة نشطة'
            : 'النوم نشط الآن',
        onStart: _activeSleepStart == null
            ? () => setState(() => _activeSleepStart = DateTime.now())
            : null,
        onStop: _activeSleepStart != null ? _save : null,
        startLabel: 'بدء النوم',
        stopLabel: 'استيقظ وحفظ',
      );
    }
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        AppTextField(
          controller: _amount,
          label: 'كمية الحليب (مل) اختياري',
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _burped,
          onChanged: (v) => setState(() => _burped = v),
          title: const Text('تجشّأ'),
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
        AppTextField(controller: _dose, label: 'تفاصيل اختيارية'),
      ],
      if (_type == 'food') ...[
        AppTextField(controller: _food, label: 'اسم الطعام'),
        const SizedBox(height: 10),
        AppTextField(controller: _dose, label: 'الكمية أو الوصف'),
      ],
      if (_type == 'medicine') ...[
        AppTextField(controller: _food, label: 'اسم الدواء'),
        const SizedBox(height: 10),
        AppTextField(controller: _dose, label: 'الجرعة'),
      ],
      if (_type == 'temperature')
        AppTextField(
          controller: _temp,
          label: 'درجة الحرارة °C',
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
      const SizedBox(height: 10),
      AppTextField(
        controller: _notes,
        label: 'ملاحظات اختيارية',
        minLines: 2,
        maxLines: 4,
      ),
    ],
  );

  Widget _eventTile(CareEvent event) => ListTile(
    contentPadding: const EdgeInsetsDirectional.fromSTEB(15, 8, 15, 8),
    leading: IconBadge(
      icon: _typeIcon(event.eventType),
      background: _typeBg(event.eventType),
      size: 36,
    ),
    title: Text(
      ArabicFormatters.eventType(event.eventType),
      textAlign: TextAlign.start,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
    ),
    subtitle: Text(
      '${ArabicFormatters.time(event.startedAt)}${event.notes == null ? '' : ' · ${event.notes}'}',
      textAlign: TextAlign.start,
      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
    ),
  );
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      _Category(
        'feeding',
        'رضاعة',
        '🍼',
        AppColors.peachLight,
        AppColors.peach,
      ),
      _Category('sleep', 'نوم', '🌙', AppColors.mintLight, AppColors.mint),
      _Category(
        'diaper',
        'حفاضة',
        '🧷',
        AppColors.purpleLight,
        AppColors.purple,
      ),
      _Category('food', 'طعام', '🥣', AppColors.yellowLight, AppColors.yellow),
      _Category('medicine', 'دواء', '💊', AppColors.blueLight, AppColors.blue),
      _Category(
        'temperature',
        'حرارة',
        '🌡️',
        AppColors.peachLight,
        AppColors.danger,
      ),
      _Category('note', 'ملاحظة', '📝', AppColors.mintLight, AppColors.mint),
    ];
    return Wrap(
      spacing: 13,
      runSpacing: 14,
      children: items
          .map(
            (item) => SizedBox(
              width: 74,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onChanged(item.type),
                child: Column(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.bg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: value == item.type ? item.color : item.bg,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withValues(alpha: .18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        item.icon,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Category {
  const _Category(this.type, this.label, this.icon, this.bg, this.color);
  final String type;
  final String label;
  final String icon;
  final Color bg;
  final Color color;
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.color,
    required this.active,
    required this.title,
    required this.onStart,
    required this.onStop,
    required this.startLabel,
    required this.stopLabel,
  });

  final Color color;
  final bool active;
  final String title;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final String startLabel;
  final String stopLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? color : AppColors.mutedText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onStart,
                  child: Text(startLabel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onStop,
                  child: Text(stopLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
          (entry) => ChoicePill(
            label: entry.value,
            selected: entry.key == value,
            onTap: () => onChanged(entry.key),
          ),
        )
        .toList(),
  );
}

String _typeTitle(String type) => switch (type) {
  'feeding' => 'تسجيل رضاعة',
  'sleep' => 'تسجيل نوم',
  'diaper' => 'تسجيل حفاضة',
  'food' => 'تسجيل طعام',
  'medicine' => 'تسجيل دواء',
  'temperature' => 'تسجيل حرارة',
  _ => 'تسجيل ملاحظة',
};

String _typeIcon(String type) => switch (type) {
  'feeding' => '🍼',
  'sleep' => '🌙',
  'diaper' => '🧷',
  'food' => '🥣',
  'medicine' => '💊',
  'temperature' => '🌡️',
  _ => '📝',
};

Color _typeBg(String type) => switch (type) {
  'feeding' => AppColors.peachLight,
  'sleep' => AppColors.mintLight,
  'diaper' => AppColors.purpleLight,
  'food' => AppColors.yellowLight,
  'medicine' => AppColors.blueLight,
  'temperature' => AppColors.peachLight,
  _ => AppColors.mintLight,
};
