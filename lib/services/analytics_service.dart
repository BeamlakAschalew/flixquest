import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../constants/api_constants.dart';

/// Centralized analytics service wrapping Mixpanel SDK.
///
/// Access via [SettingsProvider.analytics]. All event tracking flows through
/// this singleton so that event names, properties, and error handling are
/// consistent across the entire app.
class AnalyticsService {
  AnalyticsService._();

  static AnalyticsService? _instance;
  Mixpanel? _mixpanel;

  /// Whether the SDK initialized successfully.
  bool get isInitialized => _mixpanel != null;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes Mixpanel and registers super properties.
  ///
  /// Returns the singleton [AnalyticsService]. Safe to call multiple times —
  /// subsequent calls are no-ops.
  static Future<AnalyticsService> init() async {
    if (_instance != null && _instance!.isInitialized) return _instance!;
    _instance = AnalyticsService._();
    try {
      _instance!._mixpanel = await Mixpanel.init(
        mixpanelKey,
        optOutTrackingDefault: false,
        trackAutomaticEvents: true,
      );
      _instance!._registerSuperProperties();
    } catch (e) {
      debugPrint('[AnalyticsService] Mixpanel init failed: $e');
      // Gracefully degrade — all track* methods are no-ops when _mixpanel is null.
    }
    return _instance!;
  }

  /// Returns the current singleton (may be uninitialized).
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  void _registerSuperProperties() {
    _mixpanel?.registerSuperProperties({
      'Platform': Platform.operatingSystem,
      'OS Version': Platform.operatingSystemVersion,
    });
  }

  // ---------------------------------------------------------------------------
  // Core helpers
  // ---------------------------------------------------------------------------

  void _track(String event, [Map<String, dynamic>? properties]) {
    _mixpanel?.track(event, properties: properties);
  }

  // ---------------------------------------------------------------------------
  // User identity
  // ---------------------------------------------------------------------------

  /// Call after successful login or signup to tie events to a user.
  void identifyUser(String userId) {
    _mixpanel?.identify(userId);
  }

  /// Call on sign-out to reset the distinct ID and clear super properties.
  void resetUser() {
    _mixpanel?.reset();
  }

  // ---------------------------------------------------------------------------
  // Auth events
  // ---------------------------------------------------------------------------

  /// Tracks a login event.
  /// [method] should be `'email'` or `'anonymous'`.
  void trackLogin(String method) {
    _track('User Login', {'Method': method});
  }

  /// Tracks a new account signup.
  void trackSignup() {
    _track('User Signup');
  }

  /// Tracks a sign-out.
  void trackSignOut() {
    _track('User Sign Out');
  }

  // ---------------------------------------------------------------------------
  // Content page views
  // ---------------------------------------------------------------------------

  void trackMoviePageView({
    required String? movieName,
    required dynamic movieId,
    required dynamic isAdult,
  }) {
    _track('Most viewed movie pages', {
      'Movie name': '$movieName',
      'Movie id': '$movieId',
      'Is Movie adult?': '$isAdult',
    });
  }

  void trackMovieWatched({
    required String? movieName,
    required dynamic movieId,
    required dynamic isAdult,
  }) {
    _track('Most viewed movies', {
      'Movie name': '$movieName',
      'Movie id': '$movieId',
      'Is Movie adult?': '$isAdult',
    });
  }

  void trackTVPageView({
    required String? tvName,
    required dynamic tvId,
    required dynamic isAdult,
  }) {
    _track('Most viewed TV pages', {
      'TV series name': '$tvName',
      'TV series id': '$tvId',
      'Is TV series adult?': '$isAdult',
    });
  }

  void trackTVWatched({
    required String? tvName,
    required dynamic tvId,
    required String? episodeName,
    required dynamic seasonNumber,
    required dynamic episodeNumber,
  }) {
    _track('Most viewed TV series', {
      'TV series name': '$tvName',
      'TV series id': '$tvId',
      'TV series episode name': '$episodeName',
      'TV series season number': '$seasonNumber',
      'TV series episode number': '$episodeNumber',
    });
  }

  void trackSeasonDetailView({
    required String? tvName,
    required dynamic seasonNumber,
  }) {
    _track('Most viewed season details', {
      'TV series name': '$tvName',
      'TV series season number': '$seasonNumber',
    });
  }

  void trackEpisodeDetailView({
    required String? tvName,
    required String? episodeName,
  }) {
    _track('Most viewed episode details', {
      'TV series name': '$tvName',
      'TV series episode name': '$episodeName',
    });
  }

  void trackPersonPageView({
    required String? personName,
    required dynamic personId,
    dynamic isAdult,
  }) {
    _track('Most viewed person pages', {
      'Person name': '$personName',
      'Person id': '$personId',
      if (isAdult != null) 'Is Person adult?': '$isAdult',
    });
  }

  void trackLiveTVChannelView({
    required String? channelName,
    required String? streamId,
  }) {
    _track('Most viewed TV channels', {
      'TV Channel name': channelName ?? 'N/A',
      'Stream ID': streamId ?? 'N/A',
    });
  }

  // ---------------------------------------------------------------------------
  // Search & discovery
  // ---------------------------------------------------------------------------

  void trackSearch(String query) {
    _track('Searched query', {'query': query});
  }

  void trackGenreClicked({
    required String genreName,
    required String mediaType,
  }) {
    _track('Genre Selected', {
      'Genre Name': genreName,
      'Media Type': mediaType,
    });
  }

  void trackFilterApplied({
    required String mediaType,
    String? genre,
    String? year,
    String? provider,
  }) {
    _track('Filter Applied', {
      'Media Type': mediaType,
      if (genre != null) 'Genre': genre,
      if (year != null) 'Year': year,
      if (provider != null) 'Provider': provider,
    });
  }

  // ---------------------------------------------------------------------------
  // Video Player Events
  // ---------------------------------------------------------------------------

  void trackStreamServerChanged({
    required String mediaType,
    required String serverName,
  }) {
    _track('Stream Server Changed', {
      'Media Type': mediaType,
      'Server Name': serverName,
    });
  }

  void trackQualityChanged({required String quality}) {
    _track('Video Quality Changed', {
      'Quality': quality,
    });
  }

  void trackSubtitleLanguageChanged({required String language}) {
    _track('Subtitle Language Changed', {
      'Language': language,
    });
  }

  void trackPlaybackError({
    required String mediaType,
    required String error,
  }) {
    _track('Playback Error', {
      'Media Type': mediaType,
      'Error': error,
    });
  }

  // ---------------------------------------------------------------------------
  // User actions
  // ---------------------------------------------------------------------------

  void trackBookmarkToggle({
    required String mediaType,
    required String? mediaName,
    required dynamic mediaId,
    required bool added,
  }) {
    _track(added ? 'Bookmark Added' : 'Bookmark Removed', {
      'Media Type': mediaType,
      'Content Title': '$mediaName',
      'Content ID': '$mediaId',
    });
  }

  void trackShare({
    required String shareType,
    String? mediaName,
  }) {
    _track('Content Shared', {
      'Share Type': shareType,
      if (mediaName != null) 'Content Title': mediaName,
    });
  }

  void trackAppUpdateDownload(String appVersion) {
    _track('Download event', {'App version': appVersion});
  }

  void trackCloudSync({
    required String action,
    required int itemCount,
  }) {
    _track('Cloud Sync', {
      'Action': action,
      'Item Count': itemCount,
    });
  }

  void trackImageDownloaded({required String imageType}) {
    _track('Image Downloaded', {
      'Image Type': imageType,
    });
  }

  // ---------------------------------------------------------------------------
  // Settings & Account
  // ---------------------------------------------------------------------------

  void trackSettingsChange({
    required String settingName,
    required String newValue,
  }) {
    _track('Setting Changed', {
      'Setting Name': settingName,
      'New Value': newValue,
    });
  }

  void trackProfileUpdated() {
    _track('Profile Updated');
  }

  void trackPasswordChanged() {
    _track('Password Changed');
  }

  void trackAccountDeleted() {
    _track('Account Deleted');
  }
}
