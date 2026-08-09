import 'dart:async';
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
    final mixpanel = _mixpanel;
    if (mixpanel == null) return;
    unawaited(
      mixpanel.track(event, properties: properties).catchError((Object error) {
        debugPrint('[AnalyticsService] Failed to track $event: $error');
      }),
    );
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

  void trackNavigation({
    required String destination,
    required String surface,
    String source = 'navigation',
  }) {
    _track('App Destination Viewed', {
      'Destination': destination,
      'Surface': surface,
      'Source': source,
    });
  }

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

  /// DaddyLive events deliberately exclude stream URLs, embed URLs and request
  /// headers because they can contain short-lived access tokens.
  void trackLiveTVScreenOpened({required String surface}) {
    _track('Live TV Screen Opened', {
      'Provider': 'DaddyLive',
      'Surface': surface,
    });
  }

  void trackLiveTVCatalogLoad({
    required String surface,
    required bool refresh,
    required bool cacheHit,
    required bool success,
    required int durationMs,
    required int channelCount,
    required int epgDayCount,
    String? error,
    bool fallbackToCache = false,
  }) {
    _track('Live TV Catalog Load', {
      'Provider': 'DaddyLive',
      'Surface': surface,
      'Refresh': refresh,
      'Cache Hit': cacheHit,
      'Success': success,
      'Fallback To Cache': fallbackToCache,
      'Duration Ms': durationMs,
      'Channel Count': channelCount,
      'EPG Day Count': epgDayCount,
      if (error != null) 'Error': _safeError(error),
    });
  }

  void trackLiveTVInteraction({
    required String surface,
    required String action,
    String? value,
    int? resultCount,
  }) {
    _track('Live TV Interaction', {
      'Provider': 'DaddyLive',
      'Surface': surface,
      'Action': action,
      if (value != null) 'Value': value,
      if (resultCount != null) 'Result Count': resultCount,
    });
  }

  void trackLiveTVFavorite({
    required String surface,
    required String channelId,
    required String channelName,
    required bool added,
  }) {
    _track('Live TV Favorite Toggled', {
      'Provider': 'DaddyLive',
      'Surface': surface,
      'Channel ID': channelId,
      'Channel Name': channelName,
      'Added': added,
    });
  }

  void trackLiveTVStreamResolution({
    required String surface,
    required String channelId,
    required String channelName,
    required String outcome,
    required int durationMs,
    String? source,
    String? error,
  }) {
    _track('Live TV Stream Resolution', {
      'Provider': 'DaddyLive',
      'Surface': surface,
      'Channel ID': channelId,
      'Channel Name': channelName,
      'Outcome': outcome,
      'Duration Ms': durationMs,
      if (source != null) 'Source': source,
      if (error != null) 'Error': _safeError(error),
    });
  }

  void trackLiveTVPlayerEvent({
    required String surface,
    required String sessionId,
    required String channelId,
    required String channelName,
    required String event,
    required int sessionElapsedMs,
    int? startupMs,
    int? bufferingMs,
    int? bufferCount,
    String? error,
  }) {
    _track('Live TV Player Event', {
      'Provider': 'DaddyLive',
      'Surface': surface,
      'Session ID': sessionId,
      'Channel ID': channelId,
      'Channel Name': channelName,
      'Player Event': event,
      'Session Elapsed Ms': sessionElapsedMs,
      if (startupMs != null) 'Startup Ms': startupMs,
      if (bufferingMs != null) 'Buffering Ms': bufferingMs,
      if (bufferCount != null) 'Buffer Count': bufferCount,
      if (error != null) 'Error': _safeError(error),
    });
  }

  void trackLiveTVSessionEnded({
    required String surface,
    required String sessionId,
    required String channelId,
    required String channelName,
    required int durationMs,
    required int watchedMs,
    required int bufferingMs,
    required int bufferCount,
    required int channelSwitchCount,
  }) {
    _track('Live TV Session Ended', {
      'Provider': 'DaddyLive',
      'Surface': surface,
      'Session ID': sessionId,
      'Channel ID': channelId,
      'Channel Name': channelName,
      'Duration Ms': durationMs,
      'Watched Ms': watchedMs,
      'Buffering Ms': bufferingMs,
      'Buffer Count': bufferCount,
      'Channel Switch Count': channelSwitchCount,
    });
  }

  static String _safeError(String error) {
    final redacted = error
        .replaceAll(RegExp(r'https?://\S+', caseSensitive: false), '[URL]')
        .replaceAll(
          RegExp(
            r'\b(authorization|token|key|signature)\s*[:=]\s*[^,;\s}]+',
            caseSensitive: false,
          ),
          r'$1=[REDACTED]',
        )
        .replaceAll(
          RegExp(r'\bbearer\s+[^,;\s}]+', caseSensitive: false),
          'Bearer [REDACTED]',
        );
    final singleLine = redacted.replaceAll(RegExp(r'\s+'), ' ').trim();
    return singleLine.length <= 300 ? singleLine : singleLine.substring(0, 300);
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

  void trackPlaybackEvent({
    required String mediaType,
    required dynamic contentId,
    required String? contentTitle,
    required String surface,
    required String sessionId,
    required String event,
    required int sessionElapsedMs,
    String? provider,
    int? startupMs,
    int? bufferingMs,
    int? bufferCount,
    String? value,
    String? error,
  }) {
    _track('Playback Event', {
      'Media Type': mediaType,
      'Content ID': '$contentId',
      'Content Title': contentTitle ?? 'N/A',
      'Surface': surface,
      'Session ID': sessionId,
      'Playback Event': event,
      'Session Elapsed Ms': sessionElapsedMs,
      if (provider != null) 'Provider': provider,
      if (startupMs != null) 'Startup Ms': startupMs,
      if (bufferingMs != null) 'Buffering Ms': bufferingMs,
      if (bufferCount != null) 'Buffer Count': bufferCount,
      if (value != null) 'Value': value,
      if (error != null) 'Error': _safeError(error),
    });
  }

  void trackPlaybackSessionEnded({
    required String mediaType,
    required dynamic contentId,
    required String? contentTitle,
    required String surface,
    required String sessionId,
    required int durationMs,
    required int watchedMs,
    required int bufferingMs,
    required int bufferCount,
    required int providerSwitchCount,
    String? provider,
  }) {
    _track('Playback Session Ended', {
      'Media Type': mediaType,
      'Content ID': '$contentId',
      'Content Title': contentTitle ?? 'N/A',
      'Surface': surface,
      'Session ID': sessionId,
      'Duration Ms': durationMs,
      'Watched Ms': watchedMs,
      'Buffering Ms': bufferingMs,
      'Buffer Count': bufferCount,
      'Provider Switch Count': providerSwitchCount,
      if (provider != null) 'Provider': provider,
    });
  }

  void trackProviderAttempt({
    required String mediaType,
    required String provider,
    required String purpose,
    required bool success,
    required int durationMs,
    required int sourceCount,
    required int subtitleCount,
    String? error,
  }) {
    _track('Stream Provider Attempt', {
      'Media Type': mediaType,
      'Provider': provider,
      'Purpose': purpose,
      'Success': success,
      'Duration Ms': durationMs,
      'Source Count': sourceCount,
      'Subtitle Count': subtitleCount,
      if (error != null) 'Error': _safeError(error),
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
    String? outcome,
    int? durationMs,
    String? error,
  }) {
    _track('Cloud Sync', {
      'Action': action,
      'Item Count': itemCount,
      if (outcome != null) 'Outcome': outcome,
      if (durationMs != null) 'Duration Ms': durationMs,
      if (error != null) 'Error': _safeError(error),
    });
  }

  void trackDownload({
    required String action,
    required String mediaType,
    required String outcome,
    String? provider,
    String? quality,
    String? error,
  }) {
    _track('Offline Download', {
      'Action': action,
      'Media Type': mediaType,
      'Outcome': outcome,
      if (provider != null) 'Provider': provider,
      if (quality != null) 'Quality': quality,
      if (error != null) 'Error': _safeError(error),
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
