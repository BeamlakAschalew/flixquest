import 'package:flixquest/services/auth_navigation_service.dart';
import 'package:flixquest/services/in_app_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('successful login clears the root authentication route',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: InAppMessagingService.navigatorKey,
        home: const Scaffold(body: Text('authenticated home')),
      ),
    );

    InAppMessagingService.navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('login form')),
      ),
    );
    await tester.pumpAndSettle();

    final navigation = AuthNavigationService.returnToAppRoot(
      tester.element(find.text('login form')),
    );
    await tester.pump();
    await navigation;
    await tester.pumpAndSettle();

    expect(find.text('authenticated home'), findsOneWidget);
    expect(find.text('login form'), findsNothing);
  });

  testWidgets('successful signup clears a nested authentication flow',
      (tester) async {
    final nestedNavigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: InAppMessagingService.navigatorKey,
        home: Navigator(
          key: nestedNavigatorKey,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('fresh account home')),
          ),
        ),
      ),
    );

    nestedNavigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('signup form')),
      ),
    );
    await tester.pumpAndSettle();

    final navigation = AuthNavigationService.returnToAppRoot(
      tester.element(find.text('signup form')),
    );
    await tester.pump();
    await navigation;
    await tester.pumpAndSettle();

    expect(find.text('fresh account home'), findsOneWidget);
    expect(find.text('signup form'), findsNothing);
  });
}
