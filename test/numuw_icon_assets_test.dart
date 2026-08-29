import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/widgets/icons/numuw_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every registered Numuw icon is bundled as a non-empty SVG', () async {
    expect(NumuwIcons.all.length, greaterThanOrEqualTo(60));
    for (final asset in NumuwIcons.all) {
      final source = await rootBundle.loadString(asset);
      expect(source.trim(), isNotEmpty, reason: asset);
      expect(source.contains('<svg'), isTrue, reason: '$asset is not SVG');
      expect(source.contains('</svg>'), isTrue, reason: '$asset is incomplete');
    }
  });
}
