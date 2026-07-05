import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/content/development_and_feeding_library.dart';
import 'package:flutter_application_1/content/health_sources.dart';
import 'package:flutter_application_1/content/vaccination_schedule_catalog.dart';

void main() {
  group('official health source catalog', () {
    test('contains required country vaccination sources and global references', () {
      expect(OfficialHealthSources.all, hasLength(greaterThanOrEqualTo(6)));
      expect(
        OfficialHealthSources.vaccinationSourceFor(NumuwCountry.egypt).authority,
        contains('المصرية'),
      );
      expect(
        OfficialHealthSources.vaccinationSourceFor(NumuwCountry.saudiArabia).url,
        startsWith('https://www.moh.gov.sa'),
      );
      expect(
        OfficialHealthSources.vaccinationSourceFor(NumuwCountry.unitedArabEmirates).url,
        startsWith('https://mohap.gov.ae'),
      );
      expect(OfficialHealthSources.whoGrowth.url, contains('who.int'));
      expect(HealthDisclaimer.medicalArabic, contains('لا يشخّص'));
    });
  });

  group('vaccination schedule catalog', () {
    test('supports Egypt, Saudi Arabia, and UAE without invented dose rows', () {
      for (final country in NumuwCountry.values) {
        final schedule = VaccinationScheduleCatalog.forCountry(country);
        expect(schedule, isNotNull);
        expect(schedule!.source.id, isNotEmpty);
        expect(schedule.status, HealthContentStatus.needsSourceExtraction);
        expect(schedule.doses, isEmpty);
      }
    });

    test('scheduled dose status and due date calculation are deterministic', () {
      const dose = VaccineDoseDefinition(
        id: 'test-dose',
        vaccineNameArabic: 'جرعة اختبار',
        doseLabelArabic: 'الأولى',
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
      expect(rows.single.statusArabic, 'متأخر');
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
