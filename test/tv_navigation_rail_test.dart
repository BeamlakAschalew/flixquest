import 'package:flixquest/tv/app/tv_design.dart';
import 'package:flixquest/tv/widgets/tv_navigation_rail.dart';
import 'package:flixquest/provider/app_dependency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'FLIXQUEST_API_URL=https://example.com');
  });

  testWidgets('compact navigation rail scrolls instead of overflowing',
      (tester) async {
    const metrics = TvShellMetrics(
      compact: true,
      safeInset: 22,
      railWidth: 88,
      railGap: 22,
      contentPadding: 18,
      navItemHeight: 46,
      navItemGap: 3,
      mediaCardWidth: 220,
    );
    final key = GlobalKey<TvNavigationRailState>();
    final destinations = List<TvNavigationDestination>.generate(
      9,
      (index) => TvNavigationDestination(
        id: 'destination-$index',
        label: 'Destination $index',
        icon: Icons.circle_outlined,
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppDependencyProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 88,
                height: 494,
                child: TvNavigationRail(
                  key: key,
                  destinations: destinations,
                  selectedId: destinations.first.id,
                  autofocusId: destinations.first.id,
                  metrics: metrics,
                  onDestinationSelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    key.currentState!.requestFocus(destinations.last.id);
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
