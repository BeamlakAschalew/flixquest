import 'package:flixquest/models/occasional_theme.dart';
import 'package:flixquest/widgets/occasional_effect_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = OccasionalTheme.fromJson(<String, dynamic>{
    'id': 'christmas',
    'enabled': true,
    'effect': <String, dynamic>{
      'enabled': true,
      'type': 'snow',
    },
  });

  testWidgets('renders a non-interactive vector effect when enabled',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.expand(
            child: OccasionalEffectOverlay(theme: theme, enabled: true),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('occasional-effect-canvas')), findsOneWidget);
    expect(find.byType(IgnorePointer), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('does not render when reduced motion is requested',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.expand(
            child: OccasionalEffectOverlay(theme: theme, enabled: true),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('occasional-effect-canvas')), findsNothing);
  });
}
