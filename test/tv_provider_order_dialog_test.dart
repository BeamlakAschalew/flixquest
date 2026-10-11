import 'dart:async';

import 'package:flixquest/constants/app_constants.dart';
import 'package:flixquest/preferences/setting_preferences.dart';
import 'package:flixquest/provider/settings_provider.dart';
import 'package:flixquest/tv/widgets/tv_list_row.dart';
import 'package:flixquest/tv/widgets/tv_provider_order_dialog.dart';
import 'package:flixquest/video_providers/names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/tv_localization.dart';

Future<void> _openOrder(WidgetTester tester, SettingsProvider settings,
    Future<List<VideoProvider>> Function() loadProviders) async {
  tester.view.physicalSize = const Size(960, 540);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TvListRow(
              label: 'Open order',
              autofocus: true,
              onActivate: () => showTvProviderOrderDialog(
                context,
                loadProviders: loadProviders,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.select);
  await tester.pumpAndSettle();
}

List<String> _displayedOrder(WidgetTester tester) => tester
    .widgetList<TvListRow>(find.descendant(
        of: find.byType(TvProviderOrderContent),
        matching: find.byType(TvListRow)))
    .map((row) => row.label)
    .toList();

Future<void> _select(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.select);
  await tester.pumpAndSettle();
}

void main() {
  initializeTvTranslations();
  TestWidgetsFlutterBinding.ensureInitialized();
  final alpha =
      VideoProvider.scraper(id: 'alpha', name: 'Alpha', alias: 'First source');
  final beta =
      VideoProvider.scraper(id: 'beta', name: 'Beta', alias: 'Second source');

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPrefsSingleton = await SharedPreferences.getInstance();
  });

  testWidgets(
      'remote moves save stable codes and keep focus on the moved source',
      (tester) async {
    final settings = SettingsProvider()
      ..setStreamProviderOrder([beta, VideoProvider.directVixSrc, alpha]);
    await _openOrder(tester, settings, () async => [alpha, beta]);
    expect(_displayedOrder(tester),
        ['Second source', 'VixSrc Direct', 'First source']);
    expect(FocusManager.instance.primaryFocus?.debugLabel,
        'Provider order: Second source');

    await _select(tester);
    expect(find.text('Move earlier'), findsNothing);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Move later');
    await _select(tester);
    expect(_displayedOrder(tester),
        ['VixSrc Direct', 'Second source', 'First source']);
    expect(settings.streamProviderOrder,
        ['direct:vixsrc', 'scraper:beta', 'scraper:alpha']);
    expect(
        sharedPrefsSingleton
            .getStringList(SettingsPreferences.STREAM_PROVIDER_ORDER),
        settings.streamProviderOrder);
    expect(FocusManager.instance.primaryFocus?.debugLabel,
        'Provider order: Second source');

    await _select(tester);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Move earlier');
    await _select(tester);
    expect(_displayedOrder(tester).first, 'Second source');
    await _select(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(settings.streamProviderOrder,
        ['scraper:beta', 'direct:vixsrc', 'scraper:alpha']);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await _select(tester);
    expect(find.text('Move later'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Open order');
    final hydrated = SettingsProvider();
    await hydrated.getStreamProviderOrder();
    expect(
        hydrated.orderStreamProviders([
          alpha,
          beta,
          VideoProvider.directVixSrc
        ]).map((provider) => provider.codeName),
        settings.streamProviderOrder);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed discovery and retry preserve saved priorities',
      (tester) async {
    final settings = SettingsProvider()
      ..setStreamProviderOrder([alpha, beta, VideoProvider.directVixSrc]);
    final saved = settings.streamProviderOrder;
    var calls = 0;
    await _openOrder(tester, settings, () async {
      calls++;
      if (calls == 1) throw StateError('Offline');
      return [beta, alpha];
    });
    expect(_displayedOrder(tester), ['VixSrc Direct']);
    expect(
        find.text('Could not refresh sources. Your saved order is unchanged.'),
        findsOneWidget);
    await _select(tester);
    expect(find.text('Move earlier'), findsNothing);
    expect(settings.streamProviderOrder, saved);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Retry');
    await _select(tester);
    expect(calls, 2);
    expect(_displayedOrder(tester),
        ['First source', 'Second source', 'VixSrc Direct']);
    expect(
        sharedPrefsSingleton
            .getStringList(SettingsPreferences.STREAM_PROVIDER_ORDER),
        saved);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long source catalogs remain visible under remote scrolling',
      (tester) async {
    final sources = List<VideoProvider>.generate(
        16,
        (index) =>
            VideoProvider.scraper(id: 'source$index', name: 'Source $index'));
    await _openOrder(tester, SettingsProvider(), () async => sources);
    for (var step = 0; step < 15; step++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel,
        'Provider order: Source 15');
    final bounds = tester.getRect(find.text('Source 15'));
    expect(bounds.top, greaterThan(28));
    expect(bounds.bottom, lessThan(512));
    await _select(tester);
    expect(
        find.text('Priority 16 of 17. Sources are tried from top to bottom.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing while discovery is pending ignores its late result',
      (tester) async {
    final result = Completer<List<VideoProvider>>();
    await _openOrder(tester, SettingsProvider(), () => result.future);
    expect(find.text('Loading sources…'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    result.complete([alpha, beta]);
    await tester.pumpAndSettle();
    expect(find.byType(TvProviderOrderContent), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
