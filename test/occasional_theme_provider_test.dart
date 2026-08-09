import 'package:flixquest/constants/app_constants.dart';
import 'package:flixquest/models/occasional_theme.dart';
import 'package:flixquest/provider/app_dependency_provider.dart';
import 'package:flixquest/singleton/sharedpreferences_singleton.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(
      fileInput: '''
        TMDB_API_KEY=test
        MIXPANEL_API_KEY=test
        FLIXQUEST_API_URL=https://example.com
      ''',
    );
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPrefsSingleton = await SharedPreferencesSingleton.getInstance();
  });

  test('seasonal themes default on and can be persistently disabled', () async {
    final provider = AppDependencyProvider();
    await provider.getOccasionalTheme();
    provider.occasionalThemeCatalog = OccasionalThemeCatalog.fromJsonString('''
      {
        "schema_version": 2,
        "enabled": true,
        "themes": [
          {"id": "christmas", "enabled": true}
        ]
      }
    ''');

    expect(provider.occasionalThemeEnabled, isTrue);
    expect(provider.activeOccasionalTheme?.id, 'christmas');

    provider.occasionalThemeEnabled = false;
    expect(provider.activeOccasionalTheme, isNull);
    await Future<void>.delayed(Duration.zero);

    final restoredProvider = AppDependencyProvider();
    await restoredProvider.getOccasionalTheme();
    expect(restoredProvider.occasionalThemeEnabled, isFalse);
    expect(restoredProvider.activeOccasionalTheme, isNull);

    provider.dispose();
    restoredProvider.dispose();
  });
}
