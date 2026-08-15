import 'package:flixquest/tv/navigation/tv_back_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('last Back layer asks before exiting the TV app', (tester) async {
    var exitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: TvBackDispatcher(
          onBack: () => false,
          onExit: () => exitCount++,
          child: const Scaffold(
            body: Focus(autofocus: true, child: Text('TV home')),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Exit FlixQuest?'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Cancel');
    expect(exitCount, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Exit FlixQuest?'), findsNothing);
    expect(find.text('TV home'), findsOneWidget);
    expect(exitCount, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(exitCount, 1);
  });

  testWidgets('handled Back does not show the exit confirmation',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TvBackDispatcher(
          onBack: () => true,
          child: const Scaffold(
            body: Focus(autofocus: true, child: Text('Nested TV screen')),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Exit FlixQuest?'), findsNothing);
    expect(find.text('Nested TV screen'), findsOneWidget);
  });
}
