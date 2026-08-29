import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../core/formatters/arabic_formatters.dart';
import '../../models/child_guardian.dart';
import '../../models/child_profile.dart';
import '../../models/doctor_question.dart';
import '../../models/family_task.dart';
import '../../models/growth_measurement.dart';
import '../../models/vaccination.dart';
import '../../repositories/child_repository.dart';
import '../../repositories/doctor_question_repository.dart';
import '../../repositories/family_sharing_repository.dart';
import '../../repositories/family_task_repository.dart';
import '../../repositories/growth_repository.dart';
import '../../repositories/vaccination_repository.dart';
import '../../state/app_events.dart';
import '../../state/child_session.dart';
import '../../state/numuw_app_state.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/icons/numuw_icon.dart';
import '../../widgets/numuw_classy_components.dart';
import '../../widgets/numuw_motion_widgets.dart';

/// Clean UTF-8 production Child hub. It replaces the legacy corrupted Arabic
/// presentation while preserving the same repositories and user actions.
class ClassyChildScreen extends StatefulWidget {
  const ClassyChildScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  State<ClassyChildScreen> createState() => _ClassyChildScreenState();
}

class _ClassyChildScreenState extends State<ClassyChildScreen> {
  final _growthRepo = GrowthRepository();
  final _vaccinationRepo = VaccinationRepository();
  final _taskRepo = FamilyTaskRepository();
  final _familyRepo = FamilySharingRepository();
  final _questionRepo = DoctorQuestionRepository();
  final _vaccinationKey = GlobalKey();
  Future<_ChildBundle>? _future;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
    ChildSession.instance.addListener(_changed);
    AppEvents.instance.addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitial());
  }

  @override
  void didUpdateWidget(covariant ClassyChildScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitial());
    }
  }

  @override
  void dispose() {
    ChildSession.instance.removeListener(_changed);
    AppEvents.instance.removeListener(_changed);
    super.dispose();
  }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _text => _dark ? AppColors.nightText : AppColors.text;
  Color get _secondary => _dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
  Color get _accent => _dark ? AppColors.nightPrimaryStrong : AppColors.plum;
  Color get _border => _dark ? AppColors.nightBorder : AppColors.border;

  void _changed() {
    if (mounted) setState(_load);
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      _future = Future.value(const _ChildBundle([], [], [], [], []));
      return;
    }
    final request = ++_requestId;
    _future = _ChildBundle.load(
      child.id,
      growthRepo: _growthRepo,
      vaccinationRepo: _vaccinationRepo,
      taskRepo: _taskRepo,
      familyRepo: _familyRepo,
      questionRepo: _questionRepo,
    ).then((value) {
      if (request != _requestId || ChildSession.instance.selectedChild?.id != child.id) {
        return const _ChildBundle([], [], [], [], []);
      }
      return value;
    });
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  void _scrollToInitial() {
    if (!mounted || widget.initialSection != 'vaccinations') return;
    final target = _vaccinationKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic, alignment: .06);
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      return const Scaffold(body: AppPage(child: EmptyState(message: 'لا يوجد طفل محدد.')));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AppPage(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChildHeader(child: child, onEdit: () => _editChild(child)),
              const SizedBox(height: 16),
              FutureBuilder<_ChildBundle>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return NumuwClassySurface(
                      child: SizedBox(height: 190, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _accent))),
                    );
                  }
                  if (snapshot.hasError) {
                    return _MessageCard(message: readableError(snapshot.error!), danger: true);
                  }
                  final data = snapshot.data ?? const _ChildBundle([], [], [], [], []);
                  return Column(
                    children: [
                      _GrowthSection(items: data.growth, onAdd: _addGrowth),
                      const SizedBox(height: 14),
                      _VaccinationSection(
                        key: _vaccinationKey,
                        items: data.vaccinations,
                        onAdd: _addVaccination,
                        onStatus: (vaccination, status) async {
                          await _vaccinationRepo.updateStatus(vaccination.id, status);
                          await NumuwAppState.instance.vaccinationChanged();
                          await _refresh();
                        },
                      ),
                      const SizedBox(height: 14),
                      _TasksSection(
                        items: data.tasks,
                        guardians: data.guardians,
                        onAdd: () => _addTask(data.guardians),
                        onChanged: (task, completed) async {
                          await _taskRepo.setCompleted(task.id, completed);
                          AppEvents.instance.tasksChanged();
                          await _refresh();
                        },
                      ),
                      const SizedBox(height: 14),
                      _QuestionsSection(
                        items: data.questions,
                        onAdd: _addQuestion,
                        onChanged: (question, answered) async {
                          await _questionRepo.setAnswered(question.id, answered);
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
      ),
    );
  }

  Future<void> _editChild(ChildProfile child) async {
    final name = TextEditingController(text: child.name);
    final blood = TextEditingController(text: child.bloodType ?? '');
    final weight = TextEditingController(text: child.birthWeightKg?.toString() ?? '');
    final saved = await _formSheet(
      title: 'تعديل بيانات الطفل',
      asset: NumuwIcons.edit,
      fields: [
        _SheetField(controller: name, label: 'الاسم'),
        _SheetField(controller: blood, label: 'فصيلة الدم'),
        _SheetField(controller: weight, label: 'وزن الولادة بالكيلو', numeric: true),
      ],
    );
    if (saved == true) {
      try {
        final updated = await ChildRepository().updateChild(
          child.copyWith(
            name: name.text.trim().isEmpty ? child.name : name.text.trim(),
            bloodType: blood.text.trim(),
            birthWeightKg: _number(weight.text),
          ),
        );
        ChildSession.instance.selectChild(updated);
        await ChildSession.instance.refresh();
        await _refresh();
      } catch (error, stackTrace) {
        logError(error, stackTrace);
        if (mounted) _showMessage(readableError(error));
      }
    }
    name.dispose();
    blood.dispose();
    weight.dispose();
  }

  Future<void> _addGrowth() async {
    final weight = TextEditingController();
    final height = TextEditingController();
    final head = TextEditingController();
    final source = TextEditingController();
    final notes = TextEditingController();
    final date = TextEditingController(text: _dateOnly(DateTime.now()));
    final saved = await _formSheet(
      title: 'إضافة قياس نمو',
      asset: NumuwIcons.growth,
      fields: [
        _SheetField(controller: weight, label: 'الوزن كجم', numeric: true),
        _SheetField(controller: height, label: 'الطول سم', numeric: true),
        _SheetField(controller: head, label: 'محيط الرأس سم', numeric: true),
        _SheetField(controller: date, label: 'تاريخ القياس', date: true),
        _SheetField(controller: source, label: 'المصدر أو العيادة'),
        _SheetField(controller: notes, label: 'ملاحظات', multiline: true),
      ],
    );
    if (saved == true) {
      try {
        final child = ChildSession.instance.selectedChild!;
        await _growthRepo.add(
          childId: child.id,
          measuredAt: _parseDate(date.text) ?? DateTime.now(),
          weightKg: _number(weight.text),
          heightCm: _number(height.text),
          headCm: _number(head.text),
          source: source.text,
          notes: notes.text,
        );
        await _refresh();
      } catch (error, stackTrace) {
        logError(error, stackTrace);
        if (mounted) _showMessage(readableError(error));
      }
    }
    for (final controller in [weight, height, head, source, notes, date]) {
      controller.dispose();
    }
  }

  Future<void> _addVaccination() async {
    final name = TextEditingController();
    final dose = TextEditingController();
    final provider = TextEditingController();
    final date = TextEditingController(text: _dateOnly(DateTime.now()));
    final saved = await _formSheet(
      title: 'إضافة تطعيم',
      asset: NumuwIcons.vaccination,
      fields: [
        _SheetField(controller: name, label: 'اسم التطعيم'),
        _SheetField(controller: dose, label: 'الجرعة'),
        _SheetField(controller: date, label: 'التاريخ المتوقع', date: true),
        _SheetField(controller: provider, label: 'الجهة أو الطبيب'),
      ],
    );
    if (saved == true && name.text.trim().isNotEmpty) {
      try {
        await _vaccinationRepo.add(
          childId: ChildSession.instance.selectedChild!.id,
          name: name.text,
          doseLabel: dose.text,
          scheduledDate: _parseDate(date.text),
          provider: provider.text,
        );
        await NumuwAppState.instance.vaccinationChanged();
        await _refresh();
      } catch (error, stackTrace) {
        logError(error, stackTrace);
        if (mounted) _showMessage(readableError(error));
      }
    }
    name.dispose();
    dose.dispose();
    provider.dispose();
    date.dispose();
  }

  Future<void> _addTask(List<ChildGuardian> guardians) async {
    final title = TextEditingController();
    final category = TextEditingController();
    final due = TextEditingController();
    String? assignedTo;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsetsDirectional.fromSTEB(18, 10, 18, 20 + MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SheetTitle(title: 'إضافة مهمة للعيلة', asset: NumuwIcons.tasks),
                const SizedBox(height: 16),
                NumuwTextField(controller: title, label: 'عنوان المهمة'),
                const SizedBox(height: 12),
                NumuwTextField(controller: category, label: 'التصنيف'),
                const SizedBox(height: 12),
                _DateInput(controller: due, label: 'تاريخ الاستحقاق - اختياري'),
                if (guardians.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('المسؤول عن المهمة', style: TextStyle(color: _text, fontSize: 12.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _ChoiceChip(label: 'كل العيلة', selected: assignedTo == null, onTap: () => setSheetState(() => assignedTo = null)),
                      for (final guardian in guardians)
                        _ChoiceChip(label: guardian.label, selected: assignedTo == guardian.userId, onTap: () => setSheetState(() => assignedTo = guardian.userId)),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                NumuwClassyButton(label: 'حفظ المهمة', onPressed: () => Navigator.pop(sheetContext, true)),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved == true && title.text.trim().isNotEmpty) {
      try {
        await _taskRepo.add(
          childId: ChildSession.instance.selectedChild!.id,
          title: title.text,
          category: category.text,
          dueAt: _parseDate(due.text),
          assignedTo: assignedTo,
        );
        AppEvents.instance.tasksChanged();
        await _refresh();
      } catch (error, stackTrace) {
        logError(error, stackTrace);
        if (mounted) _showMessage(readableError(error));
      }
    }
    title.dispose();
    category.dispose();
    due.dispose();
  }

  Future<void> _addQuestion() async {
    final question = TextEditingController();
    final saved = await _formSheet(
      title: 'إضافة سؤال للطبيب',
      asset: NumuwIcons.doctor,
      fields: [_SheetField(controller: question, label: 'السؤال', multiline: true)],
    );
    if (saved == true && question.text.trim().isNotEmpty) {
      try {
        await _questionRepo.add(childId: ChildSession.instance.selectedChild!.id, question: question.text);
        await _refresh();
      } catch (error, stackTrace) {
        logError(error, stackTrace);
        if (mounted) _showMessage(readableError(error));
      }
    }
    question.dispose();
  }

  Future<bool?> _formSheet({required String title, required String asset, required List<_SheetField> fields}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(18, 10, 18, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetTitle(title: title, asset: asset),
              const SizedBox(height: 16),
              for (var i = 0; i < fields.length; i++) ...[
                if (fields[i].date)
                  _DateInput(controller: fields[i].controller, label: fields[i].label)
                else if (fields[i].multiline)
                  NumuwTextArea(controller: fields[i].controller, label: fields[i].label)
                else if (fields[i].numeric)
                  NumuwNumberField(controller: fields[i].controller, label: fields[i].label)
                else
                  NumuwTextField(controller: fields[i].controller, label: fields[i].label),
                if (i != fields.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 18),
              NumuwClassyButton(label: 'حفظ', onPressed: () => Navigator.pop(sheetContext, true)),
              const SizedBox(height: 8),
              NumuwClassyButton(label: 'إلغاء', variant: NumuwButtonVariant.secondary, onPressed: () => Navigator.pop(sheetContext, false)),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double? _number(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

  String _dateOnly(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime? _parseDate(String value) => DateTime.tryParse(value.trim());
}

class _ChildHeader extends StatelessWidget {
  const _ChildHeader({required this.child, required this.onEdit});
  final ChildProfile child;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final subtitle = child.isBorn
        ? 'منذ ${ArabicFormatters.age(child)}'
        : 'الموعد المتوقع ${ArabicFormatters.date(child.dueDate)}';
    return Column(
      children: [
        SizedBox(
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('طفلي', style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w800)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: NumuwPressable(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(width: 44, height: 44, child: Center(child: NumuwIcon(NumuwIcons.edit, size: 20, color: accent))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        NumuwClassySurface(
          radius: 28,
          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .09)),
                child: NumuwIcon(NumuwIcons.child, size: 42, color: accent),
              ),
              const SizedBox(height: 9),
              Text(child.name, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: 11.5)),
              const SizedBox(height: 11),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 7,
                runSpacing: 7,
                children: [
                  if (child.bloodType?.trim().isNotEmpty == true) _MiniPill(label: 'الدم ${child.bloodType}'),
                  if (child.birthWeightKg != null) _MiniPill(label: 'وزن الولادة ${child.birthWeightKg} كجم'),
                  _MiniPill(label: child.isBorn ? 'مولود' : 'حمل'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GrowthSection extends StatelessWidget {
  const _GrowthSection({required this.items, required this.onAdd});
  final List<GrowthMeasurement> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final latest = sorted.isEmpty ? null : sorted.last;
    return _Section(
      title: 'النمو',
      subtitle: 'الوزن والطول ومحيط الرأس',
      asset: NumuwIcons.growth,
      onAdd: onAdd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (latest == null)
            const _EmptyLine(message: 'أضيفي أول قياس لبدء متابعة النمو.')
          else ...[
            Row(
              children: [
                Expanded(child: _Metric(asset: NumuwIcons.weight, label: 'الوزن', value: latest.weightKg == null ? '—' : '${latest.weightKg} كجم')),
                const SizedBox(width: 7),
                Expanded(child: _Metric(asset: NumuwIcons.height, label: 'الطول', value: latest.heightCm == null ? '—' : '${latest.heightCm} سم')),
                const SizedBox(width: 7),
                Expanded(child: _Metric(asset: NumuwIcons.headCircumference, label: 'محيط الرأس', value: latest.headCircumferenceCm == null ? '—' : '${latest.headCircumferenceCm} سم')),
              ],
            ),
            if (sorted.length >= 2) ...[
              const SizedBox(height: 15),
              SizedBox(height: 150, child: _GrowthChart(items: sorted)),
            ],
            const SizedBox(height: 11),
            _MessageCard(message: 'منحنى النمو يعرض القياسات المسجلة فقط ولا يمثل تشخيصًا أو تقييمًا طبيًا.'),
          ],
        ],
      ),
    );
  }
}

class _VaccinationSection extends StatelessWidget {
  const _VaccinationSection({super.key, required this.items, required this.onAdd, required this.onStatus});
  final List<Vaccination> items;
  final VoidCallback onAdd;
  final Future<void> Function(Vaccination vaccination, String status) onStatus;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) {
      final ad = a.scheduledDate ?? DateTime(2100);
      final bd = b.scheduledDate ?? DateTime(2100);
      return ad.compareTo(bd);
    });
    return _Section(
      title: 'التطعيمات',
      subtitle: 'المواعيد والحالة والمصدر',
      asset: NumuwIcons.vaccination,
      onAdd: onAdd,
      child: sorted.isEmpty
          ? const _EmptyLine(message: 'لا توجد تطعيمات مسجلة بعد.')
          : Column(
              children: [
                for (var i = 0; i < sorted.length; i++) ...[
                  _VaccinationRow(vaccination: sorted[i], onStatus: onStatus),
                  if (i != sorted.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _VaccinationRow extends StatelessWidget {
  const _VaccinationRow({required this.vaccination, required this.onStatus});
  final Vaccination vaccination;
  final Future<void> Function(Vaccination vaccination, String status) onStatus;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: border), color: dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwIcon(NumuwIcons.vaccination, size: 23, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vaccination.name, style: TextStyle(color: text, fontSize: 12.7, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  '${vaccination.doseLabel ?? 'جرعة غير محددة'} · ${ArabicFormatters.date(vaccination.scheduledDate)}',
                  style: TextStyle(color: secondary, fontSize: 10.6),
                ),
                if (vaccination.sourceName?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      NumuwIcon(NumuwIcons.source, size: 13, color: secondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(vaccination.sourceName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 9.7))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusPill(status: vaccination.status),
              PopupMenuButton<String>(
                onSelected: (status) => onStatus(vaccination, status),
                tooltip: 'تغيير حالة التطعيم',
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'completed', child: Text('مكتمل')),
                  PopupMenuItem(value: 'scheduled', child: Text('مجدول')),
                  PopupMenuItem(value: 'skipped', child: Text('مؤجل')),
                ],
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(8),
                  child: NumuwIcon(NumuwIcons.more, size: 17, color: secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasksSection extends StatelessWidget {
  const _TasksSection({required this.items, required this.guardians, required this.onAdd, required this.onChanged});
  final List<FamilyTask> items;
  final List<ChildGuardian> guardians;
  final VoidCallback onAdd;
  final Future<void> Function(FamilyTask task, bool completed) onChanged;

  String? _assignee(FamilyTask task) {
    if (task.assignedTo == null) return null;
    for (final guardian in guardians) {
      if (guardian.userId == task.assignedTo) return guardian.label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => _Section(
        title: 'مهام العيلة',
        subtitle: 'قسّمي المسؤوليات بوضوح',
        asset: NumuwIcons.tasks,
        onAdd: onAdd,
        child: items.isEmpty
            ? const _EmptyLine(message: 'لا توجد مهام عائلية بعد.')
            : Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _CheckRow(
                      asset: NumuwIcons.tasks,
                      title: items[i].title,
                      subtitle: [items[i].category, _assignee(items[i])].whereType<String>().where((value) => value.trim().isNotEmpty).join(' · '),
                      checked: items[i].isCompleted,
                      onTap: () => onChanged(items[i], !items[i].isCompleted),
                    ),
                    if (i != items.length - 1) const SizedBox(height: 7),
                  ],
                ],
              ),
      );
}

class _QuestionsSection extends StatelessWidget {
  const _QuestionsSection({required this.items, required this.onAdd, required this.onChanged});
  final List<DoctorQuestion> items;
  final VoidCallback onAdd;
  final Future<void> Function(DoctorQuestion question, bool answered) onChanged;

  @override
  Widget build(BuildContext context) => _Section(
        title: 'أسئلة الطبيب',
        subtitle: 'جهزي الزيارة بدون نسيان التفاصيل',
        asset: NumuwIcons.doctor,
        onAdd: onAdd,
        child: items.isEmpty
            ? const _EmptyLine(message: 'لا توجد أسئلة للطبيب بعد.')
            : Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _CheckRow(
                      asset: NumuwIcons.doctor,
                      title: items[i].question,
                      subtitle: items[i].isAnswered ? 'تمت مناقشته' : 'في انتظار المناقشة',
                      checked: items[i].isAnswered,
                      onTap: () => onChanged(items[i], !items[i].isAnswered),
                    ),
                    if (i != items.length - 1) const SizedBox(height: 7),
                  ],
                ],
              ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.asset, required this.onAdd, required this.child});
  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback onAdd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return NumuwClassySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .09)),
                child: NumuwIcon(asset, size: 21, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: text, fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: secondary, fontSize: 10.5)),
                  ],
                ),
              ),
              NumuwPressable(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(20),
                child: Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .08)), child: NumuwIcon(NumuwIcons.add, size: 19, color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.asset, required this.label, required this.value});
  final String asset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 10, 6, 9),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: border), color: dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised),
      child: Column(
        children: [
          NumuwIcon(asset, size: 20, color: accent),
          const SizedBox(height: 5),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontSize: 11.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, style: TextStyle(color: secondary, fontSize: 8.8)),
        ],
      ),
    );
  }
}

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({required this.items});
  final List<GrowthMeasurement> items;

  List<FlSpot> _spots(double? Function(GrowthMeasurement item) value) {
    final result = <FlSpot>[];
    for (var i = 0; i < items.length; i++) {
      final y = value(items[i]);
      if (y != null) result.add(FlSpot(i.toDouble(), y));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (items.length - 1).toDouble(),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: border.withValues(alpha: .6), strokeWidth: .7)),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: true),
        lineBarsData: [
          LineChartBarData(spots: _spots((item) => item.weightKg), isCurved: true, dotData: const FlDotData(show: false), barWidth: 2.2, color: AppColors.plum),
          LineChartBarData(spots: _spots((item) => item.heightCm), isCurved: true, dotData: const FlDotData(show: false), barWidth: 2.2, color: AppColors.info),
          LineChartBarData(spots: _spots((item) => item.headCircumferenceCm), isCurved: true, dotData: const FlDotData(show: false), barWidth: 2.2, color: AppColors.success),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.asset, required this.title, required this.subtitle, required this.checked, required this.onTap});
  final String asset;
  final String title;
  final String subtitle;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsetsDirectional.all(11),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: border), color: dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised),
        child: Row(
          children: [
            Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .08)), child: NumuwIcon(checked ? NumuwIcons.check : asset, size: 17, color: accent)),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: text, fontSize: 12.2, fontWeight: FontWeight.w700, decoration: checked ? TextDecoration.lineThrough : null)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: secondary, fontSize: 9.8)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {'completed' => 'مكتمل', 'skipped' => 'مؤجل', _ => 'مجدول'};
    final color = switch (status) {'completed' => AppColors.success, 'skipped' => AppColors.warning, _ => AppColors.info};
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 8.8, fontWeight: FontWeight.w800)),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: accent, fontSize: 9.5, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
      child: Row(
        children: [
          NumuwIcon(NumuwIcons.logoMark, size: 21, color: secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: secondary, fontSize: 11.2, height: 1.45))),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.danger = false});
  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = danger ? AppColors.danger : (dark ? AppColors.nightPrimaryStrong : AppColors.plum);
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(color: accent.withValues(alpha: .07), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withValues(alpha: .15))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwIcon(danger ? NumuwIcons.emergency : NumuwIcons.info, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: text, fontSize: 10.7, height: 1.5))),
        ],
      ),
    );
  }
}

class _SheetField {
  const _SheetField({required this.controller, required this.label, this.numeric = false, this.multiline = false, this.date = false});
  final TextEditingController controller;
  final String label;
  final bool numeric;
  final bool multiline;
  final bool date;
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title, required this.asset});
  final String title;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumuwIcon(asset, size: 22, color: accent),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => NumuwPressable(
        onTap: () async {
          final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
          final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 3650)), locale: const Locale('ar'));
          if (picked != null) {
            controller.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AbsorbPointer(child: NumuwTextField(controller: controller, label: label)),
      );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    return NumuwPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: selected ? accent.withValues(alpha: .10) : Colors.transparent, borderRadius: BorderRadius.circular(999), border: Border.all(color: selected ? accent : border)),
        child: Text(label, style: TextStyle(color: selected ? accent : text, fontSize: 10.5, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ChildBundle {
  const _ChildBundle(this.growth, this.vaccinations, this.tasks, this.guardians, this.questions);
  final List<GrowthMeasurement> growth;
  final List<Vaccination> vaccinations;
  final List<FamilyTask> tasks;
  final List<ChildGuardian> guardians;
  final List<DoctorQuestion> questions;

  static Future<_ChildBundle> load(
    String childId, {
    required GrowthRepository growthRepo,
    required VaccinationRepository vaccinationRepo,
    required FamilyTaskRepository taskRepo,
    required FamilySharingRepository familyRepo,
    required DoctorQuestionRepository questionRepo,
  }) async {
    final results = await Future.wait<Object>([
      growthRepo.fetch(childId),
      vaccinationRepo.fetch(childId),
      taskRepo.fetch(childId),
      familyRepo.fetchGuardians(childId),
      questionRepo.fetch(childId),
    ]);
    return _ChildBundle(
      results[0] as List<GrowthMeasurement>,
      results[1] as List<Vaccination>,
      results[2] as List<FamilyTask>,
      results[3] as List<ChildGuardian>,
      results[4] as List<DoctorQuestion>,
    );
  }
}
