import 'vaccination_records.dart';

class VaccinationPlanSummary {
  const VaccinationPlanSummary({
    required this.totalDoses,
    required this.completedDoses,
    required this.overdueDoses,
    required this.dueTodayDoses,
    required this.upcomingDoses,
    required this.nextActionArabic,
  });

  final int totalDoses;
  final int completedDoses;
  final int overdueDoses;
  final int dueTodayDoses;
  final int upcomingDoses;
  final String nextActionArabic;

  int get pendingDoses => totalDoses - completedDoses;

  double get completionRatio =>
      totalDoses == 0 ? 0 : completedDoses / totalDoses;

  bool get hasOverdue => overdueDoses > 0;
  bool get hasDueToday => dueTodayDoses > 0;
  bool get isComplete => totalDoses > 0 && completedDoses == totalDoses;
}

extension VaccinationPlanProgress on VaccinationPlan {
  VaccinationPlanSummary get summary {
    final rows = scheduledDoses;
    final overdue = rows.where((row) => row.isOverdue && !row.completed).length;
    final dueToday = rows.where((row) => row.isDueToday && !row.completed).length;
    final upcoming = rows.where((row) => row.isUpcoming && !row.completed).length;
    final completed = rows.where((row) => row.completed).length;

    return VaccinationPlanSummary(
      totalDoses: rows.length,
      completedDoses: completed,
      overdueDoses: overdue,
      dueTodayDoses: dueToday,
      upcomingDoses: upcoming,
      nextActionArabic: _nextActionArabic(
        total: rows.length,
        completed: completed,
        overdue: overdue,
        dueToday: dueToday,
        nextDoseName: nextDose == null
            ? null
            : '${nextDose!.definition.vaccineNameArabic} — ${nextDose!.definition.doseLabelArabic}',
      ),
    );
  }
}

String _nextActionArabic({
  required int total,
  required int completed,
  required int overdue,
  required int dueToday,
  required String? nextDoseName,
}) {
  if (total == 0) {
    return 'اختاري الدولة وسيظهر الجدول بعد مراجعته من مصدر رسمي.';
  }
  if (completed == total) {
    return 'كل الجرعات المسجلة في الخطة مكتملة. راجعي الطبيب لأي جرعات موسمية أو خاصة.';
  }
  if (overdue > 0) {
    return 'توجد جرعات متأخرة. راجعي أقرب وحدة صحية أو طبيب الأطفال لتحديد التصرف الصحيح.';
  }
  if (dueToday > 0) {
    return 'توجد جرعة مستحقة اليوم. أكدي الموعد مع الجهة الصحية قبل الذهاب.';
  }
  return nextDoseName == null
      ? 'لا توجد جرعة قادمة محددة في الخطة الحالية.'
      : 'الجرعة القادمة: $nextDoseName.';
}
