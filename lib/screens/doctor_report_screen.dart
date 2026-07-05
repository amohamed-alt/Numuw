import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../core/errors/app_error.dart';
import '../services/report_service.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen> {
  static const availableSections = [
    'معلومات الطفل والعمر',
    'الوزن والطول',
    'الرضاعة',
    'النوم',
    'الحفاضات',
    'الطعام',
    'الحرارة',
    'الأدوية',
    'التطعيمات',
    'الأعراض والملاحظات',
  ];

  final Set<String> selectedSections = {...availableSections};
  final List<String> questions = ['هل زيادة الوزن مناسبة للعمر؟'];
  final TextEditingController questionController = TextEditingController();
  String range = 'آخر 7 أيام';
  Uint8List? reportBytes;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  DateTime? get since => switch (range) {
        'آخر 7 أيام' => DateTime.now().subtract(const Duration(days: 7)),
        'آخر 30 يومًا' => DateTime.now().subtract(const Duration(days: 30)),
        _ => null,
      };

  void addQuestion() {
    final value = questionController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      questions.add(value);
      questionController.clear();
    });
  }

  Future<void> generate() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || loading || selectedSections.isEmpty) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final bytes = await ReportService().buildDoctorReport(
        child,
        sections: selectedSections,
        since: since,
        additionalQuestions: questions,
      );
      if (mounted) setState(() => reportBytes = bytes);
    } catch (exception, stackTrace) {
      logError(exception, stackTrace);
      if (mounted) setState(() => error = readableError(exception));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> share() async {
    final bytes = reportBytes;
    if (bytes == null) return;
    await Printing.sharePdf(bytes: bytes, filename: 'numuw-doctor-report.pdf');
  }

  @override
  Widget build(BuildContext context) => reportBytes == null
      ? _ConfigView(
          range: range,
          onRangeChanged: (value) => setState(() => range = value),
          availableSections: availableSections,
          selectedSections: selectedSections,
          onSectionChanged: (section, selected) => setState(() {
            selected ? selectedSections.add(section) : selectedSections.remove(section);
          }),
          questions: questions,
          questionController: questionController,
          onAddQuestion: addQuestion,
          onDeleteQuestion: (index) => setState(() => questions.removeAt(index)),
          loading: loading,
          error: error,
          onGenerate: selectedSections.isEmpty ? null : generate,
        )
      : _PreviewView(
          range: range,
          sectionCount: selectedSections.length,
          questionCount: questions.length,
          onBack: () => setState(() => reportBytes = null),
          onShare: share,
        );
}

class _ConfigView extends StatelessWidget {
  const _ConfigView({
    required this.range,
    required this.onRangeChanged,
    required this.availableSections,
    required this.selectedSections,
    required this.onSectionChanged,
    required this.questions,
    required this.questionController,
    required this.onAddQuestion,
    required this.onDeleteQuestion,
    required this.loading,
    required this.error,
    required this.onGenerate,
  });

  final String range;
  final ValueChanged<String> onRangeChanged;
  final List<String> availableSections;
  final Set<String> selectedSections;
  final void Function(String, bool) onSectionChanged;
  final List<String> questions;
  final TextEditingController questionController;
  final VoidCallback onAddQuestion;
  final ValueChanged<int> onDeleteQuestion;
  final bool loading;
  final String? error;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: numuwPageColor(),
        appBar: AppBar(title: const Text('تقرير زيارة الطبيب')),
        body: AppPage(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('اختاري الفترة الزمنية', style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: ['آخر 7 أيام', 'آخر 30 يومًا', 'كل التسجيلات'].map((value) => ChoicePill(label: value, selected: range == value, onTap: () => onRangeChanged(value))).toList()),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: Text('أقسام التقرير', style: TextStyle(color: numuwTextColor(), fontSize: 18, fontWeight: FontWeight.w900))),
              Text('${selectedSections.length} من ${availableSections.length}', style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 13)),
            ]),
            const SizedBox(height: 12),
            SoftCard(padding: const EdgeInsetsDirectional.symmetric(horizontal: 12), child: Column(children: availableSections.map((section) => SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: Text(section), value: selectedSections.contains(section), onChanged: (value) => onSectionChanged(section, value))).toList())),
            const SizedBox(height: 22),
            Text('أسئلة للطبيب', style: TextStyle(color: numuwTextColor(), fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            SoftCard(child: Column(children: [
              ...List.generate(questions.length, (index) => Row(children: [Expanded(child: Text('• ${questions[index]}')), IconButton(onPressed: () => onDeleteQuestion(index), icon: const Icon(Icons.close_rounded, size: 18))])),
              Row(children: [Expanded(child: TextField(controller: questionController, decoration: const InputDecoration(hintText: 'أضيفي سؤالًا…'), onSubmitted: (_) => onAddQuestion())), const SizedBox(width: 8), IconButton.filled(onPressed: onAddQuestion, icon: const Icon(Icons.add_rounded))]),
            ])),
            if (error != null) ...[const SizedBox(height: 12), ErrorMessageCard(message: error!)],
            const SizedBox(height: 18),
            PrimaryButton(label: 'معاينة التقرير', loading: loading, onPressed: onGenerate),
          ]),
        ),
      );
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({required this.range, required this.sectionCount, required this.questionCount, required this.onBack, required this.onShare});
  final String range;
  final int sectionCount;
  final int questionCount;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: numuwPageColor(),
        appBar: AppBar(title: const Text('معاينة التقرير'), leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_forward_rounded))),
        body: AppPage(child: Column(children: [
          Container(width: double.infinity, padding: const EdgeInsetsDirectional.all(22), decoration: BoxDecoration(color: const Color(0xFFF7F3EA), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 28, offset: Offset(0, 12))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Expanded(child: Text('تقرير متابعة الطفل', style: TextStyle(color: Color(0xFF18222D), fontSize: 20, fontWeight: FontWeight.w900))), Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF0F1923), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.nightlight_round, color: Color(0xFFE8B86D)))]),
            const Divider(height: 28, color: Color(0xFFDDD5C8)),
            _PaperRow('الفترة', range),
            _PaperRow('الأقسام المختارة', '$sectionCount'),
            _PaperRow('أسئلة الطبيب', '$questionCount'),
            const SizedBox(height: 14),
            const Text('هذا التقرير يلخص البيانات التي سجلتها الأسرة ولا يمثل تشخيصًا طبيًا.', style: TextStyle(color: Color(0xFF607080), fontSize: 11, height: 1.5)),
          ])),
          const SizedBox(height: 18),
          PrimaryButton(label: 'مشاركة التقرير', onPressed: onShare),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: onBack, icon: const Icon(Icons.refresh_rounded), label: const Text('إعادة الإنشاء')),
        ])),
      );
}

class _PaperRow extends StatelessWidget {
  const _PaperRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsetsDirectional.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF607080)))), Text(value, style: const TextStyle(color: Color(0xFF18222D), fontWeight: FontWeight.w700))]));
}
