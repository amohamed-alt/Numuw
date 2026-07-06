import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/content/health_sources.dart';
import 'package:flutter_application_1/content/vaccination_plan_mapper.dart';
import 'package:flutter_application_1/content/vaccination_plan_summary.dart';
import 'package:flutter_application_1/content/vaccination_schedule_catalog.dart';
import 'package:flutter_application_1/models/vaccination.dart';

void main() {
  const firstDose = VaccineDoseDefinition(
    id: 'dose-1',
    vaccineNameArabic: 'طعم الخماسي',
    doseLabelArabic: 'الجرعة الأولى',
    dueFromBirth: Duration(days: 60),
    sourceId: 'source',
  );
  const secondDose = VaccineDoseDefinition(
    id: 'dose-2',
    vaccineNameArabic: 'سابين',
    doseLabelArabic: 'الجرعة الثانية',
    dueFromBirth: Duration(days: 120),
    sourceId: 'source',
  );

  test('mapper links completed Supabase rows with the selected schedule', () {
    final schedule = VaccinationScheduleDefinition(
      country: NumuwCountry.egypt,
      source: OfficialHealthSources.egyptVaccination,
      doses: const [firstDose, secondDose],
    );

    final plan = VaccinationPlanMapper.buildPlan(
      schedule: schedule,
      birthDate: DateTime(2026, 1, 1),
      today: DateTime(2026, 5, 2),
      records: [
        Vaccination(
          id: 'row-1',
          childId: 'child',
          createdBy: 'user',
          name: 'طعم الخماسي',
          doseLabel: 'الجرعة الأولى',
          administeredDate: DateTime(2026, 3, 1),
          provider: 'وحدة صحية',
          status: 'completed',
        ),
      ],
    );

    expect(plan.completedDoseIds, {'dose-1'});
    expect(plan.summary.completedDoses, 1);
    expect(plan.summary.overdueDoses, 1);
  });
}
