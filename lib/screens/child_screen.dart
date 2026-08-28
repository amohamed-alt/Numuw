import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../models/child_profile.dart';
import '../models/growth_measurement.dart';
import '../models/vaccination.dart';
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
  final GrowthRepository _growthRepository = GrowthRepository();
  final VaccinationRepository _vaccinationRepository = VaccinationRepository();
  final GlobalKey _vaccinationKey = GlobalKey();
  Future<_ChildOverviewData>? _future;

  @override
  void initState() {
    super.initState();
    _load();
    ChildSession.instance.addListener(_handleChange);
    AppEvents.instance.addListener(_handleChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection());
  }

  @override
  void didUpdateWidget(covariant ChildScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection());
    }
  }

  @override
  void dispose() {
    ChildSession.instance.removeListener(_handleChange);
    AppEvents.instance.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) return;
    setState(_load);
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child != null) {
      _future = _ChildOverviewData.load(
        child.id,
        _growthRepository,
        _vaccinationRepository,
      );
    }
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  void _scrollToSection() {
    if (widget.initialSection != 'vaccinations') return;
    final target = _vaccinationKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: .08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(message: 'لا يوجد طفل محدد.'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: numuwPageColor(),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_ChildOverviewData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    LoadingSkeleton(height: 170),
                    SizedBox(height: 14),
                    LoadingSkeleton(height: 260),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    ErrorMessageCard(message: readableError(snapshot.error!)),
                    const SizedBox(height: 12),
                    PrimaryButton(label: 'إعادة المحاولة', onPressed: _refresh),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? const _ChildOverviewData([], []);
            return RefreshIndicator(
              onRefresh: _refresh,
              color: numuwAccentColor(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 28),
                children: [
                  _ChildHeader(child: child),
                  const SizedBox(height: 18),
                  _ProfileHero(child: child),
                  const SizedBox(height: 14),
                  _OverviewGrid(
                    latestGrowth: data.growth.isEmpty ? null : data.growth.last,
                    vaccinations: data.vaccinations,
                    onGrowth: () => _showGrowthSheet(data.growth),
                    onVaccinations: () => _showVaccinationSheet(data.vaccinations),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'النمو والقياسات'),
                  const SizedBox(height: 10),
                  _GrowthCard(
                    latest: data.growth.isEmpty ? null : data.growth.last,
                    count: data.growth.length,
                    onAdd: _addGrowth,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    key: _vaccinationKey,
                    title: 'التطعيمات',
                  ),
                  const SizedBox(height: 10),
                  _VaccinationList(
                    items: data.vaccinations,
                    onAdd: _addVaccination,
                    onStatus: (item, status) async {
                      await _vaccinationRepository.updateStatus(item.id, status);
                      AppEvents.instance.vaccinationsChanged();
                      await _refresh();
                    },
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'هذا الأسبوع'),
                  const SizedBox(height: 10),
                  const _GentleInfoCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'التطور والمهارات',
                    text:
                        'كل طفل يتطور بطريقته. راقبي التفاعل والحركة بهدوء، وناقشي أي تغيّر يقلقك مع طبيب الأطفال.',
                  ),
                  const SizedBox(height: 12),
                  const _GentleInfoCard(
                    icon: Icons.sports_esports_outlined,
                    title: 'نشاط بسيط',
                    text:
                        'تحدثي مع طفلك، قلّدي أصواته، واستخدمي لعبة خفيفة لتحفيز تتبّعها بالعين.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsetsDirectional.all(14),
                    decoration: BoxDecoration(
                      color: numuwNightMode()
                          ? AppColors.nightInfo.withValues(alpha: .09)
                          : AppColors.blueLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: (numuwNightMode()
                                ? AppColors.nightInfo
                                : AppColors.blue)
                            .withValues(alpha: .2),
                      ),
                    ),
                    child: Text(
                      'يعرض نُمُوّ البيانات التي تسجلها الأسرة فقط، ولا يصنّف الطفل بأنه طبيعي أو غير طبيعي.',
                      style: TextStyle(
                        color: numuwTextColor(),
                        fontSize: 12.5,
                        height: 1.55,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _addGrowth() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final weight = TextEditingController();
    final height = TextEditingController();
    final head = TextEditingController();
    final source = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            18,
            8,
            18,
            MediaQuery.viewInsetsOf(context).bottom + 22,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة قياس جديد',
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'أدخلي القياسات كما تم تسجيلها في المنزل أو العيادة.',
                  style: TextStyle(color: numuwSecondaryTextColor(), height: 1.5),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'الوزن بالكيلوجرام'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'الطول بالسنتيمتر'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: head,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'محيط الرأس بالسنتيمتر'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: source,
                  decoration: const InputDecoration(labelText: 'مكان القياس — اختياري'),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'حفظ القياس',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      try {
        await _growthRepository.add(
          childId: child.id,
          measuredAt: DateTime.now(),
          weightKg: _toDouble(weight.text),
          heightCm: _toDouble(height.text),
          headCm: _toDouble(head.text),
          source: source.text,
        );
        AppEvents.instance.dashboardDataChanged();
        await _refresh();
      } catch (error, stackTrace) {
        logError(error, stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(readableError(error))),
          );
        }
      }
    }

    weight.dispose();
    height.dispose();
    head.dispose();
    source.dispose();
  }

  Future<void> _addVaccination() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    final name = TextEditingController();
    final dose = TextEditingController();
    DateTime? date;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              18,
              8,
              18,
              MediaQuery.viewInsetsOf(context).bottom + 22,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إضافة تطعيم',
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'اسم التطعيم'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dose,
                    decoration: const InputDecoration(labelText: 'الجرعة — اختياري'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                        locale: const Locale('ar'),
                      );
                      if (picked != null) setSheetState(() => date = picked);
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      date == null
                          ? 'اختيار الموعد'
                          : '${date!.day}/${date!.month}/${date!.year}',
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'حفظ التطعيم',
                    onPressed: () => Navigator.pop(
                      context,
                      name.text.trim().isNotEmpty,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved == true) {
      try {
        await _vaccinationRepository.add(
          childId: child.id,
          name: name.text,
          doseLabel: dose.text,
          scheduledDate: date,
        );
        AppEvents.instance.vaccinationsChanged();
        await _refresh();
      } catch (error, stackTrace) {
        logError(error, stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(readableError(error))),
          );
        }
      }
    }

    name.dispose();
    dose.dispose();
  }

  void _showGrowthSheet(List<GrowthMeasurement> items) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سجل النمو',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              const EmptyState(message: 'لا توجد قياسات مسجلة حتى الآن.')
            else
              ...items.reversed.take(5).map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.monitor_weight_outlined, color: numuwAccentColor()),
                      title: Text(_measurementSummary(item)),
                      subtitle: Text(_date(item.measuredAt)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showVaccinationSheet(List<Vaccination> items) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص التطعيمات',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              const EmptyState(message: 'لم تتم إضافة تطعيمات بعد.')
            else
              ...items.take(6).map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.vaccines_outlined, color: numuwAccentColor()),
                      title: Text(item.name),
                      subtitle: Text(item.scheduledDate == null ? 'موعد غير محدد' : _date(item.scheduledDate!)),
                      trailing: Icon(
                        item.status == 'completed'
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: item.status == 'completed'
                            ? (numuwNightMode() ? AppColors.nightSuccess : AppColors.success)
                            : numuwSecondaryTextColor(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ChildHeader extends StatelessWidget {
  const _ChildHeader({required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طفلي',
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'النمو، التطعيمات والمهارات في مكان واحد',
              style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 13.5),
            ),
          ],
        ),
      ),
      AppIconButton(icon: Icons.edit_outlined, onPressed: () {}, badge: false),
    ],
  );
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(18),
    decoration: BoxDecoration(
      gradient: AppColors.heroGradient(numuwNightMode()),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: numuwAccentColor().withValues(alpha: .22)),
    ),
    child: Row(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: numuwAccentColor().withValues(alpha: .13),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.child_care_rounded, size: 34, color: numuwAccentColor()),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                child.name,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                child.isBorn
                    ? _age(child.birthDate)
                    : 'موعد الولادة ${child.dueDate == null ? 'غير محدد' : _date(child.dueDate!)}',
                style: TextStyle(
                  color: numuwSecondaryTextColor(),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: numuwAccentColor().withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _feedingLabel(child.feedingType),
                  style: TextStyle(
                    color: numuwAccentColor(),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({
    required this.latestGrowth,
    required this.vaccinations,
    required this.onGrowth,
    required this.onVaccinations,
  });

  final GrowthMeasurement? latestGrowth;
  final List<Vaccination> vaccinations;
  final VoidCallback onGrowth;
  final VoidCallback onVaccinations;

  @override
  Widget build(BuildContext context) {
    final completed = vaccinations.where((item) => item.status == 'completed').length;
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            icon: Icons.monitor_weight_outlined,
            title: 'آخر وزن',
            value: latestGrowth?.weightKg == null ? '—' : '${latestGrowth!.weightKg} كجم',
            onTap: onGrowth,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            icon: Icons.vaccines_outlined,
            title: 'التطعيمات',
            value: '$completed مكتملة',
            onTap: onVaccinations,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: numuwAccentColor(), size: 22),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(title, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5)),
      ],
    ),
  );
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.latest, required this.count, required this.onAdd});

  final GrowthMeasurement? latest;
  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.show_chart_rounded, color: numuwAccentColor()),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                latest == null ? 'لا توجد قياسات بعد' : _measurementSummary(latest!),
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text('$count قياس', style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'يعرض نُمُوّ تطور القياسات المسجلة فقط. ناقشي أي تغيّر يقلقك مع طبيب الأطفال.',
          style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5, height: 1.55),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة قياس'),
        ),
      ],
    ),
  );
}

class _VaccinationList extends StatelessWidget {
  const _VaccinationList({
    required this.items,
    required this.onAdd,
    required this.onStatus,
  });

  final List<Vaccination> items;
  final VoidCallback onAdd;
  final Future<void> Function(Vaccination, String) onStatus;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsetsDirectional.all(10),
    child: Column(
      children: [
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsetsDirectional.all(8),
            child: Text('لا توجد تطعيمات مسجلة حتى الآن.'),
          )
        else
          ...items.take(5).map(
                (item) => ListTile(
                  contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: numuwNightMode()
                          ? AppColors.nightInfo.withValues(alpha: .11)
                          : AppColors.blueLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.vaccines_outlined,
                      color: numuwNightMode() ? AppColors.nightInfo : AppColors.blue,
                    ),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(
                    item.scheduledDate == null ? 'موعد غير محدد' : _date(item.scheduledDate!),
                  ),
                  trailing: IconButton(
                    tooltip: item.status == 'completed' ? 'إعادة للمنتظر' : 'تم التطعيم',
                    onPressed: () => onStatus(
                      item,
                      item.status == 'completed' ? 'scheduled' : 'completed',
                    ),
                    icon: Icon(
                      item.status == 'completed'
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: item.status == 'completed'
                          ? (numuwNightMode() ? AppColors.nightSuccess : AppColors.success)
                          : numuwSecondaryTextColor(),
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة تطعيم'),
        ),
      ],
    ),
  );
}

class _GentleInfoCard extends StatelessWidget {
  const _GentleInfoCard({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: numuwAccentColor().withValues(alpha: .11),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: numuwAccentColor()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5, height: 1.55),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: numuwTextColor(),
      fontSize: 17,
      fontWeight: FontWeight.w900,
    ),
  );
}

class _ChildOverviewData {
  const _ChildOverviewData(this.growth, this.vaccinations);

  final List<GrowthMeasurement> growth;
  final List<Vaccination> vaccinations;

  static Future<_ChildOverviewData> load(
    String childId,
    GrowthRepository growthRepository,
    VaccinationRepository vaccinationRepository,
  ) async {
    final results = await Future.wait<Object>([
      growthRepository.fetch(childId),
      vaccinationRepository.fetch(childId),
    ]);
    return _ChildOverviewData(
      results[0] as List<GrowthMeasurement>,
      results[1] as List<Vaccination>,
    );
  }
}

double? _toDouble(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.'));

String _measurementSummary(GrowthMeasurement item) {
  final values = <String>[];
  if (item.weightKg != null) values.add('${item.weightKg} كجم');
  if (item.heightCm != null) values.add('${item.heightCm} سم');
  if (item.headCircumferenceCm != null) values.add('الرأس ${item.headCircumferenceCm} سم');
  return values.isEmpty ? 'قياس بدون قيم' : values.join(' • ');
}

String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

String _age(DateTime? birthDate) {
  if (birthDate == null) return 'العمر غير محدد';
  final days = DateTime.now().difference(birthDate).inDays.clamp(0, 5000);
  if (days < 14) return '$days يومًا';
  if (days < 90) return '${days ~/ 7} أسابيع';
  if (days < 730) return '${days ~/ 30} أشهر';
  return '${days ~/ 365} سنوات';
}

String _feedingLabel(String value) => switch (value) {
  'breast' => 'رضاعة طبيعية',
  'formula' => 'رضاعة صناعية',
  'mixed' => 'رضاعة مختلطة',
  _ => 'نوع الرضاعة غير محدد',
};
