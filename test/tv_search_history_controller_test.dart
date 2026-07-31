import 'package:flixquest/tv/controllers/tv_search_history_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('normalizes, deduplicates, and caps recent searches', () async {
    SharedPreferences.setMockInitialValues({
      TvSearchHistoryController.preferenceKey: <String>[
        '  The   Bear  ',
        'the bear',
        '',
        'Dune',
      ],
    });
    final preferences = await SharedPreferences.getInstance();
    final history = TvSearchHistoryController(preferences);

    expect(history.load(), ['The Bear', 'Dune']);

    final updated = await history.remember('  DUNE  ');
    expect(updated, ['DUNE', 'The Bear']);
    expect(history.load(), ['DUNE', 'The Bear']);
  });

  test('can remove one entry and clear the history', () async {
    SharedPreferences.setMockInitialValues({
      TvSearchHistoryController.preferenceKey: <String>['Dune', 'The Bear'],
    });
    final preferences = await SharedPreferences.getInstance();
    final history = TvSearchHistoryController(preferences);

    expect(await history.remove(' dune '), ['The Bear']);
    await history.clear();
    expect(history.load(), isEmpty);
  });
}
