import 'package:shared_preferences/shared_preferences.dart';

/// Persists the small amount of UI state needed to resume after process death.
class AppSessionStateStore {
  AppSessionStateStore(this._preferences);

  static const handheldDestinationKey = 'app_session.handheld_destination.v1';
  static const televisionDestinationKey =
      'app_session.television_destination.v1';

  static const handheldDestinations = <String>{
    'movies',
    'series',
    'discover',
    'bookmarks',
    'downloads',
    'profile',
  };

  static const televisionDestinations = <String>{
    'home',
    'search',
    'movies',
    'series',
    'live',
    'library',
    'profile',
    'settings',
  };

  final SharedPreferences _preferences;

  String? get handheldDestination => _validatedDestination(
        handheldDestinationKey,
        handheldDestinations,
      );

  String? get televisionDestination => _validatedDestination(
        televisionDestinationKey,
        televisionDestinations,
      );

  Future<void> rememberHandheldDestination(String destinationId) async {
    if (!handheldDestinations.contains(destinationId)) return;
    await _preferences.setString(handheldDestinationKey, destinationId);
  }

  Future<void> rememberTelevisionDestination(String destinationId) async {
    if (!televisionDestinations.contains(destinationId)) return;
    await _preferences.setString(televisionDestinationKey, destinationId);
  }

  String? _validatedDestination(String key, Set<String> validDestinations) {
    final destinationId = _preferences.getString(key);
    return validDestinations.contains(destinationId) ? destinationId : null;
  }
}
