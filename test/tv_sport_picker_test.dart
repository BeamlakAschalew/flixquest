import 'package:easy_localization/easy_localization.dart';
import 'package:flixquest/functions/live_sport_preferences.dart';
import 'package:flixquest/tv/widgets/tv_list_row.dart';
import 'package:flixquest/tv/widgets/tv_sport_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/tv_localization.dart';

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

/// Opens the picker from a focused row, the way a remote would, and returns
/// a holder the result lands in once the dialog closes.
Future<List<Set<String>?>> _open(
  WidgetTester tester, {
  Set<String> initial = const <String>{},
  bool firstTime = true,
}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final results = <Set<String>?>[];
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TvListRow(
          label: 'Open sports',
          autofocus: true,
          onActivate: () async => results.add(await showTvSportPicker(
            context,
            initial: initial,
            firstTime: firstTime,
          )),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  await _press(tester, LogicalKeyboardKey.select);
  return results;
}

String? get _focused => FocusManager.instance.primaryFocus?.debugLabel;

/// Down until a button has focus, then along to [label].
Future<void> _focusButton(WidgetTester tester, String label) async {
  const buttons = <String>{'Save', 'Skip', 'Cancel'};
  for (var i = 0; i < liveSports.length && !buttons.contains(_focused); i++) {
    await _press(tester, LogicalKeyboardKey.arrowDown);
  }
  for (var i = 0; i < 2 && _focused != label; i++) {
    await _press(
        tester,
        label == 'Save'
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.arrowRight);
  }
  expect(_focused, label);
}

/// The sport whose button has focus, by the name the remote reads out.
String _focusedSport() =>
    liveSports.firstWhere((sport) => tr(sport.labelKey) == _focused).id;

void main() {
  initializeTvTranslations();

  testWidgets('the remote starts on the first sport and toggles with select',
      (tester) async {
    final results = await _open(tester);
    expect(find.text('Which sports do you follow?'), findsOneWidget);
    expect(_focused, 'Football (Soccer)');

    // On, along, on and off again, down a row, on.
    await _press(tester, LogicalKeyboardKey.select);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused, 'Basketball');
    await _press(tester, LogicalKeyboardKey.select);
    await _press(tester, LogicalKeyboardKey.select);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    final third = _focusedSport();
    await _press(tester, LogicalKeyboardKey.select);

    await _focusButton(tester, 'Save');
    await _press(tester, LogicalKeyboardKey.select);

    expect(results.single, <String>{'soccer', third});
    expect(_focused, 'Open sports');
    expect(tester.takeException(), isNull);
  });

  testWidgets('first time, Skip and Back both answer with no sports',
      (tester) async {
    var results = await _open(tester, initial: <String>{'tennis'});
    await _press(tester, LogicalKeyboardKey.escape);
    expect(results.single, isNull);

    results = await _open(tester, initial: <String>{'tennis'});
    await _focusButton(tester, 'Skip');
    await _press(tester, LogicalKeyboardKey.select);
    expect(results.single, isEmpty);
  });

  testWidgets('editing offers Cancel, which keeps the saved sports',
      (tester) async {
    final results =
        await _open(tester, initial: <String>{'tennis'}, firstTime: false);
    expect(find.text('Skip'), findsNothing);
    await _focusButton(tester, 'Cancel');
    await _press(tester, LogicalKeyboardKey.select);
    expect(results.single, isNull);
  });
}
