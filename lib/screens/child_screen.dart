import 'package:flutter/material.dart';

import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../models/child_profile.dart';
import '../models/doctor_question.dart';
import '../models/family_task.dart';
import '../models/growth_measurement.dart';
import '../models/vaccination.dart';
import '../repositories/child_repository.dart';
import '../repositories/doctor_question_repository.dart';
import '../repositories/family_task_repository.dart';
import '../repositories/growth_repository.dart';
import '../repositories/vaccination_repository.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class ChildScreen extends StatefulWidget {
  const ChildScreen({super.key});

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  final _growthRepo = GrowthRepository();
  final _vaccRepo = VaccinationRepository();
  final _taskRepo = FamilyTaskRepository();
  final _questionRepo = DoctorQuestionRepository();
  Future<_ChildData>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child != null)
      _future = _ChildData.load(
        child.id,
        _growthRepo,
        _vaccRepo,
        _taskRepo,
        _questionRepo,
      );
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null)
      return const Scaffold(
        body: AppPage(child: EmptyState(message: 'لا يوجد طفل محدد.')),
      );
    return Scaffold(
      body: AppPage(
        child: Column(
          children: [
            AppHeader(
              title: child.name,
              subtitle: ArabicFormatters.age(child),
              trailing: IconButton(
                onPressed: () => _editChild(child),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 22),
            _ProfileCard(child: child),
            const SizedBox(height: 22),
            FutureBuilder<_ChildData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done)
                  return const SoftCard(
                    child: Center(child: CircularProgressIndicator()),
                  );
                if (snapshot.hasError)
                  return EmptyState(
                    message: readableError(snapshot.error!),
                    icon: Icons.error_outline_rounded,
                  );
                final data = snapshot.data!;
                return Column(
                  children: [
                    SectionTitle(
                      title: 'النمو',
                      icon: Icons.trending_up_rounded,
                      action: TextButton(
                        onPressed: _addGrowth,
                        child: const Text('إضافة'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    data.growth.isEmpty
                        ? const EmptyState(
                            message:
                                'لا توجد قياسات نمو بعد. أضيفي قياسًا عند توفره.',
                          )
                        : _GrowthList(data.growth),
                    const SizedBox(height: 20),
                    SectionTitle(
                      title: 'التطعيمات',
                      icon: Icons.shield_outlined,
                      action: TextButton(
                        onPressed: _addVaccination,
                        child: const Text('إضافة'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    data.vaccinations.isEmpty
                        ? const EmptyState(
                            message:
                                'أضيفي مواعيد التطعيم حسب تعليمات الجهة الصحية أو الطبيب.',
                          )
                        : _VaccinationList(
                            items: data.vaccinations,
                            onStatus: (v, s) async {
                              await _vaccRepo.updateStatus(v.id, s);
                              await _refresh();
                            },
                          ),
                    const SizedBox(height: 20),
                    SectionTitle(
                      title: 'مهام العائلة',
                      icon: Icons.assignment_rounded,
                      action: TextButton(
                        onPressed: _addTask,
                        child: const Text('إضافة'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    data.tasks.isEmpty
                        ? const EmptyState(message: 'لا توجد مهام عائلية بعد.')
                        : _TaskList(
                            items: data.tasks,
                            onChanged: (t, done) async {
                              await _taskRepo.setCompleted(t.id, done);
                              await _refresh();
                            },
                          ),
                    const SizedBox(height: 20),
                    SectionTitle(
                      title: 'أسئلة الطبيب',
                      icon: Icons.help_outline_rounded,
                      action: TextButton(
                        onPressed: _addQuestion,
                        child: const Text('إضافة'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    data.questions.isEmpty
                        ? const EmptyState(message: 'لا توجد أسئلة للطبيب بعد.')
                        : _QuestionList(
                            items: data.questions,
                            onAnswered: (q, done) async {
                              await _questionRepo.setAnswered(q.id, done);
                              await _refresh();
                            },
                          ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editChild(ChildProfile child) async {
    final name = TextEditingController(text: child.name);
    final blood = TextEditingController(text: child.bloodType ?? '');
    final weight = TextEditingController(
      text: child.birthWeightKg?.toString() ?? '',
    );
    final saved = await _showForm('تعديل بيانات الطفل', [
      _DialogField(name, 'الاسم'),
      _DialogField(blood, 'فصيلة الدم'),
      _DialogField(weight, 'وزن الولادة', TextInputType.number),
    ]);
    if (saved != true) return;
    final updated = await ChildRepository().updateChild(
      child.copyWith(
        name: name.text,
        bloodType: blood.text,
        birthWeightKg: double.tryParse(weight.text.replaceAll(',', '.')),
      ),
    );
    ChildSession.instance.selectChild(updated);
    await ChildSession.instance.refresh();
    setState(_load);
  }

  Future<void> _addGrowth() async {
    final w = TextEditingController(),
        h = TextEditingController(),
        head = TextEditingController(),
        source = TextEditingController(),
        notes = TextEditingController();
    if (await _showForm('إضافة قياس نمو', [
          _DialogField(w, 'الوزن كجم', TextInputType.number),
          _DialogField(h, 'الطول سم', TextInputType.number),
          _DialogField(head, 'محيط الرأس سم', TextInputType.number),
          _DialogField(source, 'المصدر'),
          _DialogField(notes, 'ملاحظات'),
        ]) ==
        true) {
      final c = ChildSession.instance.selectedChild!;
      await _growthRepo.add(
        childId: c.id,
        measuredAt: DateTime.now(),
        weightKg: _num(w),
        heightCm: _num(h),
        headCm: _num(head),
        source: source.text,
        notes: notes.text,
      );
      await _refresh();
    }
  }

  Future<void> _addVaccination() async {
    final n = TextEditingController(),
        dose = TextEditingController(),
        provider = TextEditingController(),
        date = TextEditingController();
    if (await _showForm('إضافة تطعيم', [
              _DialogField(n, 'اسم التطعيم'),
              _DialogField(dose, 'الجرعة'),
              _DialogField(date, 'التاريخ YYYY-MM-DD', TextInputType.datetime),
              _DialogField(provider, 'الجهة/الطبيب'),
            ]) ==
            true &&
        n.text.trim().isNotEmpty) {
      await _vaccRepo.add(
        childId: ChildSession.instance.selectedChild!.id,
        name: n.text,
        doseLabel: dose.text,
        scheduledDate: _date(date.text),
        provider: provider.text,
      );
      await _refresh();
    }
  }

  Future<void> _addTask() async {
    final t = TextEditingController(), cat = TextEditingController();
    if (await _showForm('إضافة مهمة', [
              _DialogField(t, 'عنوان المهمة'),
              _DialogField(cat, 'التصنيف'),
            ]) ==
            true &&
        t.text.trim().isNotEmpty) {
      await _taskRepo.add(
        childId: ChildSession.instance.selectedChild!.id,
        title: t.text,
        category: cat.text,
      );
      await _refresh();
    }
  }

  Future<void> _addQuestion() async {
    final q = TextEditingController();
    if (await _showForm('إضافة سؤال للطبيب', [_DialogField(q, 'السؤال')]) ==
            true &&
        q.text.trim().isNotEmpty) {
      await _questionRepo.add(
        childId: ChildSession.instance.selectedChild!.id,
        question: q.text,
      );
      await _refresh();
    }
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));
  DateTime? _date(String text) => DateTime.tryParse(text.trim());
  Future<bool?> _showForm(String title, List<Widget> fields) =>
      showDialog<bool>(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: fields),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      );
}

class _ChildData {
  const _ChildData(this.growth, this.vaccinations, this.tasks, this.questions);
  final List<GrowthMeasurement> growth;
  final List<Vaccination> vaccinations;
  final List<FamilyTask> tasks;
  final List<DoctorQuestion> questions;
  static Future<_ChildData> load(
    String id,
    GrowthRepository g,
    VaccinationRepository v,
    FamilyTaskRepository t,
    DoctorQuestionRepository q,
  ) async {
    final r = await Future.wait([
      g.fetch(id),
      v.fetch(id),
      t.fetch(id),
      q.fetch(id),
    ]);
    return _ChildData(
      r[0] as List<GrowthMeasurement>,
      r[1] as List<Vaccination>,
      r[2] as List<FamilyTask>,
      r[3] as List<DoctorQuestion>,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});
  final ChildProfile child;
  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          [
                Text('الجنس: ${ArabicFormatters.gender(child.gender)}'),
                Text(
                  'الرضاعة: ${ArabicFormatters.feedingType(child.feedingType)}',
                ),
                Text(
                  'فصيلة الدم: ${child.bloodType?.isNotEmpty == true ? child.bloodType : 'غير محدد'}',
                ),
                Text(
                  'وزن الولادة: ${child.birthWeightKg == null ? 'غير محدد' : '${child.birthWeightKg} كجم'}',
                ),
                Text(
                  child.isBorn
                      ? 'تاريخ الميلاد: ${ArabicFormatters.date(child.birthDate)}'
                      : 'موعد الولادة المتوقع: ${ArabicFormatters.date(child.dueDate)}',
                ),
              ]
              .map(
                (w) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    child: w,
                  ),
                ),
              )
              .toList(),
    ),
  );
}

class _GrowthList extends StatelessWidget {
  const _GrowthList(this.items);
  final List<GrowthMeasurement> items;
  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      children: items
          .map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ArabicFormatters.date(e.measuredAt)),
              subtitle: Text(
                'وزن ${e.weightKg ?? '-'} كجم · طول ${e.heightCm ?? '-'} سم · رأس ${e.headCircumferenceCm ?? '-'} سم',
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _VaccinationList extends StatelessWidget {
  const _VaccinationList({required this.items, required this.onStatus});
  final List<Vaccination> items;
  final Future<void> Function(Vaccination, String) onStatus;
  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      children: items
          .map(
            (v) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                v.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${v.doseLabel ?? ''} · ${ArabicFormatters.date(v.scheduledDate)} · ${v.status}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (s) => onStatus(v, s),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'completed', child: Text('مكتمل')),
                  PopupMenuItem(value: 'skipped', child: Text('متروك')),
                  PopupMenuItem(value: 'scheduled', child: Text('مجدول')),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.items, required this.onChanged});
  final List<FamilyTask> items;
  final Future<void> Function(FamilyTask, bool) onChanged;
  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      children: items
          .map(
            (t) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: t.isCompleted,
              onChanged: (v) => onChanged(t, v ?? false),
              title: Text(t.title),
              subtitle: Text(t.category ?? 'بدون تصنيف'),
            ),
          )
          .toList(),
    ),
  );
}

class _QuestionList extends StatelessWidget {
  const _QuestionList({required this.items, required this.onAnswered});
  final List<DoctorQuestion> items;
  final Future<void> Function(DoctorQuestion, bool) onAnswered;
  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      children: items
          .map(
            (q) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: q.isAnswered,
              onChanged: (v) => onAnswered(q, v ?? false),
              title: Text(q.question),
              subtitle: Text(q.isAnswered ? 'تمت الإجابة' : 'بانتظار الطبيب'),
            ),
          )
          .toList(),
    ),
  );
}

class _DialogField extends StatelessWidget {
  const _DialogField(this.controller, this.label, [this.keyboardType]);
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
