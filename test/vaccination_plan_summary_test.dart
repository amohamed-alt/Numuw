import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/content/health_sources.dart';
import 'package:flutter_application_1/content/vaccination_plan_summary.dart';
import 'package:flutter_application_1/content/vaccination_records.dart';
import 'package:flutter_application_1/content/vaccination_schedule_catalog.dart';

void main() {
  test('vaccination summary handles unavailable country schedule safely', () {
    final schedule = VaccinationScheduleDefinition(
      country: NumuwCountry.saudiArabia,
      source: OfficialHealthSources.saudiVaccination,
      doses: const [],
    );

    final plan = VaccinationPlan(
      schedule: schedule,
      birthDate: DateTime(2026, 1, 1),
      today: DateTime(2026, 1, 10),
    );

    expect(plan.summary.totalDoses, 0);
    expect(plan.summary.completionRatio, 0);
    expect(plan.summary.nextActionArabic, contains('مصدر رسمي'));
  });

  test('vaccination summary prioritizes overdue and completion state', () {
    const firstDose = VaccineDoseDefinition(
      id: 'dose-1',
      vaccineNameArabic: 'جرعة أولى',
      doseLabelArabic: 'الأولى',
      dueFromBirth: Duration(days: 0),
      sourceId: 'test-source',
    );
    const secondDose = VaccineDoseDefinition(
      id: 'dose-2',
      vaccineNameArabic: 'جرعة ثانية',
      doseLabelArabic: 'الثانية',
      dueFromBirth: Duration(days: 30),
      sourceId: 'test-source',
    );

    final schedule = VaccinationScheduleDefinition(
      country: NumuwCountry.egypt,
      source: OfficialHealthSources.egyptVaccination,
      doses: const [firstDose, secondDose],
    );

    final overduePlan = VaccinationPlan(
      schedule: schedule,
      birthDate: DateTime(2026, 1, 1),
      today: DateTime(2026, 2, 15),
      records: [
        VaccinationRecord(doseId: 'dose-1', givenDate: DateTime(2026, 1, 1)),
      ],
    );

    expect(overduePlan.summary.totalDoses, 2);
    expect(overduePlan.summary.completedDoses, 1);
    expect(overduePlan.summary.overdueDoses, 1);
    expect(overduePlan.summary.nextActionArabic, contains('متأخرة'));

    final completePlan = overduePlan.copyWithRecord(
      VaccinationRecord(doseId: 'dose-2', givenDate: DateTime(2026, 2, 1)),
    );

    expect(completePlan.summary.isComplete, isTrue);
    expect(completePlan.summary.completionRatio, 1);
    expect(completePlan.summary.nextActionArabic, contains('مكتملة'));
  });
}
