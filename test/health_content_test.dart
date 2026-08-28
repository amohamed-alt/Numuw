import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/content/development_and_feeding_library.dart';
import 'package:flutter_application_1/content/health_sources.dart';
import 'package:flutter_application_1/content/vaccination_records.dart';
import 'package:flutter_application_1/content/vaccination_schedule_catalog.dart';
import 'package:flutter_application_1/content/who_growth_standards.dart';

void main() {
  group('official health source catalog', () {
    test('contains required country vaccination sources and global references', () {
      expect(OfficialHealthSources.all, hasLength(greaterThanOrEqualTo(6)));
      expect(OfficialHealthSources.vaccinationSourceFor(NumuwCountry.egypt).id, isNotEmpty);
      expect(
        OfficialHealthSources.vaccinationSourceFor(NumuwCountry.saudiArabia).url,
        startsWith('https://www.moh.gov.sa'),
      );
      expect(
        OfficialHealthSources.vaccinationSourceFor(NumuwCountry.unitedArabEmirates).url,
        startsWith('https://mohap.gov.ae'),
      );
      expect(OfficialHealthSources.whoGrowth.url, contains('who.int'));
      expect(HealthDisclaimer.medicalArabic, isNotEmpty);
    });
  });

  group('vaccination schedule catalog', () {
    test('keeps country schedules source-gated and avoids verified invented rows', () {
      for (final country in NumuwCountry.values) {
        final schedule = VaccinationScheduleCatalog.forCountry(country);
        expect(schedule, isNotNull);
        expect(schedule!.source.id, isNotEmpty);
        expect(schedule.status, isNot(HealthContentStatus.verified));
        if (country == NumuwCountry.egypt) {
          expect(schedule.status, HealthContentStatus.needsClinicalReview);
          expect(schedule.doses, isNotEmpty);
          expect(
            schedule.doses.every((dose) => dose.status == HealthContentStatus.needsClinicalReview),
            isTrue,
          );
        } else {
          expect(schedule.status, HealthContentStatus.needsSourceExtraction);
          expect(schedule.doses, isEmpty);
        }
      }
    });

    test('scheduled dose status and due date calculation are deterministic', () {
      const dose = VaccineDoseDefinition(
        id: 'test-dose',
        vaccineNameArabic: 'test vaccine',
        doseLabelArabic: 'first',
        dueFromBirth: Duration(days: 60),
        sourceId: 'test-source',
      );

      final schedule = VaccinationScheduleDefinition(
        country: NumuwCountry.egypt,
        source: OfficialHealthSources.egyptVaccination,
        doses: const [dose],
      );

      final rows = schedule.buildForBirthDate(
        DateTime(2026, 1, 1),
        today: DateTime(2026, 3, 5),
      );

      expect(rows, hasLength(1));
      expect(rows.single.dueDate, DateTime(2026, 3, 2));
      expect(rows.single.isOverdue, isTrue);
    });

    test('vaccination records drive completed and next dose calculations', () {
      const firstDose = VaccineDoseDefinition(
        id: 'dose-1',
        vaccineNameArabic: 'tracked vaccine',
        doseLabelArabic: 'first',
        dueFromBirth: Duration(days: 0),
        sourceId: 'test-source',
      );
      const secondDose = VaccineDoseDefinition(
        id: 'dose-2',
        vaccineNameArabic: 'tracked vaccine',
        doseLabelArabic: 'second',
        dueFromBirth: Duration(days: 30),
        sourceId: 'test-source',
      );

      final schedule = VaccinationScheduleDefinition(
        country: NumuwCountry.egypt,
        source: OfficialHealthSources.egyptVaccination,
        doses: const [firstDose, secondDose],
      );

      final plan = VaccinationPlan(
        schedule: schedule,
        birthDate: DateTime(2026, 1, 1),
        today: DateTime(2026, 1, 15),
        records: [
          VaccinationRecord(doseId: 'dose-1', givenDate: DateTime(2026, 1, 1)),
        ],
      );

      expect(plan.completedDoseIds, {'dose-1'});
      expect(plan.nextDose?.definition.id, 'dose-2');
      expect(plan.overdueDoses, isEmpty);
      expect(plan.reminderCandidates.single.definition.id, 'dose-2');
    });
  });

  group('WHO growth standards', () {
    test('keeps chart display gated while seeded LMS rows are under review', () {
      expect(WhoGrowthStandards.metadata.source.id, 'who-child-growth-standards');
      expect(WhoGrowthStandards.metadata.indicators, contains(GrowthIndicator.weightForAge));
      expect(WhoGrowthStandards.metadata.indicators, contains(GrowthIndicator.lengthHeightForAge));
      expect(WhoGrowthStandards.metadata.indicators, contains(GrowthIndicator.headCircumferenceForAge));
      expect(WhoGrowthStandards.metadata.canDisplayCharts, isFalse);
      expect(WhoGrowthStandards.lmsRows, isNotEmpty);
      expect(
        WhoGrowthStandards.rowFor(
          indicator: GrowthIndicator.weightForAge,
          sex: ChildSex.female,
          ageMonths: 6,
        ),
        isNotNull,
      );
    });
  });

  group('development and feeding library', () {
    test('returns age-banded activity content', () {
      expect(DevelopmentLibrary.forAgeInMonths(1)?.id, '0-2m');
      expect(DevelopmentLibrary.forAgeInMonths(7)?.id, '6-8m');
      expect(DevelopmentLibrary.forAgeInMonths(18)?.id, '13-24m');
      expect(DevelopmentLibrary.forAgeInMonths(30), isNull);
    });

    test('calculates completed months correctly', () {
      expect(ageInCompletedMonths(DateTime(2026, 1, 15), DateTime(2026, 2, 14)), 0);
      expect(ageInCompletedMonths(DateTime(2026, 1, 15), DateTime(2026, 2, 15)), 1);
      expect(ageInCompletedMonths(DateTime(2026, 1, 15), DateTime(2027, 1, 14)), 11);
    });

    test('feeding library keeps source attribution', () {
      expect(ComplementaryFeedingLibrary.source.id, 'who-iycf');
      expect(ComplementaryFeedingLibrary.sixMonthsArabic, isNotEmpty);
    });
  });
}
