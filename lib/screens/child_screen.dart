import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../models/child_profile.dart';
import '../models/child_guardian.dart';
import '../models/doctor_question.dart';
import '../models/family_task.dart';
import '../models/growth_measurement.dart';
import '../models/vaccination.dart';
import '../repositories/child_repository.dart';
import '../repositories/doctor_question_repository.dart';
import '../repositories/family_task_repository.dart';
import '../repositories/family_sharing_repository.dart';
import '../repositories/growth_repository.dart';
import '../repositories/vaccination_repository.dart';
import '../state/app_events.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class ChildScreen extends StatefulWidget {
  const ChildScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  final _growthRepo = GrowthRepository();
  final _vaccRepo = VaccinationRepository();
  final _taskRepo = FamilyTaskRepository();
  final _familyRepo = FamilySharingRepository();
  final _questionRepo = DoctorQuestionRepository();
  Future<_ChildData>? _future;
  int _requestId = 0;
  final _vaccinationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _load();
    ChildSession.instance.addListener(_onChildChanged);
    AppEvents.instance.addListener(_onExternalChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitial());
  }

  @override
  void didUpdateWidget(covariant ChildScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitial());
    }
  }

  @override
  void dispose() {
    ChildSession.instance.removeListener(_onChildChanged);
    AppEvents.instance.removeListener(_onExternalChanged);
    super.dispose();
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child != null) {
      final request = ++_requestId;
      _future =
          _ChildData.load(
            child.id,
            _growthRepo,
            _vaccRepo,
            _taskRepo,
            _familyRepo,
            _questionRepo,
          ).then((data) {
            if (request != _requestId ||
                ChildSession.instance.selectedChild?.id != child.id) {
              return const _ChildData([], [], [], [], []);
            }
            return data;
          });
    }
  }

  void _onChildChanged() {
    if (mounted) setState(_load);
  }

  void _onExternalChanged() {
    if (mounted) setState(_load);
  }

  void _scrollToInitial() {
    if (!mounted || widget.initialSection != 'vaccinations') return;
    final context = _vaccinationKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: .08,
    );
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
                        key: _vaccinationKey,
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
                        guardians: data.guardians,
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
    final child = ChildSession.instance.selectedChild!;
    final guardians = await _familyRepo.fetchGuardians(child.id);
    String? assignedTo;
    if (await _showForm('إضافة مهمة', [
              _DialogField(t, 'عنوان المهمة'),
              _DialogField(cat, 'التصنيف'),
              _DialogDateField(due, 'تاريخ الاستحقاق', optional: true),
              if (guardians.isNotEmpty)
                _GuardianPicker(
                  guardians: guardians,
                  onChanged: (value) => assignedTo = value,
                ),
            ]) ==
            true &&
        t.text.trim().isNotEmpty) {
      await _taskRepo.add(
        childId: child.id,
        title: t.text,
        category: cat.text,
        dueAt: _date(due.text),
        assignedTo: assignedTo,
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
  const _ChildData(
    this.growth,
    this.vaccinations,
    this.tasks,
    this.guardians,
    this.questions,
  );

  final List<GrowthMeasurement> growth;
  final List<Vaccination> vaccinations;
  final List<FamilyTask> tasks;
  final List<ChildGuardian> guardians;
  final List<DoctorQuestion> questions;

  static Future<_ChildData> load(
    String id,
    GrowthRepository g,
    VaccinationRepository v,
    FamilyTaskRepository t,
    FamilySharingRepository f,
    DoctorQuestionRepository q,
  ) async {
    final r = await Future.wait([
      g.fetch(id),
      v.fetch(id),
      t.fetch(id),
      f.fetchGuardians(id),
      q.fetch(id),
    ]);
    return _ChildData(
      r[0] as List<GrowthMeasurement>,
      r[1] as List<Vaccination>,
      r[2] as List<FamilyTask>,
      r[3] as List<ChildGuardian>,
      r[4] as List<DoctorQuestion>,
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
    final sorted = [...items]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final latest = sorted.isEmpty ? null : sorted.last;
    return _SectionCard(
      title: 'النمو',
      icon: Icons.trending_up_rounded,
      actionLabel: 'إضافة قياس +',
      onAction: onAdd,
      children: [
        Row(
          children: [
            _GrowthLegend(label: 'الوزن', color: AppColors.mint),
            const SizedBox(width: 8),
            _GrowthLegend(label: 'الطول', color: AppColors.blue),
            const SizedBox(width: 8),
            _GrowthLegend(label: 'محيط الرأس', color: AppColors.purple),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: sorted.isEmpty
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
              : _GrowthLineChart(items: sorted),
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
        const SizedBox(height: 10),
        InfoBanner(
          message:
              'منحنى النمو يساعدك على متابعة القياسات المسجلة فقط، ولا يمثل تقييمًا طبيًا أو تشخيصًا.',
          icon: Icons.info_outline_rounded,
        ),
      ],
    );
  }
}

class _GrowthLegend extends StatelessWidget {
  const _GrowthLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _GrowthLineChart extends StatelessWidget {
  const _GrowthLineChart({required this.items});

  final List<GrowthMeasurement> items;

  @override
  Widget build(BuildContext context) {
    final lines = [
      _lineData(
        color: AppColors.mint,
        values: [for (final item in items) item.weightKg],
      ),
      _lineData(
        color: AppColors.blue,
        values: [for (final item in items) item.heightCm],
      ),
      _lineData(
        color: AppColors.purple,
        values: [for (final item in items) item.headCircumferenceCm],
      ),
    ].where((line) => line.spots.isNotEmpty).toList();
    final values = lines.expand((line) => line.spots.map((spot) => spot.y));
    final minY = values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);
    final maxY = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY).abs() < .1 ? 1.0 : (maxY - minY) * .12);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (items.length - 1).toDouble().clamp(0, double.infinity),
        minY: (minY - padding).clamp(0, double.infinity),
        maxY: maxY + padding,
        lineBarsData: lines,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: numuwBorderColor(), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= items.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${items[index].measuredAt.day}/${items[index].measuredAt.month}',
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    spot.y.toStringAsFixed(1),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  LineChartBarData _lineData({
    required Color color,
    required List<double?> values,
  }) {
    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value != null && value > 0) spots.add(FlSpot(i.toDouble(), value));
    }
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: .08),
      ),
    );
  }
}

class _VaccinationSection extends StatelessWidget {
  const _VaccinationSection({
    super.key,
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
    required this.guardians,
    required this.onAdd,
    required this.onChanged,
  });

  final List<FamilyTask> items;
  final List<ChildGuardian> guardians;
  final VoidCallback onAdd;
  final Future<void> Function(FamilyTask, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    String? assigneeLabel(FamilyTask task) {
      final assignedTo = task.assignedTo;
      if (assignedTo == null) return null;
      for (final guardian in guardians) {
        if (guardian.userId == assignedTo) return guardian.label;
      }
      return null;
    }

    return _SectionCard(
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
                        ? (assigneeLabel(task) == null
                              ? null
                              : Text(
                                  'مسندة إلى: ${assigneeLabel(task)}',
                                  textAlign: TextAlign.start,
                                ))
                        : Text(
                            assigneeLabel(task) == null
                                ? task.category!
                                : '${task.category!} · مسندة إلى: ${assigneeLabel(task)}',
                            textAlign: TextAlign.start,
                          ),
                  ),
                )
                .toList(),
    );
  }
}

class _GuardianPicker extends StatefulWidget {
  const _GuardianPicker({required this.guardians, required this.onChanged});

  final List<ChildGuardian> guardians;
  final ValueChanged<String?> onChanged;

  @override
  State<_GuardianPicker> createState() => _GuardianPickerState();
}

class _GuardianPickerState extends State<_GuardianPicker> {
  String? _value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 10),
    child: DropdownButtonFormField<String?>(
      initialValue: _value,
      decoration: InputDecoration(
        labelText: 'المسؤول عن المهمة',
        filled: true,
        fillColor: numuwSurfaceColor(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('كل العيلة')),
        ...widget.guardians.map(
          (guardian) => DropdownMenuItem<String?>(
            value: guardian.userId,
            child: Text(guardian.label),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _value = value);
        widget.onChanged(value);
      },
    ),
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
