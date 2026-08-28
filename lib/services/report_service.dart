import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/formatters/arabic_formatters.dart';
import '../models/care_event.dart';
import '../models/child_profile.dart';
import '../repositories/care_event_repository.dart';
import '../repositories/doctor_question_repository.dart';
import '../repositories/growth_repository.dart';
import '../repositories/vaccination_repository.dart';

class ReportService {
  Future<Uint8List> buildDoctorReport(
    ChildProfile child, {
    Set<String>? sections,
    DateTime? since,
    List<String> additionalQuestions = const [],
  }) async {
    final selected = sections ?? const <String>{};
    bool include(String section) => selected.isEmpty || selected.contains(section);

    final fontData = await rootBundle.load(
      'assets/fonts/NotoNaskhArabic-Regular.ttf',
    );
    final font = pw.Font.ttf(fontData);
    final growth = await GrowthRepository().fetch(child.id);
    final allEvents = await CareEventRepository().fetchRecent(child.id, limit: 160);
    final events = since == null
        ? allEvents
        : allEvents
              .where((event) => !event.startedAt.isBefore(since))
              .toList(growable: false);
    final pumping = events
        .where((event) => event.isPumping && (event.pumpedAmountMl ?? 0) > 0)
        .toList();
    final pumpingTotal = pumping.fold<double>(
      0,
      (sum, event) => sum + (event.pumpedAmountMl ?? 0),
    );
    final pumpingDaily = <DateTime, double>{};
    for (final event in pumping) {
      final local = event.startedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      pumpingDaily[day] =
          (pumpingDaily[day] ?? 0) + (event.pumpedAmountMl ?? 0);
    }
    final vaccinations = await VaccinationRepository().fetch(child.id);
    final savedQuestions = await DoctorQuestionRepository().fetch(child.id);
    final questions = [
      ...savedQuestions.where((question) => !question.isAnswered).map(
        (question) => question.question,
      ),
      ...additionalQuestions.where((question) => question.trim().isNotEmpty),
    ];

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (_) => [
          _h('تقرير متابعة الطفل'),
          _p('نُمُوّ · ${ArabicFormatters.date(DateTime.now())}'),
          if (include('معلومات الطفل والعمر')) ...[
            _h('معلومات الطفل'),
            _p('الطفل: ${child.name}'),
            _p('العمر: ${ArabicFormatters.age(child)}'),
            _p('الجنس: ${ArabicFormatters.gender(child.gender)}'),
            _p('الرضاعة: ${ArabicFormatters.feedingType(child.feedingType)}'),
          ],
          if (include('الوزن والطول')) ...[
            _h('آخر قياسات النمو'),
            if (growth.isEmpty) _p('لا توجد قياسات نمو مسجلة.'),
            ...growth.reversed.take(5).map(
              (item) => _p(
                '${ArabicFormatters.date(item.measuredAt)}: وزن ${item.weightKg ?? '-'} كجم، طول ${item.heightCm ?? '-'} سم، محيط رأس ${item.headCircumferenceCm ?? '-'} سم',
              ),
            ),
          ],
          if (include('الرضاعة')) ...[
            _h('الرضاعة والشفط'),
            _p(
              'الرضعات: ${events.where((event) => event.eventType == 'feeding' && !event.isPumping).length}',
            ),
            _p(
              'جلسات الشفط: ${pumping.length}، الإجمالي ${pumpingTotal.round()} مل، المتوسط ${pumping.isEmpty ? 0 : (pumpingTotal / pumping.length).round()} مل للجلسة',
            ),
            ...pumpingDaily.entries.map(
              (entry) => _p(
                'شفط ${ArabicFormatters.date(entry.key)}: ${entry.value.round()} مل',
              ),
            ),
          ],
          if (include('النوم')) ...[
            _h('النوم'),
            _p('جلسات النوم: ${events.where((event) => event.eventType == 'sleep').length}'),
          ],
          if (include('الحفاضات')) ...[
            _h('الحفاضات'),
            _p('التسجيلات: ${events.where((event) => event.eventType == 'diaper').length}'),
          ],
          if (include('الطعام')) ...[
            _h('الطعام'),
            _p('الوجبات المسجلة: ${events.where((event) => event.eventType == 'food').length}'),
          ],
          if (include('الحرارة')) ...[
            _h('درجة الحرارة'),
            ..._temperatureLines(events),
          ],
          if (include('الأدوية')) ...[
            _h('الأدوية والفيتامينات'),
            ...events
                .where((event) => event.eventType == 'medicine')
                .take(12)
                .map(
                  (event) => _p(
                    '${event.medicineName ?? 'دواء'}${event.medicineDose?.isNotEmpty == true ? ' · ${event.medicineDose}' : ''} · ${ArabicFormatters.date(event.startedAt)}',
                  ),
                ),
          ],
          if (include('التطعيمات')) ...[
            _h('التطعيمات'),
            if (vaccinations.isEmpty) _p('لا توجد تطعيمات مسجلة.'),
            ...vaccinations.map(
              (vaccination) => _p(
                '${vaccination.name} - ${vaccination.status} - ${ArabicFormatters.date(vaccination.scheduledDate)}',
              ),
            ),
          ],
          if (include('الأعراض والملاحظات')) ...[
            _h('الملاحظات'),
            ...events
                .where((event) => event.notes?.isNotEmpty == true)
                .take(16)
                .map(
                  (event) => _p(
                    '${ArabicFormatters.eventType(event.eventType)}: ${event.notes}',
                  ),
                ),
          ],
          if (questions.isNotEmpty) ...[
            _h('أسئلة للطبيب'),
            ...questions.map((question) => _p('• $question')),
          ],
          pw.SizedBox(height: 12),
          _p(
            'هذا التقرير يلخص البيانات التي سجلتها الأسرة ولا يمثل تشخيصًا طبيًا.',
          ),
        ],
      ),
    );
    return doc.save();
  }

  List<pw.Widget> _temperatureLines(List<CareEvent> events) {
    final values = events
        .where(
          (event) =>
              event.eventType == 'temperature' && event.temperatureC != null,
        )
        .toList();
    if (values.isEmpty) return [_p('لا توجد قياسات حرارة مسجلة.')];
    final maximum = values
        .map((event) => event.temperatureC!)
        .reduce((a, b) => a > b ? a : b);
    return [
      _p('عدد القياسات: ${values.length}'),
      _p('أعلى درجة حرارة مسجلة: $maximum°'),
    ];
  }

  pw.Widget _h(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      );

  pw.Widget _p(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 12)),
      );
}

class AssistantService {
  const AssistantService();

  String safetyNotice() =>
      'يمكن للمساعد تنظيم بياناتك وأسئلتك فقط، ولا يقدّم تشخيصًا أو علاجًا. في الطوارئ تواصلي مع الطبيب أو خدمات الطوارئ فورًا.';

  String localSummary(ChildProfile child, List<CareEvent> events) {
    final feeding = events.where((event) => event.eventType == 'feeding').length;
    final sleep = events.where((event) => event.eventType == 'sleep').length;
    final diaper = events.where((event) => event.eventType == 'diaper').length;
    return 'ملخص ${child.name}: رضعات $feeding، نوم $sleep، حفاضات $diaper. استخدمي هذا الملخص لتحضير أسئلتك للطبيب.';
  }
}
