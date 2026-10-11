import 'package:flixquest/models/recently_watched.dart';
import 'package:flixquest/tv/focus/tv_focus_memory.dart';
import 'package:flixquest/tv/models/tv_media_item.dart';
import 'package:flixquest/tv/widgets/tv_content_row.dart';
import 'package:flixquest/tv/widgets/tv_continue_watching_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/tv_localization.dart';

RecentMovie _recentMovie({required int? id, required String title}) =>
    RecentMovie(
      backdropPath: null,
      dateTime: '2026-09-05',
      elapsed: 600000,
      id: id,
      posterPath: null,
      releaseYear: 2024,
      remaining: 3000000,
      title: title,
    );

RecentEpisode _recentEpisode() => RecentEpisode(
      dateTime: '2026-09-05',
      elapsed: 600000,
      episodeName: 'Pilot',
      episodeNum: 4,
      id: 991,
      posterPath: null,
      remaining: 900000,
      seasonNum: 2,
      seriesName: 'Example series',
      seriesId: 77,
    );

/// One [TvContentRow] with the Continue watching wiring, and nothing else.
Widget _rowHarness({
  required List<String> items,
  required ValueChanged<String> onItemActivated,
  ValueChanged<String>? onItemMenu,
  String? itemMenuHint,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TvFocusMemoryScope(
        memory: TvFocusMemory(),
        child: TvContentRow<String>(
          title: 'Continue watching',
          scopeId: 'row',
          items: items,
          itemId: (item) => item,
          semanticLabel: (item) => item,
          autofocus: true,
          itemBuilder: (_, item) => SizedBox(width: 120, child: Text(item)),
          onItemActivated: onItemActivated,
          onItemMenu: onItemMenu,
          itemMenuHint: itemMenuHint,
        ),
      ),
    ),
  );
}

void main() {
  initializeTvTranslations();
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a held OK opens the row menu while a tap still activates',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final activated = <String>[];
    final menus = <String>[];
    await tester.pumpWidget(
      _rowHarness(
        items: const <String>['a', 'b'],
        onItemActivated: activated.add,
        onItemMenu: menus.add,
        itemMenuHint: 'Hold OK to remove',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'row:a');

    // A press short enough to be a press resumes the title.
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(activated, <String>['a']);
    expect(menus, isEmpty);

    // Past Android's long-press timeout it offers the secondary action instead,
    // and only once the key comes back up.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 700));
    expect(menus, isEmpty, reason: 'the menu waits for the key to be released');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(menus, <String>['a']);
    expect(activated, <String>['a'], reason: 'a hold must not also activate');

    // The remote's menu key is the shortcut for anyone whose remote has one.
    await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
    await tester.pump();
    expect(menus, <String>['a', 'a']);

    // Moving away mid-hold abandons it, so the next release is a plain press.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'row:b');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(menus, <String>['a', 'a']);
    expect(activated, <String>['a']);
  });

  testWidgets('the hint only shows itself while the row holds focus',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final focusNode = FocusNode(debugLabel: 'outside');
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              Focus(focusNode: focusNode, child: const SizedBox(height: 20)),
              TvFocusMemoryScope(
                memory: TvFocusMemory(),
                child: TvContentRow<String>(
                  title: 'Continue watching',
                  scopeId: 'row',
                  items: const <String>['a'],
                  itemId: (item) => item,
                  semanticLabel: (item) => item,
                  autofocus: true,
                  itemBuilder: (_, item) =>
                      SizedBox(width: 120, child: Text(item)),
                  onItemActivated: (_) {},
                  onItemMenu: (_) {},
                  itemMenuHint: 'Hold OK to remove',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hint = find.ancestor(
      of: find.text('Hold OK to remove'),
      matching: find.byType(AnimatedOpacity),
    );
    expect(tester.widget<AnimatedOpacity>(hint).opacity, 1);

    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(hint).opacity, 0);
  });

  testWidgets('losing the focused card hands focus to its neighbour',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var items = <String>['a', 'b', 'c'];
    late StateSetter setOuterState;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              setOuterState = setState;
              return TvFocusMemoryScope(
                memory: TvFocusMemory(),
                child: TvContentRow<String>(
                  title: 'Continue watching',
                  scopeId: 'row',
                  items: items,
                  itemId: (item) => item,
                  semanticLabel: (item) => item,
                  autofocus: true,
                  itemBuilder: (_, item) =>
                      SizedBox(width: 120, child: Text(item)),
                  onItemActivated: (_) {},
                  onItemMenu: (_) {},
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'row:b');

    setOuterState(() => items = <String>['a', 'c']);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'row:c',
      reason: 'the card that took the removed slot should keep the remote busy',
    );

    // Removing the last card leaves nothing to fall back to within the row.
    setOuterState(() => items = <String>['a']);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'row:a');
  });

  testWidgets('the confirmation defaults to keeping the entry', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final item =
        TvMediaItem.fromRecentMovie(_recentMovie(id: 42, title: 'Dune'));
    late BuildContext rowContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              rowContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    var confirmed = confirmRemoveFromContinueWatching(
      context: rowContext,
      item: item,
    );
    await tester.pumpAndSettle();
    expect(find.text('Remove from Continue watching?'), findsOneWidget);
    expect(find.textContaining('"Dune"'), findsOneWidget);
    // A stray press must not delete anything, so the safe action holds focus.
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Cancel');

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(await confirmed, isFalse);
    expect(find.text('Remove from Continue watching?'), findsNothing);

    confirmed = confirmRemoveFromContinueWatching(
      context: rowContext,
      item: item,
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Remove');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(await confirmed, isTrue);
  });

  test('a removal carries the keys the recently watched store needs', () {
    expect(
      TvContinueWatchingRemoval.forItem(
        TvMediaItem.fromRecentMovie(_recentMovie(id: 42, title: 'Dune')),
      ),
      const TvContinueWatchingRemoval.movie(42),
    );
    expect(
      TvContinueWatchingRemoval.forItem(
        TvMediaItem.fromRecentEpisode(_recentEpisode()),
      ),
      const TvContinueWatchingRemoval.episode(
        episodeId: 991,
        seasonNumber: 2,
        episodeNumber: 4,
      ),
    );
    // Rows that never came from the store have nothing to remove.
    expect(
      TvContinueWatchingRemoval.forItem(
        TvMediaItem.fromRecentMovie(_recentMovie(id: null, title: 'Dune')),
      ),
      isNull,
    );
  });
}
