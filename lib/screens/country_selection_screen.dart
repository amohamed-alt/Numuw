import 'package:flutter/material.dart';

import '../content/health_sources.dart';
import '../state/country_preference.dart';
import '../widgets/app_widgets.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() =>
      _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final selected = CountryPreference.instance.country;
    final countries = NumuwCountry.values
        .where(
          (country) => country.arabicName.contains(query.trim()) ||
              country.isoCode.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('الدولة')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'ابحثي عن الدولة',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            InfoBanner(
              message:
                  'اختيار الدولة يحدد مصادر التطعيمات والمحتوى المحلي. لا يُعرض أي جدول غير مراجع.',
              icon: Icons.public_rounded,
            ),
            const SizedBox(height: 14),
            for (final country in countries) ...[
              SoftCard(
                onTap: () async {
                  await CountryPreference.instance.setCountry(country);
                  if (context.mounted) setState(() {});
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          numuwAccentColor().withValues(alpha: .13),
                      child: Text(
                        country.isoCode,
                        style: TextStyle(
                          color: numuwAccentColor(),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        country.arabicName,
                        style: TextStyle(
                          color: numuwTextColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (selected == country)
                      Icon(Icons.check_circle_rounded, color: numuwAccentColor())
                    else
                      Icon(
                        Icons.chevron_left_rounded,
                        color: numuwSecondaryTextColor(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
