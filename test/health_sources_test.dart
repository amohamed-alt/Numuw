import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/content/health_sources.dart';

void main() {
  group('Arab-country health source registry', () {
    test('covers the configured Arab countries', () {
      expect(NumuwCountry.values.length, 19);
      expect(NumuwCountry.fromIsoCode('eg'), NumuwCountry.egypt);
      expect(NumuwCountry.fromIsoCode('SA'), NumuwCountry.saudiArabia);
      expect(NumuwCountry.fromIsoCode('mr'), NumuwCountry.mauritania);
      expect(NumuwCountry.fromIsoCode(''), isNull);
      expect(NumuwCountry.fromIsoCode('XX'), isNull);
    });

    test('every country has auditable vaccination source metadata', () {
      for (final country in NumuwCountry.values) {
        final source = OfficialHealthSources.vaccinationSourceFor(country);
        expect(source.id, isNotEmpty);
        expect(source.countryIsoCode, country.isoCode);
        expect(source.authority, isNotEmpty);
        expect(source.title, contains(country.arabicName));
        expect(source.url, startsWith('https://'));
        expect(source.versionLabel, isNotEmpty);
        expect(source.notes, isNotEmpty);
      }
    });

    test('global sources remain available', () {
      expect(OfficialHealthSources.whoGrowth.url, contains('who.int'));
      expect(OfficialHealthSources.whoFeeding.url, contains('who.int'));
      expect(OfficialHealthSources.cdcMilestones.url, contains('cdc.gov'));
    });
  });
}
