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
import '../state/app_events.dart';
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
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(child: child, onEdit: () => _editChild(child)),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 24),
              child: FutureBuilder<_ChildData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingSkeleton(height: 220);
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
                      _GrowthSection(items: data.growth, onAdd: _addGrowth),
                      const SizedBox(height: 14),
                      _VaccinationSection(
                        items: data.vaccinations,
                        onAdd: _addVaccination,
                        onStatus: (v, s) async {
                          await _vaccRepo.updateStatus(v.id, s);
                          AppEvents.instance.vaccinationsChanged();
                          await _refresh();
                        },
                      ),
                      const SizedBox(height: 14),
                      _FamilyTasksSection(
                        items: data.tasks,
                        onAdd: _addTask,
                        onChanged: (t, done) async {
                          await _taskRepo.setCompleted(t.id, done);
                          AppEvents.instance.tasksChanged();
                          await _refresh();
                        },
                      ),
                      const SizedBox(height: 14),
                      _DoctorQuestionsSection(
                        items: data.questions,
                        onAdd: _addQuestion,
                        onAnswered: (q, done) async {
                          await _questionRepo.setAnswered(q.id, done);
                          await _refresh();
                        },
                      ),
                    ],
                  );
                },
              ),
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
    final measuredAt = TextEditingController(text: _dateOnly(DateTime.now()));
    if (await _showForm('إضافة قياس نمو', [
          _DialogField(w, 'الوزن كجم', TextInputType.number),
          _DialogField(h, 'الطول سم', TextInputType.number),
          _DialogField(head, 'محيط الرأس سم', TextInputType.number),
          _DialogDateField(measuredAt, 'تاريخ القياس'),
          _DialogField(source, 'المصدر'),
          _DialogField(notes, 'ملاحظات'),
        ]) ==
        true) {
      final c = ChildSession.instance.selectedChild!;
      await _growthRepo.add(
        childId: c.id,
        measuredAt: _date(measuredAt.text) ?? DateTime.now(),
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
    final date = TextEditingController(text: _dateOnly(DateTime.now()));
    if (await _showForm('إضافة تطعيم', [
              _DialogField(n, 'اسم التطعيم'),
              _DialogField(dose, 'الجرعة'),
              _DialogDateField(date, 'التاريخ المتوقع'),
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
      AppEvents.instance.vaccinationsChanged();
      await _refresh();
    }
  }

  Future<void> _addTask() async {
    final t = TextEditingController();
    final cat = TextEditingController();
    final due = TextEditingController();
    if (await _showForm('إضافة مهمة', [
              _DialogField(t, 'عنوان المهمة'),
              _DialogField(cat, 'التصنيف'),
              _DialogDateField(due, 'تاريخ الاستحقاق', optional: true),
            ]) ==
            true &&
        t.text.trim().isNotEmpty) {
      await _taskRepo.add(
        childId: ChildSession.instance.selectedChild!.id,
        title: t.text,
        category: cat.text,
        dueAt: _date(due.text),
      );
      AppEvents.instance.tasksChanged();
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
  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.child, required this.onEdit});

  final ChildProfile child;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 24),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.mintLight, AppColors.background],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${child.name} ?',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
            AppIconButton(
              icon: Icons.edit_outlined,
              onPressed: onEdit,
              badge: false,
              size: 38,
              radius: 12,
              iconSize: 17,
              borderWidth: 1.5,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconBadge(
                  icon: '👶',
                  background: numuwSurfaceColor(),
                  size: 80,
                  borderColor: AppColors.mint.withValues(alpha: .30),
                ),
                PositionedDirectional(
                  end: -2,
                  bottom: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Text('📷', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ArabicFormatters.age(child),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: AppColors.mint,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 13,
                        color: numuwSecondaryTextColor(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          child.isBorn
                              ? 'منذ ${ArabicFormatters.date(child.birthDate)}'
                              : 'الموعد ${ArabicFormatters.date(child.dueDate)}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: numuwSecondaryTextColor(),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SoftCard(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          radius: 16,
          child: Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  label: 'الرضاعة',
                  value:
                      '${ArabicFormatters.feedingType(child.feedingType)} 🌱',
                  color: AppColors.mint,
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _ProfileStat(
                  label: 'فصيلة الدم',
                  value: child.bloodType?.isNotEmpty == true
                      ? '${child.bloodType} 🩸'
                      : 'غير محدد',
                  color: AppColors.peach,
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _ProfileStat(
                  label: 'وزن الولادة',
                  value: child.birthWeightKg == null
                      ? 'غير محدد'
                      : '${child.birthWeightKg} كجم',
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: numuwSecondaryTextColor(),
          fontSize: 11,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
      ),
    ],
  );
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    margin: const EdgeInsetsDirectional.symmetric(horizontal: 8),
    color: numuwBorderColor(),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => SoftCard(
    radius: 22,
    padding: const EdgeInsetsDirectional.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.mint, size: 16),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: AppColors.mint,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );
}

class _GrowthSection extends StatelessWidget {
  const _GrowthSection({required this.items, required this.onAdd});

  final List<GrowthMeasurement> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final latest = items.isEmpty ? null : items.first;
    return _SectionCard(
      title: 'النمو',
      icon: Icons.trending_up_rounded,
      actionLabel: 'إضافة قياس +',
      onAction: onAdd,
      children: [
        Row(
          children: [
            _SmallTab(label: 'الطول', active: true),
            const SizedBox(width: 8),
            _SmallTab(label: 'الوزن', active: false),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 135,
          width: double.infinity,
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد قياسات نمو بعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : CustomPaint(
                  painter: _GrowthChartPainter(items.take(5).toList()),
                ),
        ),
        if (latest != null) ...[
          const SizedBox(height: 8),
          Text(
            'آخر قياس: وزن ${latest.weightKg ?? '-'} كجم · طول ${latest.heightCm ?? '-'} سم · رأس ${latest.headCircumferenceCm ?? '-'} سم',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: numuwSecondaryTextColor(),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _SmallTab extends StatelessWidget {
  const _SmallTab({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? AppColors.mintLight : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: active ? AppColors.mint : numuwSecondaryTextColor(),
        fontSize: 13,
        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
      ),
    ),
  );
}

class _GrowthChartPainter extends CustomPainter {
  const _GrowthChartPainter(this.items);
  final List<GrowthMeasurement> items;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final dashed = Paint()
      ..color = AppColors.border
      ..strokeWidth = .7;
    canvas.drawLine(
      Offset(0, size.height * .80),
      Offset(size.width, size.height * .80),
      grid,
    );
    canvas.drawLine(
      Offset(0, size.height * .52),
      Offset(size.width, size.height * .52),
      dashed,
    );
    canvas.drawLine(
      Offset(0, size.height * .26),
      Offset(size.width, size.height * .26),
      dashed,
    );

    final values = items
        .map((e) => e.heightCm ?? e.weightKg ?? e.headCircumferenceCm ?? 0)
        .where((v) => v > 0)
        .toList();
    if (values.isEmpty) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < .1 ? 1 : max - min;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : (size.width * i / (values.length - 1));
      final normalized = (values[i] - min) / span;
      final y = size.height * .78 - normalized * size.height * .55;
      points.add(Offset(x, y));
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final area = Path.from(path)
      ..lineTo(points.last.dx, size.height * .80)
      ..lineTo(points.first.dx, size.height * .80)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = AppColors.mint.withValues(alpha: .14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.mint
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = AppColors.mint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.items != items;
}

class _VaccinationSection extends StatelessWidget {
  const _VaccinationSection({
    required this.items,
    required this.onAdd,
    required this.onStatus,
  });

  final List<Vaccination> items;
  final VoidCallback onAdd;
  final Future<void> Function(Vaccination, String) onStatus;

  @override
  Widget build(BuildContext context) {
    final completed = items.where((v) => v.status == 'completed').toList();
    final upcoming = items.where((v) => v.status == 'scheduled').toList();
    return _SectionCard(
      title: 'التطعيمات',
      icon: Icons.shield_outlined,
      actionLabel: 'إضافة +',
      onAction: onAdd,
      children: [
        if (items.isEmpty)
          Text(
            'أضيفي مواعيد التطعيم حسب تعليمات الجهة الصحية أو الطبيب.',
            textAlign: TextAlign.start,
            style: TextStyle(color: numuwSecondaryTextColor(), height: 1.6),
          )
        else ...[
          _VaccinationMini(
            label: 'آخر تطعيم',
            vaccination: completed.isEmpty ? null : completed.first,
            fallback: 'لم يتم تسجيل تطعيم مكتمل',
          ),
          const SizedBox(height: 10),
          _VaccinationMini(
            label: 'التطعيم القادم',
            vaccination: upcoming.isEmpty ? null : upcoming.first,
            fallback: 'لم يتم تحديد تطعيم قادم',
            onStatus: onStatus,
          ),
        ],
      ],
    );
  }
}

class _VaccinationMini extends StatelessWidget {
  const _VaccinationMini({
    required this.label,
    required this.vaccination,
    required this.fallback,
    this.onStatus,
  });

  final String label;
  final Vaccination? vaccination;
  final String fallback;
  final Future<void> Function(Vaccination, String)? onStatus;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(12),
    decoration: BoxDecoration(
      color: AppColors.neutralSoft,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: numuwBorderColor()),
    ),
    child: Row(
      children: [
        const IconBadge(
          icon: '💉',
          background: AppColors.yellowLight,
          size: 38,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                vaccination == null
                    ? fallback
                    : '${vaccination!.name} · ${ArabicFormatters.date(vaccination!.scheduledDate)}',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (vaccination != null && onStatus != null)
          PopupMenuButton<String>(
            onSelected: (status) => onStatus!(vaccination!, status),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'completed', child: Text('مكتمل')),
              PopupMenuItem(value: 'skipped', child: Text('مؤجل')),
              PopupMenuItem(value: 'scheduled', child: Text('مجدول')),
            ],
          ),
      ],
    ),
  );
}

class _FamilyTasksSection extends StatelessWidget {
  const _FamilyTasksSection({
    required this.items,
    required this.onAdd,
    required this.onChanged,
  });

  final List<FamilyTask> items;
  final VoidCallback onAdd;
  final Future<void> Function(FamilyTask, bool) onChanged;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'مهام العائلة',
    icon: Icons.assignment_rounded,
    actionLabel: 'إضافة +',
    onAction: onAdd,
    children: items.isEmpty
        ? [
            Text(
              'لا توجد مهام عائلية بعد.',
              textAlign: TextAlign.start,
              style: TextStyle(color: numuwSecondaryTextColor()),
            ),
          ]
        : items
              .map(
                (task) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: task.isCompleted,
                  onChanged: (value) => onChanged(task, value ?? false),
                  title: Text(
                    task.title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 14,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: task.category == null
                      ? null
                      : Text(task.category!, textAlign: TextAlign.start),
                ),
              )
              .toList(),
  );
}

class _DoctorQuestionsSection extends StatelessWidget {
  const _DoctorQuestionsSection({
    required this.items,
    required this.onAdd,
    required this.onAnswered,
  });

  final List<DoctorQuestion> items;
  final VoidCallback onAdd;
  final Future<void> Function(DoctorQuestion, bool) onAnswered;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'أسئلة الطبيب',
    icon: Icons.help_outline_rounded,
    actionLabel: 'إضافة +',
    onAction: onAdd,
    children: items.isEmpty
        ? [
            Text(
              'لا توجد أسئلة للطبيب بعد.',
              textAlign: TextAlign.start,
              style: TextStyle(color: numuwSecondaryTextColor()),
            ),
          ]
        : items
              .map(
                (question) => Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 10),
                  padding: const EdgeInsetsDirectional.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: question.isAnswered,
                    onChanged: (value) => onAnswered(question, value ?? false),
                    title: Text(
                      question.question,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      question.isAnswered ? 'تمت الإجابة' : 'معلّق',
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              )
              .toList(),
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

class _DialogDateField extends StatelessWidget {
  const _DialogDateField(this.controller, this.label, {this.optional = false});

  final TextEditingController controller;
  final String label;
  final bool optional;

  Future<void> _pick(BuildContext context) async {
    final current = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ar'),
    );
    if (picked == null) return;
    controller.text =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          optional ? '$label اختياري' : label,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _pick(context),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: optional ? 'اختياري' : null,
            suffixIcon: const Icon(Icons.calendar_month_outlined),
            filled: true,
            fillColor: numuwSurfaceColor(),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: numuwBorderColor(), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: numuwBorderColor(), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: numuwAccentColor(), width: 1.8),
            ),
          ),
        ),
      ],
    ),
  );
}
