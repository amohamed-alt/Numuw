import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../core/formatters/arabic_formatters.dart';
import '../design/numuw_motion_widgets.dart';
import '../design/numuw_organic_icons.dart';
import '../models/child_guardian.dart';
import '../models/child_profile.dart';
import '../models/doctor_question.dart';
import '../models/family_task.dart';
import '../models/growth_measurement.dart';
import '../models/vaccination.dart';
import '../repositories/child_repository.dart';
import '../repositories/doctor_question_repository.dart';
import '../repositories/family_sharing_repository.dart';
import '../repositories/family_task_repository.dart';
import '../repositories/growth_repository.dart';
import '../repositories/vaccination_repository.dart';
import '../state/app_events.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import '../widgets/numuw_components.dart';

class ChildScreen extends StatefulWidget {
  const ChildScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  final _growthRepo = GrowthRepository();
  final _vaccinationRepo = VaccinationRepository();
  final _taskRepo = FamilyTaskRepository();
  final _familyRepo = FamilySharingRepository();
  final _questionRepo = DoctorQuestionRepository();
  final _vaccinationKey = GlobalKey();

  Future<_ChildData>? _future;
  int _requestId = 0;

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
    if (child == null) {
      _future = null;
      return;
    }
    final request = ++_requestId;
    _future = _ChildData.load(
      child.id,
      _growthRepo,
      _vaccinationRepo,
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

  void _onChildChanged() {
    if (mounted) setState(_load);
  }

  void _onExternalChanged() {
    if (mounted) setState(_load);
  }

  void _scrollToInitial() {
    if (!mounted || widget.initialSection != 'vaccinations') return;
    final targetContext = _vaccinationKey.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: MediaQuery.maybeOf(context)?.disableAnimations == true
          ? Duration.zero
          : NumuwMotionSpec.enter,
      curve: NumuwMotionSpec.standard,
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
        body: AppPage(
          child: EmptyState(message: 'لا يوجد طفل محدد. اختاري طفلًا للمتابعة.'),
        ),
      );
    }

    return Scaffold(
      body: AppPage(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 0),
              child: NumuwEntrance(child: _buildProfileHeader(child)),
            ),
            const SizedBox(height: 18),
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
                  final data = snapshot.data ??
                      const _ChildData([], [], [], [], []);
                  return Column(
                    children: [
                      NumuwEntrance(
                        child: _GrowthSection(
                          items: data.growth,
                          onAdd: _addGrowth,
                        ),
                      ),
                      const SizedBox(height: 14),
                      NumuwEntrance(
                        child: _VaccinationSection(
                          key: _vaccinationKey,
                          items: data.vaccinations,
                          onAdd: _addVaccination,
                          onStatus: (vaccination, status) async {
                            await _vaccinationRepo.updateStatus(
                              vaccination.id,
                              status,
                            );
                            AppEvents.instance.vaccinationsChanged();
                            await _refresh();
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      NumuwEntrance(
                        child: _FamilyTasksSection(
                          items: data.tasks,
                          guardians: data.guardians,
                          onAdd: _addTask,
                          onChanged: (task, done) async {
                            await _taskRepo.setCompleted(task.id, done);
                            AppEvents.instance.tasksChanged();
                            await _refresh();
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      NumuwEntrance(
                        child: _DoctorQuestionsSection(
                          items: data.questions,
                          onAdd: _addQuestion,
                          onAnswered: (question, done) async {
                            await _questionRepo.setAnswered(question.id, done);
                            await _refresh();
                          },
                        ),
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

  Widget _buildProfileHeader(ChildProfile child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumuwAppBar(
          title: 'طفلي',
          subtitle: 'النمو والتطعيمات والمهام والأسئلة الطبية في مكان واحد',
          leading: NumuwPressable(
            semanticLabel: 'تعديل بيانات الطفل',
            onTap: () => _editChild(child),
            child: Container(
              width: 44,
              height: 44,
              padding: const EdgeInsetsDirectional.all(8),
              decoration: BoxDecoration(
                color: numuwSurfaceColor(),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: numuwBorderColor()),
              ),
              child: const NumuwOrganicIcon(
                NumuwOrganicIconName.edit,
                semanticLabel: 'تعديل',
              ),
            ),
          ),
          trailing: NumuwStatusBadge(
            label: '${_stageLabel(child)} جاهز',
            color: AppColors.mint,
          ),
        ),
        const SizedBox(height: 14),
        NumuwPlantProgress(
          progress: _profileProgress(child),
          label: _profileProgressLabel(child),
        ),
        const SizedBox(height: 14),
        NumuwCard(
          child: Row(
            children: [
              const NumuwOrganicIcon(
                NumuwOrganicIconName.newborn,
                size: 58,
                semanticLabel: 'الطفل',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: TextStyle(
                        color: numuwTextColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.isBorn
                          ? 'منذ ${ArabicFormatters.age(child)}'
                          : 'الموعد المتوقع ${ArabicFormatters.date(child.dueDate)}',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _profileProgress(ChildProfile child) {
    var score = 0;
    if (child.name.trim().isNotEmpty) score++;
    if (child.bloodType?.trim().isNotEmpty == true) score++;
    if (child.birthWeightKg != null) score++;
    if (child.feedingType.trim().isNotEmpty && child.feedingType != 'not_set') {
      score++;
    }
    return score / 4;
  }

  String _profileProgressLabel(ChildProfile child) {
    final progress = _profileProgress(child);
    if (progress == 0) return 'البذرة الأولى';
    if (progress < .75) return 'الملف ينمو';
    return 'البيانات مكتملة';
  }

  String _stageLabel(ChildProfile child) => child.isBorn ? 'مولود' : 'حمل';

  Future<void> _editChild(ChildProfile child) async {
    final name = TextEditingController(text: child.name);
    final bloodType = TextEditingController(text: child.bloodType ?? '');
    final birthWeight = TextEditingController(
      text: child.birthWeightKg?.toString() ?? '',
    );
    try {
      final saved = await _showForm(
        'تعديل بيانات الطفل',
        [
          _DialogField(name, 'الاسم'),
          _DialogField(bloodType, 'فصيلة الدم'),
          _DialogField(
            birthWeight,
            'وزن الولادة بالكيلوغرام',
            TextInputType.number,
          ),
        ],
      );
      if (saved != true || !mounted) return;
      final updated = await ChildRepository().updateChild(
        child.copyWith(
          name: name.text.trim(),
          bloodType: bloodType.text.trim(),
          birthWeightKg: _number(birthWeight),
        ),
      );
      ChildSession.instance.selectChild(updated);
      await ChildSession.instance.refresh();
      if (mounted) setState(_load);
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) _showError(error);
    } finally {
      name.dispose();
      bloodType.dispose();
      birthWeight.dispose();
    }
  }

  Future<void> _addGrowth() async {
    final weight = TextEditingController();
    final height = TextEditingController();
    final head = TextEditingController();
    final source = TextEditingController();
    final notes = TextEditingController();
    final measuredAt = TextEditingController(text: _dateOnly(DateTime.now()));
    try {
      final saved = await _showForm(
        'إضافة قياس نمو',
        [
          _DialogField(weight, 'الوزن بالكيلوغرام', TextInputType.number),
          _DialogField(height, 'الطول بالسنتيمتر', TextInputType.number),
          _DialogField(head, 'محيط الرأس بالسنتيمتر', TextInputType.number),
          _DialogDateField(measuredAt, 'تاريخ القياس'),
          _DialogField(source, 'المصدر أو مكان القياس'),
          _DialogField(notes, 'ملاحظات'),
        ],
      );
      if (saved != true) return;
      final child = ChildSession.instance.selectedChild;
      if (child == null) return;
      if (_number(weight) == null &&
          _number(height) == null &&
          _number(head) == null) {
        _showMessage('أدخلي قياسًا واحدًا على الأقل.');
        return;
      }
      await _growthRepo.add(
        childId: child.id,
        measuredAt: _date(measuredAt.text) ?? DateTime.now(),
        weightKg: _number(weight),
        heightCm: _number(height),
        headCm: _number(head),
        source: source.text,
        notes: notes.text,
      );
      await _refresh();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) _showError(error);
    } finally {
      weight.dispose();
      height.dispose();
      head.dispose();
      source.dispose();
      notes.dispose();
      measuredAt.dispose();
    }
  }

  Future<void> _addVaccination() async {
    final name = TextEditingController();
    final dose = TextEditingController();
    final provider = TextEditingController();
    final scheduledDate = TextEditingController(text: _dateOnly(DateTime.now()));
    try {
      final saved = await _showForm(
        'إضافة تطعيم',
        [
          _DialogField(name, 'اسم التطعيم'),
          _DialogField(dose, 'الجرعة'),
          _DialogDateField(scheduledDate, 'التاريخ المتوقع'),
          _DialogField(provider, 'الجهة أو الطبيب'),
        ],
      );
      if (saved != true || name.text.trim().isEmpty) return;
      final child = ChildSession.instance.selectedChild;
      if (child == null) return;
      await _vaccinationRepo.add(
        childId: child.id,
        name: name.text,
        doseLabel: dose.text,
        scheduledDate: _date(scheduledDate.text),
        provider: provider.text,
      );
      AppEvents.instance.vaccinationsChanged();
      await _refresh();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) _showError(error);
    } finally {
      name.dispose();
      dose.dispose();
      provider.dispose();
      scheduledDate.dispose();
    }
  }

  Future<void> _addTask() async {
    final title = TextEditingController();
    final category = TextEditingController();
    final dueDate = TextEditingController();
    String? assignedTo;
    try {
      final child = ChildSession.instance.selectedChild;
      if (child == null) return;
      final guardians = await _familyRepo.fetchGuardians(child.id);
      if (!mounted) return;
      final saved = await _showForm(
        'إضافة مهمة عائلية',
        [
          _DialogField(title, 'عنوان المهمة'),
          _DialogField(category, 'التصنيف'),
          _DialogDateField(dueDate, 'تاريخ الاستحقاق', optional: true),
          if (guardians.isNotEmpty)
            _GuardianPicker(
              guardians: guardians,
              onChanged: (value) => assignedTo = value,
            ),
        ],
      );
      if (saved != true || title.text.trim().isEmpty) return;
      await _taskRepo.add(
        childId: child.id,
        title: title.text,
        category: category.text,
        dueAt: _date(dueDate.text),
        assignedTo: assignedTo,
      );
      AppEvents.instance.tasksChanged();
      await _refresh();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) _showError(error);
    } finally {
      title.dispose();
      category.dispose();
      dueDate.dispose();
    }
  }

  Future<void> _addQuestion() async {
    final question = TextEditingController();
    try {
      final saved = await _showForm(
        'إضافة سؤال للطبيب',
        [_DialogField(question, 'السؤال')],
      );
      if (saved != true || question.text.trim().isEmpty) return;
      final child = ChildSession.instance.selectedChild;
      if (child == null) return;
      await _questionRepo.add(childId: child.id, question: question.text);
      await _refresh();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) _showError(error);
    } finally {
      question.dispose();
    }
  }

  double? _number(TextEditingController controller) => double.tryParse(
        controller.text.trim().replaceAll(',', '.'),
      );

  DateTime? _date(String text) => DateTime.tryParse(text.trim());

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<bool?> _showForm(String title, List<Widget> fields) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: fields),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      );

  void _showError(Object error) => _showMessage(readableError(error));

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
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
    String childId,
    GrowthRepository growthRepo,
    VaccinationRepository vaccinationRepo,
    FamilyTaskRepository taskRepo,
    FamilySharingRepository familyRepo,
    DoctorQuestionRepository questionRepo,
  ) async {
    final values = await Future.wait([
      growthRepo.fetch(childId),
      vaccinationRepo.fetch(childId),
      taskRepo.fetch(childId),
      familyRepo.fetchGuardians(childId),
      questionRepo.fetch(childId),
    ]);
    return _ChildData(
      values[0] as List<GrowthMeasurement>,
      values[1] as List<Vaccination>,
      values[2] as List<FamilyTask>,
      values[3] as List<ChildGuardian>,
      values[4] as List<DoctorQuestion>,
    );
  }
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
  final NumuwOrganicIconName icon;
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
                NumuwOrganicIcon(icon, size: 38, semanticLabel: title),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
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
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    final latest = sorted.isEmpty ? null : sorted.first;
    return _SectionCard(
      title: 'النمو',
      icon: NumuwOrganicIconName.growth,
      actionLabel: 'إضافة قياس +',
      onAction: onAdd,
      children: [
        NumuwStatusBadge(
          label: sorted.isEmpty ? 'ابدئي أول قياس' : '${sorted.length} قياس محفوظ',
          color: AppColors.mint,
        ),
        const SizedBox(height: 12),
        if (latest == null)
          _EmptySection(
            icon: NumuwOrganicIconName.weight,
            message: 'لا توجد قياسات بعد. أضيفي الوزن أو الطول أو محيط الرأس.',
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: NumuwOrganicIconName.weight,
                  label: 'الوزن',
                  value: latest.weightKg == null ? '—' : '${latest.weightKg} كجم',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  icon: NumuwOrganicIconName.height,
                  label: 'الطول',
                  value: latest.heightCm == null ? '—' : '${latest.heightCm} سم',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  icon: NumuwOrganicIconName.headCircumference,
                  label: 'الرأس',
                  value: latest.headCircumferenceCm == null
                      ? '—'
                      : '${latest.headCircumferenceCm} سم',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'آخر قياس: ${ArabicFormatters.date(latest.measuredAt)}',
            style: TextStyle(
              color: numuwSecondaryTextColor(),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (sorted.length > 1) ...[
            const SizedBox(height: 12),
            ...sorted.take(4).map(
                  (measurement) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8),
                    child: _MeasurementRow(measurement: measurement),
                  ),
                ),
          ],
        ],
        const SizedBox(height: 10),
        const InfoBanner(
          message:
              'منحنى النمو يساعدك على متابعة القياسات المسجلة فقط، ولا يمثل تقييمًا طبيًا أو تشخيصًا.',
          icon: Icons.info_outline_rounded,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final NumuwOrganicIconName icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.all(10),
        decoration: BoxDecoration(
          color: numuwNightMode() ? AppColors.nightSurfaceSoft : AppColors.neutralSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: numuwBorderColor()),
        ),
        child: Column(
          children: [
            NumuwOrganicIcon(icon, size: 30),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      );
}

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({required this.measurement});

  final GrowthMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final values = <String>[
      if (measurement.weightKg != null) '${measurement.weightKg} كجم',
      if (measurement.heightCm != null) '${measurement.heightCm} سم',
      if (measurement.headCircumferenceCm != null)
        'رأس ${measurement.headCircumferenceCm} سم',
    ];
    return Row(
      children: [
        const NumuwOrganicIcon(NumuwOrganicIconName.calendar, size: 30),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${ArabicFormatters.date(measurement.measuredAt)} · ${values.join(' · ')}',
            style: TextStyle(
              color: numuwTextColor(),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
    final completed = items.where((item) => item.status == 'completed').length;
    final scheduled = items.where((item) => item.status == 'scheduled').toList()
      ..sort((a, b) {
        final left = a.scheduledDate ?? DateTime(9999);
        final right = b.scheduledDate ?? DateTime(9999);
        return left.compareTo(right);
      });
    return _SectionCard(
      title: 'التطعيمات',
      icon: NumuwOrganicIconName.vaccine,
      actionLabel: 'إضافة +',
      onAction: onAdd,
      children: [
        NumuwStatusBadge(
          label: items.isEmpty
              ? 'لم يبدأ الجدول'
              : '$completed مكتمل · ${scheduled.length} قادم',
          color: AppColors.blue,
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _EmptySection(
            icon: NumuwOrganicIconName.vaccine,
            message: 'أضيفي مواعيد التطعيم حسب تعليمات الجهة الصحية أو الطبيب.',
          )
        else ...[
          ...items.take(6).map(
                (vaccination) => Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 9),
                  child: _VaccinationTile(
                    vaccination: vaccination,
                    onStatus: onStatus,
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _VaccinationTile extends StatelessWidget {
  const _VaccinationTile({required this.vaccination, required this.onStatus});

  final Vaccination vaccination;
  final Future<void> Function(Vaccination, String) onStatus;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: numuwNightMode() ? AppColors.nightSurfaceSoft : AppColors.neutralSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: numuwBorderColor()),
        ),
        child: Row(
          children: [
            const NumuwOrganicIcon(NumuwOrganicIconName.vaccine, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccination.name,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (vaccination.doseLabel?.trim().isNotEmpty == true)
                        vaccination.doseLabel!,
                      ArabicFormatters.date(vaccination.scheduledDate),
                      _vaccinationStatusLabel(vaccination.status),
                    ].join(' · '),
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'تغيير حالة التطعيم',
              onSelected: (status) => onStatus(vaccination, status),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'completed', child: Text('مكتمل')),
                PopupMenuItem(value: 'scheduled', child: Text('مجدول')),
                PopupMenuItem(value: 'skipped', child: Text('مؤجل')),
              ],
            ),
          ],
        ),
      );

  static String _vaccinationStatusLabel(String status) => switch (status) {
        'completed' => 'مكتمل',
        'skipped' => 'مؤجل',
        _ => 'مجدول',
      };
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
    String? assignee(FamilyTask task) {
      final userId = task.assignedTo;
      if (userId == null) return null;
      for (final guardian in guardians) {
        if (guardian.userId == userId) return guardian.label;
      }
      return null;
    }

    return _SectionCard(
      title: 'مهام العائلة',
      icon: NumuwOrganicIconName.tasks,
      actionLabel: 'إضافة +',
      onAction: onAdd,
      children: [
        if (items.isEmpty)
          _EmptySection(
            icon: NumuwOrganicIconName.family,
            message: 'لا توجد مهام عائلية بعد.',
          )
        else
          ...items.take(8).map(
                (task) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: task.isCompleted,
                  onChanged: (value) => onChanged(task, value ?? false),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    [
                      if (task.category?.trim().isNotEmpty == true) task.category!,
                      if (assignee(task) != null) 'مسندة إلى: ${assignee(task)}',
                      if (task.dueAt != null)
                        'الاستحقاق: ${ArabicFormatters.date(task.dueAt)}',
                    ].join(' · '),
                    style: TextStyle(color: numuwSecondaryTextColor()),
                  ),
                ),
              ),
      ],
    );
  }
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
        icon: NumuwOrganicIconName.doctor,
        actionLabel: 'إضافة +',
        onAction: onAdd,
        children: [
          if (items.isEmpty)
            _EmptySection(
              icon: NumuwOrganicIconName.doctor,
              message: 'لا توجد أسئلة للطبيب بعد. سجلي ما تريدين مناقشته قبل الزيارة.',
            )
          else
            ...items.take(8).map(
                  (question) => Container(
                    margin: const EdgeInsetsDirectional.only(bottom: 9),
                    decoration: BoxDecoration(
                      color: numuwNightMode()
                          ? AppColors.nightSurfaceSoft
                          : AppColors.blueLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CheckboxListTile(
                      dense: true,
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                      ),
                      value: question.isAnswered,
                      onChanged: (value) =>
                          onAnswered(question, value ?? false),
                      title: Text(
                        question.question,
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        question.isAnswered ? 'تمت الإجابة' : 'معلّق',
                        style: TextStyle(color: numuwSecondaryTextColor()),
                      ),
                    ),
                  ),
                ),
        ],
      );
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.icon, required this.message});

  final NumuwOrganicIconName icon;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(14),
        decoration: BoxDecoration(
          color: numuwNightMode() ? AppColors.nightSurfaceSoft : AppColors.neutralSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            NumuwOrganicIcon(icon, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
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
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('كل العائلة'),
            ),
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
          textDirection:
              keyboardType == null ? TextDirection.rtl : TextDirection.ltr,
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
              optional ? '$label (اختياري)' : label,
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
