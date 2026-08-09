import 'package:flixquest/services/auth_navigation_service.dart';
import 'package:flixquest/services/auth_session_controller.dart';
import 'package:flixquest/services/in_app_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(
    () => AuthSessionController.instance.setAuthenticatedUserId(null),
  );

  testWidgets('successful login restores the auth gate after legacy logout',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: InAppMessagingService.navigatorKey,
        home: const Scaffold(body: Text('authenticated home')),
      ),
    );

    // This reproduces the old mobile logout behavior that replaced UserState's
    // root route with a standalone landing page.
    InAppMessagingService.navigatorKey.currentState!
        .pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('standalone landing')),
      ),
    );
    await tester.pumpAndSettle();

    InAppMessagingService.navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('login form')),
      ),
    );
    await tester.pumpAndSettle();

    final navigation = AuthNavigationService.returnToAppRoot(
      tester.element(find.text('login form')),
      authenticatedUserId: 'mobile-user',
    );
    await tester.pump();
    await navigation;
    await tester.pumpAndSettle();

    expect(find.text('authenticated home'), findsOneWidget);
    expect(find.text('standalone landing'), findsNothing);
    expect(find.text('login form'), findsNothing);
    expect(AuthSessionController.instance.userId.value, 'mobile-user');
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
      authenticatedUserId: 'tv-user',
    );
    await tester.pump();
    await navigation;
    await tester.pumpAndSettle();

    expect(find.text('fresh account home'), findsOneWidget);
    expect(find.text('signup form'), findsNothing);
    expect(AuthSessionController.instance.userId.value, 'tv-user');
  });
}
