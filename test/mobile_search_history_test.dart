import 'package:flixquest/constants/app_constants.dart';
import 'package:flixquest/preferences/setting_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('can remove one mobile search and clear all recent searches', () async {
    SharedPreferences.setMockInitialValues({
      SettingsPreferences.RECENT_SEARCHES: <String>['Dune', 'The Bear'],
    });
    sharedPrefsSingleton = await SharedPreferences.getInstance();
    final preferences = SettingsPreferences();

    await preferences.removeRecentSearch('Dune');
    expect(await preferences.getRecentSearches(), ['The Bear']);

    await preferences.clearRecentSearches();
    expect(await preferences.getRecentSearches(), isEmpty);
  });
}
