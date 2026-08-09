import 'package:flixquest/services/app_session_state_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('restores valid handheld and television destinations', () async {
    SharedPreferences.setMockInitialValues({
      AppSessionStateStore.handheldDestinationKey: 'downloads',
      AppSessionStateStore.televisionDestinationKey: 'library',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = AppSessionStateStore(preferences);

    expect(store.handheldDestination, 'downloads');
    expect(store.televisionDestination, 'library');
  });

  test('ignores stale destination values', () async {
    SharedPreferences.setMockInitialValues({
      AppSessionStateStore.handheldDestinationKey: 'removed-tab',
      AppSessionStateStore.televisionDestinationKey: 'removed-screen',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = AppSessionStateStore(preferences);

    expect(store.handheldDestination, isNull);
    expect(store.televisionDestination, isNull);
  });

  test('only persists known destinations', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = AppSessionStateStore(preferences);

    await store.rememberHandheldDestination('profile');
    await store.rememberTelevisionDestination('settings');
    await store.rememberHandheldDestination('invalid');
    await store.rememberTelevisionDestination('invalid');

    expect(store.handheldDestination, 'profile');
    expect(store.televisionDestination, 'settings');
  });
}
