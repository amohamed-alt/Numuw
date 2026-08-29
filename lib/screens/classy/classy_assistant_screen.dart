import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../core/formatters/arabic_formatters.dart';
import '../../models/ai_assistant_response.dart';
import '../../models/care_event.dart';
import '../../models/doctor_question.dart';
import '../../models/vaccination.dart';
import '../../repositories/care_event_repository.dart';
import '../../repositories/doctor_question_repository.dart';
import '../../repositories/vaccination_repository.dart';
import '../../services/ai_assistant_service.dart';
import '../../state/child_session.dart';
import '../../state/numuw_app_state.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/icons/numuw_icon.dart';
import '../../widgets/numuw_classy_components.dart';
import '../../widgets/numuw_motion_widgets.dart';
import '../main_shell.dart';

/// Production assistant backed by the authenticated Supabase AI edge function.
/// Parsed care events always require an explicit user review/save action.
class ClassyAssistantScreen extends StatefulWidget {
  const ClassyAssistantScreen({super.key, this.service});

  final AiAssistantService? service;

  @override
  State<ClassyAssistantScreen> createState() => _ClassyAssistantScreenState();
}

class _ClassyAssistantScreenState extends State<ClassyAssistantScreen> {
  late final AiAssistantService _ai;
  final _careRepo = CareEventRepository();
  final _questionRepo = DoctorQuestionRepository();
  final _vaccinationRepo = VaccinationRepository();
  final _input = TextEditingController();

  bool _loading = false;
  bool _emergency = false;
  String? _error;
  String? _notice;
  AiAssistantResponse? _response;
  String _composerMode = 'log';
  final Set<int> _savedDrafts = <int>{};

  @override
  void initState() {
    super.initState();
    _ai = widget.service ?? AiAssistantService();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _text => _dark ? AppColors.nightText : AppColors.text;
  Color get _secondary =>
      _dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
  Color get _accent =>
      _dark ? AppColors.nightPrimaryStrong : AppColors.plum;

  Future<List<CareEvent>> _events() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return const <CareEvent>[];
    return _careRepo.fetchRecent(child.id, limit: 80);
  }

  Future<void> _dailySummary() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    await _run(() async {
      final response = await _ai.dailySummary(
        child: child,
        events: await _events(),
        now: DateTime.now(),
        locale: Localizations.localeOf(context),
      );
      if (mounted) setState(() => _response = response);
    });
  }

  Future<void> _doctorSummary() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null) return;
    await _run(() async {
      final values = await Future.wait<Object>([
        _events(),
        _questionRepo.fetch(child.id),
        _vaccinationRepo.fetch(child.id),
      ]);
      final response = await _ai.doctorSummary(
        child: child,
        events: values[0] as List<CareEvent>,
        questions: values[1] as List<DoctorQuestion>,
        vaccinations: values[2] as List<Vaccination>,
        now: DateTime.now(),
        locale: Localizations.localeOf(context),
      );
      if (mounted) setState(() => _response = response);
    });
  }

  Future<void> _submitComposer() async {
    final child = ChildSession.instance.selectedChild;
    final text = _input.text.trim();
    if (child == null || text.isEmpty || _loading) return;

    if (_composerMode == 'question') {
      await _run(() async {
        await _questionRepo.add(childId: child.id, question: text);
        if (!mounted) return;
        setState(() {
          _input.clear();
          _notice = 'تم حفظ السؤال داخل ملف الطفل ليظهر في تقرير الطبيب.';
        });
      });
      return;
    }

    await _run(() async {
      final response = await _ai.parseCareEvent(
        child: child,
        text: text,
        now: DateTime.now(),
        locale: Localizations.localeOf(context),
      );
      if (!mounted) return;
      setState(() {
        _input.clear();
        _response = response;
        _savedDrafts.clear();
      });
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
      _notice = null;
      _emergency = false;
    });
    try {
      await action();
    } on EmergencyDetectedException {
      if (mounted) setState(() => _emergency = true);
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveDraft(int index, AiCareEventDraft draft) async {
    if (_savedDrafts.contains(index)) return;
    if (draft.hasAmbiguousTime) {
      setState(
        () => _notice =
            'راجعي التاريخ والوقت يدويًا قبل الحفظ لأن المساعد غير متأكد منهما.',
      );
      return;
    }

    final metadata = <String, dynamic>{
      if (draft.foodName != null) 'food_name': draft.foodName,
      if (draft.pumpingLeftAmountMl != null)
        'left_amount_ml': draft.pumpingLeftAmountMl,
      if (draft.pumpingRightAmountMl != null)
        'right_amount_ml': draft.pumpingRightAmountMl,
      if (draft.eventType == 'pumping' &&
          (draft.pumpingLeftAmountMl != null ||
              draft.pumpingRightAmountMl != null))
        'quantity_mode': 'split',
      if (draft.eventType == 'feeding' && draft.feedingMethods.isNotEmpty)
        'feeding_methods': draft.feedingMethods,
    };

    try {
      await NumuwAppState.instance.saveCareEvent(
        eventType: draft.eventType,
        startedAt: draft.startedAt ?? DateTime.now(),
        endedAt: draft.endedAt,
        side: draft.side,
        feedingMethod:
            draft.feedingMethods.isEmpty ? null : draft.feedingMethods.first,
        amountMl: draft.amountMl,
        diaperWet: draft.diaperWet,
        diaperDirty: draft.diaperDirty,
        temperatureC: draft.temperatureC,
        medicineName: draft.medicineName,
        medicineDose: draft.medicineDose,
        burped: draft.burped,
        vomited: draft.vomited,
        notes: draft.notes,
        metadata: metadata,
      );
      if (!mounted) return;
      setState(() {
        _savedDrafts.add(index);
        _notice = 'تم حفظ التسجيل بعد مراجعتك.';
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    return Scaffold(
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(childName: child?.name),
            const SizedBox(height: 14),
            const _SafetyBanner(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    asset: NumuwIcons.weeklyReport,
                    title: 'ملخص اليوم',
                    subtitle: 'من بيانات الطفل المسجلة',
                    onTap: child == null || _loading ? null : _dailySummary,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _ActionCard(
                    asset: NumuwIcons.doctorReport,
                    title: 'ملخص للطبيب',
                    subtitle: 'بيانات + أسئلة + تطعيمات',
                    onTap: child == null || _loading ? null : _doctorSummary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_emergency) ...[
              _EmergencyCard(
                onManualLog: () =>
                    MainShellScope.maybeOf(context)?.selectTab(1),
              ),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              _InfoCard(
                asset: NumuwIcons.info,
                message: _error!,
                danger: true,
              ),
              const SizedBox(height: 12),
            ],
            if (_notice != null) ...[
              _InfoCard(asset: NumuwIcons.check, message: _notice!),
              const SizedBox(height: 12),
            ],
            _ResultPanel(
              response: _response,
              loading: _loading,
              savedDrafts: _savedDrafts,
              onSaveDraft: _saveDraft,
            ),
            const SizedBox(height: 12),
            _ModePicker(
              value: _composerMode,
              onChanged: (value) => setState(() => _composerMode = value),
            ),
            const SizedBox(height: 8),
            _Composer(
              controller: _input,
              enabled: child != null && !_loading,
              mode: _composerMode,
              onSend: _submitComposer,
              onManualLog: () =>
                  MainShellScope.maybeOf(context)?.selectTab(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.childName});
  final String? childName;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: .10),
          ),
          child: NumuwIcon(NumuwIcons.assistant, size: 26, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اسألي المساعد',
                style: TextStyle(
                  color: text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                childName == null
                    ? 'اختاري طفلًا أولًا'
                    : 'مساعدة آمنة مبنية على بيانات $childName',
                style: TextStyle(color: secondary, fontSize: 11.2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Container(
      padding: const EdgeInsetsDirectional.all(13),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: .15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwIcon(NumuwIcons.privacy, size: 21, color: accent),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'المساعد ينظّم البيانات ولا يشخّص أو يصف دواءً أو يغيّر جرعة أو يؤكد أن الطفل بخير. علامات الخطر تحتاج طبيبًا أو طوارئ فورًا.',
              style: TextStyle(
                color: text,
                fontSize: 10.8,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String asset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return Opacity(
      opacity: onTap == null ? .55 : 1,
      child: NumuwClassySurface(
        onTap: onTap,
        padding: const EdgeInsetsDirectional.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumuwIcon(asset, size: 25, color: accent),
            const SizedBox(height: 9),
            Text(
              title,
              style: TextStyle(
                color: text,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: secondary,
                fontSize: 9.8,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.response,
    required this.loading,
    required this.savedDrafts,
    required this.onSaveDraft,
  });

  final AiAssistantResponse? response;
  final bool loading;
  final Set<int> savedDrafts;
  final Future<void> Function(int, AiCareEventDraft) onSaveDraft;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final value = response;

    return NumuwClassySurface(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: loading
            ? SizedBox(
                key: const ValueKey('loading'),
                height: 130,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NumuwIcon(
                        NumuwIcons.voiceWave,
                        size: 34,
                        color: accent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'براجع البيانات بأمان...',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : value == null
                ? SizedBox(
                    key: const ValueKey('empty'),
                    height: 130,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NumuwIcon(
                            NumuwIcons.logoMark,
                            size: 35,
                            color: secondary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'اختاري ملخصًا أو اكتبي تسجيلًا ذكيًا',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    key: ValueKey(value.hashCode),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (value.message.trim().isNotEmpty)
                        Text(
                          value.message,
                          style: TextStyle(
                            color: text,
                            fontSize: 12.5,
                            height: 1.65,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      for (final section in value.sections) ...[
                        const SizedBox(height: 12),
                        if (section.title.isNotEmpty)
                          Text(
                            section.title,
                            style: TextStyle(
                              color: text,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        const SizedBox(height: 5),
                        for (final item in section.items)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(bottom: 4),
                            child: Text(
                              '• $item',
                              style: TextStyle(
                                color: secondary,
                                fontSize: 10.8,
                                height: 1.45,
                              ),
                            ),
                          ),
                      ],
                      if (value.actions.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          'مراجعة قبل الحفظ',
                          style: TextStyle(
                            color: text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var i = 0; i < value.actions.length; i++) ...[
                          _DraftCard(
                            draft: value.actions[i],
                            saved: savedDrafts.contains(i),
                            onSave: () => onSaveDraft(i, value.actions[i]),
                          ),
                          if (i != value.actions.length - 1)
                            const SizedBox(height: 8),
                        ],
                      ],
                      if (value.disclaimer?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        _InfoCard(
                          asset: NumuwIcons.info,
                          message: value.disclaimer!,
                        ),
                      ],
                      ..._sourceWidgets(context, value.raw),
                    ],
                  ),
      ),
    );
  }

  List<Widget> _sourceWidgets(
    BuildContext context,
    Map<String, dynamic> raw,
  ) {
    final sourceData = raw['sources'] ?? raw['references'];
    if (sourceData is! List || sourceData.isEmpty) return const <Widget>[];
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.nightSecondaryText
        : AppColors.secondaryText;
    return <Widget>[
      const SizedBox(height: 12),
      Row(
        children: [
          NumuwIcon(NumuwIcons.source, size: 16, color: secondary),
          const SizedBox(width: 6),
          Text(
            'المصادر',
            style: TextStyle(
              color: secondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      for (final source in sourceData.take(5))
        Text(
          '• ${_sourceLabel(source)}',
          style: TextStyle(
            color: secondary,
            fontSize: 9.8,
            height: 1.4,
          ),
        ),
    ];
  }

  String _sourceLabel(Object? source) {
    if (source is Map) {
      final map = Map<String, dynamic>.from(source);
      return '${map['title'] ?? map['name'] ?? map['url'] ?? ''}';
    }
    return '$source';
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.saved,
    required this.onSave,
  });

  final AiCareEventDraft draft;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    final border = dark ? AppColors.nightBorder : AppColors.border;
    final details = <String>[
      if (draft.startedAt != null)
        'الوقت ${ArabicFormatters.time(draft.startedAt)}',
      if (draft.amountMl != null) '${draft.amountMl!.round()} مل',
      if (draft.temperatureC != null) '${draft.temperatureC}°',
      if (draft.side != null) 'الجهة ${draft.side}',
      if (draft.foodName != null) draft.foodName!,
      if (draft.medicineName != null) draft.medicineName!,
      if (draft.notes != null) draft.notes!,
    ];

    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
        color: dark ? AppColors.nightSurfaceRaised : AppColors.surfaceRaised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              NumuwIcon(
                _draftAsset(draft.eventType),
                size: 20,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ArabicFormatters.eventType(draft.eventType),
                  style: TextStyle(
                    color: text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (draft.needsReview || draft.hasAmbiguousTime)
                const Text(
                  'راجعي',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              details.join(' · '),
              style: TextStyle(
                color: secondary,
                fontSize: 10.3,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 10),
          NumuwClassyButton(
            label: saved
                ? 'تم الحفظ'
                : (draft.hasAmbiguousTime
                    ? 'راجعي الوقت يدويًا'
                    : 'حفظ بعد المراجعة'),
            size: NumuwButtonSize.small,
            variant: saved
                ? NumuwButtonVariant.tonal
                : NumuwButtonVariant.primary,
            onPressed: saved || draft.hasAmbiguousTime ? null : onSave,
          ),
        ],
      ),
    );
  }
}

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'تسجيل ذكي',
              asset: NumuwIcons.microphone,
              selected: value == 'log',
              onTap: () => onChanged('log'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeButton(
              label: 'سؤال للطبيب',
              asset: NumuwIcons.doctor,
              selected: value == 'question',
              onTap: () => onChanged('question'),
            ),
          ),
        ],
      );
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String asset;
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
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? accent : border),
          color: selected ? accent.withValues(alpha: .08) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumuwIcon(
              asset,
              size: 17,
              color: selected ? accent : text,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? accent : text,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.mode,
    required this.onSend,
    required this.onManualLog,
  });

  final TextEditingController controller;
  final bool enabled;
  final String mode;
  final VoidCallback onSend;
  final VoidCallback onManualLog;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final secondary =
        dark ? AppColors.nightSecondaryText : AppColors.secondaryText;
    final accent = dark ? AppColors.nightPrimaryStrong : AppColors.plum;
    return NumuwClassySurface(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: mode == 'log'
                        ? 'مثال: رضع 15 دقيقة من اليمين الساعة 2...'
                        : 'اكتبي السؤال الذي تريدين حفظه للطبيب...',
                    hintStyle: TextStyle(color: secondary, fontSize: 11),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: text,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                  onSubmitted: (_) {
                    if (enabled) onSend();
                  },
                ),
              ),
              const SizedBox(width: 8),
              NumuwPressable(
                onTap: enabled ? onSend : null,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: enabled
                        ? accent
                        : accent.withValues(alpha: .35),
                  ),
                  child: NumuwIcon(
                    NumuwIcons.check,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (mode == 'log') ...[
            const SizedBox(height: 5),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onManualLog,
                child: const Text('أو افتحي التسجيل اليدوي'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onManualLog});
  final VoidCallback onManualLog;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.all(14),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.danger.withValues(alpha: .25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NumuwIcon(
                  NumuwIcons.emergency,
                  size: 23,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'الوصف يحتوي علامة خطر محتملة. لا تنتظري رد المساعد؛ تواصلي مع الطبيب أو الطوارئ المحلية فورًا.',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 11.5,
                      height: 1.55,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            NumuwClassyButton(
              label: 'فتح التسجيل اليدوي فقط',
              variant: NumuwButtonVariant.danger,
              size: NumuwButtonSize.small,
              onPressed: onManualLog,
            ),
          ],
        ),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.asset,
    required this.message,
    this.danger = false,
  });
  final String asset;
  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? AppColors.nightText : AppColors.text;
    final accent = danger
        ? AppColors.danger
        : (dark ? AppColors.nightPrimaryStrong : AppColors.plum);
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: .15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumuwIcon(asset, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: text, fontSize: 10.6, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

String _draftAsset(String type) => switch (type) {
      'feeding' => NumuwIcons.feeding,
      'pumping' => NumuwIcons.pumping,
      'sleep' => NumuwIcons.sleep,
      'diaper' => NumuwIcons.diaper,
      'food' => NumuwIcons.food,
      'medicine' => NumuwIcons.medicine,
      'temperature' => NumuwIcons.temperature,
      _ => NumuwIcons.note,
    };
