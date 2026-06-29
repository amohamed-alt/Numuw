import 'package:flutter/material.dart';

import '../core/app_colors.dart';
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
    if (child != null) {
      _future = _ChildData.load(
        child.id,
        _growthRepo,
        _vaccRepo,
        _taskRepo,
        _questionRepo,
      );
    }
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      return const Scaffold(
        body: AppPage(child: EmptyState(message: 'لا يوجد طفل محدد.')),
      );
    }
    return Scaffold(
      body: AppPage(
        child: Column(
          children: [
            AppHeader(
              title: child.name,
              subtitle: ArabicFormatters.age(child),
              trailing: AppIconButton(
                icon: Icons.edit_outlined,
                onPressed: () => _editChild(child),
              ),
            ),
            const SizedBox(height: 18),
            _ProfileCard(child: child),
            const SizedBox(height: 22),
            FutureBuilder<_ChildData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SoftCard(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return EmptyState(
                    message: readableError(snapshot.error!),
                    icon: Icons.error_outline_rounded,
                  );
                }
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
    final w = TextEditingController();
    final h = TextEditingController();
    final head = TextEditingController();
    final source = TextEditingController();
    final notes = TextEditingController();
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
    final n = TextEditingController();
    final dose = TextEditingController();
    final provider = TextEditingController();
    final date = TextEditingController();
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
    final t = TextEditingController();
    final cat = TextEditingController();
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.mintLight, AppColors.mintSoft],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                icon: '👶',
                background: AppColors.surface,
                size: 68,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  child.name,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Line('الجنس', ArabicFormatters.gender(child.gender)),
          _Line('الرضاعة', ArabicFormatters.feedingType(child.feedingType)),
          _Line(
            'فصيلة الدم',
            child.bloodType?.isNotEmpty == true ? child.bloodType! : 'غير محدد',
          ),
          _Line(
            'وزن الولادة',
            child.birthWeightKg == null
                ? 'غير محدد'
                : '${child.birthWeightKg} كجم',
          ),
          _Line(
            child.isBorn ? 'تاريخ الميلاد' : 'موعد الولادة المتوقع',
            child.isBorn
                ? ArabicFormatters.date(child.birthDate)
                : ArabicFormatters.date(child.dueDate),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.start,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _GrowthList extends StatelessWidget {
  const _GrowthList(this.items);
  final List<GrowthMeasurement> items;
  @override
  Widget build(BuildContext context) => SoftCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: items
          .map(
            (e) => ListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                15,
                8,
                15,
                8,
              ),
              leading: const IconBadge(
                icon: '📏',
                background: AppColors.mintLight,
                size: 36,
              ),
              title: Text(
                ArabicFormatters.date(e.measuredAt),
                textAlign: TextAlign.start,
              ),
              subtitle: Text(
                'وزن ${e.weightKg ?? '-'} كجم · طول ${e.heightCm ?? '-'} سم · رأس ${e.headCircumferenceCm ?? '-'} سم',
                textAlign: TextAlign.start,
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
    padding: EdgeInsets.zero,
    child: Column(
      children: items
          .map(
            (v) => ListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                15,
                8,
                15,
                8,
              ),
              leading: const IconBadge(
                icon: '💉',
                background: AppColors.yellowLight,
                size: 36,
              ),
              title: Text(
                v.name,
                textAlign: TextAlign.start,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${v.doseLabel ?? ''} · ${ArabicFormatters.date(v.scheduledDate)} · ${v.status}',
                textAlign: TextAlign.start,
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
    padding: EdgeInsets.zero,
    child: Column(
      children: items
          .map(
            (t) => CheckboxListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                15,
                0,
                15,
                0,
              ),
              value: t.isCompleted,
              onChanged: (v) => onChanged(t, v ?? false),
              title: Text(t.title, textAlign: TextAlign.start),
              subtitle: Text(
                t.category ?? 'بدون تصنيف',
                textAlign: TextAlign.start,
              ),
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
    padding: EdgeInsets.zero,
    child: Column(
      children: items
          .map(
            (q) => CheckboxListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                15,
                0,
                15,
                0,
              ),
              value: q.isAnswered,
              onChanged: (v) => onAnswered(q, v ?? false),
              title: Text(q.question, textAlign: TextAlign.start),
              subtitle: Text(
                q.isAnswered ? 'تمت الإجابة' : 'بانتظار الطبيب',
                textAlign: TextAlign.start,
              ),
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
    padding: const EdgeInsetsDirectional.only(bottom: 10),
    child: AppTextField(
      controller: controller,
      label: label,
      keyboardType: keyboardType,
      textDirection: keyboardType == null
          ? TextDirection.rtl
          : TextDirection.ltr,
    ),
  );
}
