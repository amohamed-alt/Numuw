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
  Future<Uint8List> buildDoctorReport(ChildProfile child) async {
    final fontData = await rootBundle.load(
      'assets/fonts/NotoNaskhArabic-Regular.ttf',
    );
    final font = pw.Font.ttf(fontData);
    final growth = await GrowthRepository().fetch(child.id);
    final events = await CareEventRepository().fetchRecent(child.id, limit: 80);
    final vaccinations = await VaccinationRepository().fetch(child.id);
    final questions = await DoctorQuestionRepository().fetch(child.id);
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (_) => [
          _h('تقرير نُمُوّ للطبيب'),
          _p('الطفل: ${child.name}'),
          _p('العمر: ${ArabicFormatters.age(child)}'),
          _p('الجنس: ${ArabicFormatters.gender(child.gender)}'),
          _p('الرضاعة: ${ArabicFormatters.feedingType(child.feedingType)}'),
          _h('آخر قياسات النمو'),
          ...growth
              .take(5)
              .map(
                (g) => _p(
                  '${ArabicFormatters.date(g.measuredAt)}: وزن ${g.weightKg ?? '-'} كجم، طول ${g.heightCm ?? '-'} سم، محيط رأس ${g.headCircumferenceCm ?? '-'} سم',
                ),
              ),
          _h('ملخص التسجيلات'),
          _p('رضاعة: ${events.where((e) => e.eventType == 'feeding').length}'),
          _p('نوم: ${events.where((e) => e.eventType == 'sleep').length}'),
          _p('حفاضات: ${events.where((e) => e.eventType == 'diaper').length}'),
          _p(
            'حرارة: ${events.where((e) => e.eventType == 'temperature').length}',
          ),
          _p('أدوية: ${events.where((e) => e.eventType == 'medicine').length}'),
          _h('التطعيمات'),
          ...vaccinations.map(
            (v) => _p(
              '${v.name} - ${v.status} - ${ArabicFormatters.date(v.scheduledDate)}',
            ),
          ),
          _h('ملاحظات وأسئلة للطبيب'),
          ...events
              .where((e) => e.notes?.isNotEmpty == true)
              .take(12)
              .map(
                (e) => _p(
                  '${ArabicFormatters.eventType(e.eventType)}: ${e.notes}',
                ),
              ),
          ...questions
              .where((q) => !q.isAnswered)
              .map((q) => _p('سؤال: ${q.question}')),
          _p('هذا التقرير يعرض بيانات مسجلة من الأم ولا يمثل تشخيصًا طبيًا.'),
        ],
      ),
    );
    return doc.save();
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
      'المساعد الشخصي غير متصل بتحليل طبي آلي الآن. يمكنه تنظيم بياناتك وأسئلتك فقط. في الطوارئ أو صعوبة التنفس أو حرارة عالية أو خمول شديد تواصلي مع الطبيب أو الطوارئ فورًا.';

  String localSummary(ChildProfile child, List<CareEvent> events) {
    final feeding = events.where((e) => e.eventType == 'feeding').length;
    final sleep = events.where((e) => e.eventType == 'sleep').length;
    final diaper = events.where((e) => e.eventType == 'diaper').length;
    return 'ملخص ${child.name}: رضعات $feeding، نوم $sleep، حفاضات $diaper. استخدمي هذا الملخص لتحضير أسئلتك للطبيب.';
  }
}
