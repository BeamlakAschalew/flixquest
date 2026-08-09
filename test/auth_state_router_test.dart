import 'package:flixquest/screens/user/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mobile changes from landing to home immediately after login',
      (tester) async {
    final userId = ValueNotifier<String?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: AuthStateRouter(
          userIdListenable: userId,
          builder: (_, isAuthenticated) => Text(
            isAuthenticated ? 'mobile home' : 'mobile landing',
          ),
        ),
      ),
    );
    expect(find.text('mobile landing'), findsOneWidget);

    userId.value = 'signed-in-user';
    await tester.pump();

    expect(find.text('mobile home'), findsOneWidget);
    expect(find.text('mobile landing'), findsNothing);
  });

  testWidgets('TV changes from landing to home immediately after login',
      (tester) async {
    final userId = ValueNotifier<String?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: AuthStateRouter(
          userIdListenable: userId,
          builder: (_, isAuthenticated) => Text(
            isAuthenticated ? 'TV home' : 'TV landing',
          ),
        ),
      ),
    );
    expect(find.text('TV landing'), findsOneWidget);

    userId.value = 'signed-in-tv-user';
    await tester.pump();

    expect(find.text('TV home'), findsOneWidget);
    expect(find.text('TV landing'), findsNothing);
  });

  testWidgets('switching from guest to an account rebuilds the home shell',
      (tester) async {
    final userId = ValueNotifier<String?>('anonymous-user');
    var shellGeneration = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AuthStateRouter(
          userIdListenable: userId,
          builder: (_, __) => _SessionShell(
            generation: ++shellGeneration,
          ),
        ),
      ),
    );
    expect(find.text('shell 1'), findsOneWidget);

    userId.value = 'registered-user';
    await tester.pump();

    expect(find.text('shell 2'), findsOneWidget);
    expect(find.text('shell 1'), findsNothing);
  });
}

class _SessionShell extends StatelessWidget {
  const _SessionShell({required this.generation});

  final int generation;

  @override
  Widget build(BuildContext context) => Text('shell $generation');
}
