import 'package:flixquest/provider/app_dependency_provider.dart';
import 'package:flixquest/provider/settings_provider.dart';
import 'package:flixquest/tv/app/tv_design.dart';
import 'package:flixquest/tv/focus/tv_focus_memory.dart';
import 'package:flixquest/tv/focus/tv_screen_focus_controller.dart';
import 'package:flixquest/tv/screens/tv_search_screen.dart';
import 'package:flixquest/tv/screens/tv_settings_screen.dart';
import 'package:flixquest/tv/widgets/tv_content_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  setUpAll(() {
    dotenv.testLoad(
      fileInput: '''
        TMDB_API_KEY=test
        MIXPANEL_API_KEY=test
        FLIXQUEST_API_URL=https://example.com
      ''',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('content grid enters predictably and contains edge navigation',
      (tester) async {
    tester.view.physicalSize = const Size(960, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = TvContentGridController()..requestFocus();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 620,
              height: 500,
              child: TvFocusMemoryScope(
                memory: TvFocusMemory(),
                child: TvContentGrid<int>(
                  controller: controller,
                  scopeId: 'test-grid',
                  items: List<int>.generate(5, (index) => index),
                  itemId: (item) => '$item',
                  semanticLabel: (item) => 'Item $item',
                  targetItemWidth: 250,
                  itemBuilder: (_, item, width) => SizedBox(
                    width: width,
                    child: Text('Item $item'),
                  ),
                  onItemActivated: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(FocusManager.instance.primaryFocus?.debugLabel, 'test-grid:0');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'test-grid:1');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'test-grid:1');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'test-grid:3');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'test-grid:3');
    expect(tester.takeException(), isNull);
  });

  testWidgets('search remote arrows and back leave text entry with focus',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final focusController = TvScreenFocusController()..requestFocus();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AppDependencyProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TvSearchScreen(
              metrics: metrics,
              focusController: focusController,
              onOpenMedia: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(FocusManager.instance.primaryFocus?.debugLabel, 'TV search query');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'TV search action');

    focusController.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'TV search action');
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings entry and dialog back restore the originating tile',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final focusController = TvScreenFocusController()..requestFocus();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AppDependencyProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TvSettingsScreen(
              metrics: metrics,
              focusController: focusController,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'TV setting theme mode',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text('Choose how FlixQuest looks on this TV.'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Choose how FlixQuest looks on this TV.'), findsNothing);
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'TV setting theme mode',
    );
    expect(tester.takeException(), isNull);
  });
}
