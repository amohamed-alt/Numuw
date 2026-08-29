import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/design/numuw_motion_widgets.dart';
import 'package:flutter_application_1/design/numuw_organic_icons.dart';

void main() {
  testWidgets('every organic icon renders without exceptions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final icon in NumuwOrganicIconName.values)
                  NumuwOrganicIcon(
                    icon,
                    semanticLabel: 'organic-${icon.name}',
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(NumuwOrganicIcon), findsNWidgets(NumuwOrganicIconName.values.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('organic icon exposes an explicit semantic label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NumuwOrganicIcon(
            NumuwOrganicIconName.breastfeeding,
            semanticLabel: 'رضاعة طبيعية',
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('رضاعة طبيعية'), findsOneWidget);
  });

  testWidgets('motion primitives disable transition durations for reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: NumuwEntrance(
              visible: false,
              child: Text('content'),
            ),
          ),
        ),
      ),
    );

    final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));

    expect(slide.duration, Duration.zero);
    expect(opacity.duration, Duration.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pressable keeps accessible button semantics', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NumuwPressable(
            semanticLabel: 'فتح السجل',
            onTap: () => tapped = true,
            child: const SizedBox(width: 80, height: 48),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('فتح السجل'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('فتح السجل'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
