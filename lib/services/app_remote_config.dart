import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;

import '../constants/api_constants.dart';
import '../models/banner_ad.dart';
import '../provider/app_dependency_provider.dart';
import '../models/banner_ads_config.dart';
import '../models/adsterra_playback_ads_config.dart';
import '../models/vast_preroll_config.dart';
import 'app_update_service.dart';

class AppRemoteConfig {
  const AppRemoteConfig._();

  static const occasionalThemeKey = 'occasional_theme';
  static const appLogoKey = 'app_logo_url';
  static const legacyAppLogoKey = 'cinemax_logo';
  static const flixquestApiInstancesKey = 'flixquest_api_instances';
  static const flixquestApiUrlKey = 'flixquest_api_url_v2';
  static const tmdbApiKey = 'tmdb_api_key';
  static const enableWatchNowKey = 'enable_stream';
  static const enableDownloadKey = 'enable_download';
  static const enableLiveTvKey = 'enable_live_tv';
  static const bannersKey = 'banners';
  static const bannerAdNetworkKey = 'banner_ad_network';
  static const bannerAdNetworkTestKey = 'banner_ad_network_test';
  static const bannerAdNetworkOverridesKey = 'banner_ad_network_overrides';
  static const hostedBannerModeKey = 'hosted_banner_mode';
  static const adsterraBannerEnabledKey = 'adsterra_banner_enabled';
  static const adsterraTvEnabledKey = 'adsterra_tv_enabled';
  static const adsterraBannersKey = 'adsterra_banners';
  static const clickaduBannerEnabledKey = 'clickadu_banner_enabled';
  static const clickaduTvEnabledKey = 'clickadu_tv_enabled';
  static const clickaduBannersKey = 'clickadu_banners';
  static const exoclickBannerEnabledKey = 'exoclick_banner_enabled';
  static const exoclickTvEnabledKey = 'exoclick_tv_enabled';
  static const exoclickBannersKey = 'exoclick_banners';
  static const adsterraPlaybackEnabledKey = 'adsterra_playback_enabled';
  static const adsterraPlaybackAdsKey = 'adsterra_playback_ads';
  static const playbackPopunderNetworkKey = 'playback_popunder_network';
  static const playbackPopupFrequencyMinutesKey =
      'playback_popup_frequency_minutes';
  static const tvPlaybackPopunderNetworkKey = 'tv_playback_popunder_network';
  static const tvPlaybackPopupFrequencyMinutesKey =
      'tv_playback_popup_frequency_minutes';
  static const playerExitPopupEnabledKey = 'player_exit_popup_enabled';
  static const playerExitPopupFrequencyMinutesKey =
      'player_exit_popup_frequency_minutes';
  static const playerExitPopupMinWatchSecondsKey =
      'player_exit_popup_min_watch_seconds';
  static const clickaduPlaybackEnabledKey = 'clickadu_playback_enabled';
  static const clickaduPlaybackAdsKey = 'clickadu_playback_ads';
  static const monetagPlaybackEnabledKey = 'monetag_playback_enabled';
  static const monetagPlaybackAdsKey = 'monetag_playback_ads';
  static const exoclickPlaybackEnabledKey = 'exoclick_playback_enabled';
  static const exoclickPlaybackAdsKey = 'exoclick_playback_ads';
  static const vastPrerollEnabledKey = 'vast_preroll_enabled';
  static const vastPrerollKey = 'vast_preroll';
  static const vastPrerollNetworkKey = 'vast_preroll_network';
  static const telegramChannelUrlKey = 'telegram_channel_url';
  static const appDownloadUrlKey = 'app_download_url';

  /// Per-ABI APK links, e.g. `app_download_url_arm64_v8a`. An empty one sends
  /// that ABI to the universal [appDownloadUrlKey] build.
  static String abiDownloadUrlKey(String abi) =>
      '${appDownloadUrlKey}_${abi.replaceAll('-', '_')}';

  /// Live TV used to ride on the OTT flag before it got a dedicated key.
  static const legacyEnableLiveTvKey = 'enable_ott';

  static Future<void> configure(FirebaseRemoteConfig remoteConfig) async {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(minutes: 1),
      ),
    );
    await remoteConfig.setDefaults(<String, Object>{
      occasionalThemeKey: '{"enabled":false}',
      appLogoKey: '',
      legacyAppLogoKey: 'default',
      'forced_update': false,
      'latest_version': '',
      'latest_build_number': 0,
      'min_build_number': 0,
      appDownloadUrlKey: '',
      for (final abi in AppUpdateService.splitApkAbis)
        abiDownloadUrlKey(abi): '',
      'change_log': '',
      flixquestApiInstancesKey: '',
      flixquestApiUrlKey: '',
      tmdbApiKey: '',
      // Feature toggles ship enabled so a failed or offline fetch never hides
      // playback, downloads or Live TV.
      enableWatchNowKey: true,
      enableDownloadKey: true,
      enableLiveTvKey: true,
      legacyEnableLiveTvKey: true,
      bannersKey: '{"banners":[]}',
      bannerAdNetworkKey: 'adsterra',
      bannerAdNetworkTestKey: '',
      bannerAdNetworkOverridesKey: '{}',
      hostedBannerModeKey: 'stack',
      adsterraBannerEnabledKey: false,
      adsterraTvEnabledKey: false,
      adsterraBannersKey: '{"units":{},"defaults":{},"placements":{}}',
      clickaduBannerEnabledKey: false,
      clickaduTvEnabledKey: false,
      clickaduBannersKey: '{"units":{},"defaults":{},"placements":{}}',
      exoclickBannerEnabledKey: false,
      exoclickTvEnabledKey: false,
      exoclickBannersKey: '{"units":{},"defaults":{},"placements":{}}',
      adsterraPlaybackEnabledKey: false,
      adsterraPlaybackAdsKey: '{}',
      playbackPopunderNetworkKey: 'adsterra',
      playbackPopupFrequencyMinutesKey: 0,
      playerExitPopupEnabledKey: false,
      playerExitPopupFrequencyMinutesKey: 0,
      playerExitPopupMinWatchSecondsKey: 60,
      clickaduPlaybackEnabledKey: false,
      clickaduPlaybackAdsKey: '{}',
      monetagPlaybackEnabledKey: false,
      monetagPlaybackAdsKey: '{}',
      exoclickPlaybackEnabledKey: false,
      exoclickPlaybackAdsKey: '{}',
      vastPrerollEnabledKey: false,
      vastPrerollKey: '{}',
      vastPrerollNetworkKey: 'clickadu',
      // Empty keeps the Home prompt to join the channel off.
      telegramChannelUrlKey: '',
    });
  }

  /// Only the dev flavor may exercise real banner catalogs independently of
  /// production settings. Build mode (debug/profile/release) is irrelevant.
  @visibleForTesting
  static ({String network, bool testMode}) resolveBannerNetworkSelection(
    String production,
    String test, {
    String? flavor = appFlavor,
  }) {
    final testNetwork = test.trim().toLowerCase();
    final testMode = flavor == 'dev' &&
        const {'adsterra', 'clickadu', 'exoclick', 'none'}
            .contains(testNetwork);
    final network = production.trim().toLowerCase();
    return (
      network:
          testMode ? testNetwork : (network.isEmpty ? 'adsterra' : network),
      testMode: testMode,
    );
  }

  static Map<String, String> parseBannerNetworkOverrides(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return const {};
      return Map.unmodifiable({
        for (final entry in json.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: (entry.value as String).trim().toLowerCase(),
      });
    } catch (_) {
      return const {};
    }
  }

  static List<String> parseApiInstances(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic> && decoded['instances'] is List) {
        return (decoded['instances'] as List)
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
      } else if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      // Malformed JSON falls back gracefully.
    }
    return const [];
  }

  static void apply(
    FirebaseRemoteConfig remoteConfig,
    AppDependencyProvider provider,
  ) {
    final preferredLogoValue = remoteConfig.getValue(appLogoKey);
    final legacyLogoValue = remoteConfig.getValue(legacyAppLogoKey);
    final preferredLogo = preferredLogoValue.asString().trim();
    final legacyLogo = legacyLogoValue.asString().trim();
    if (preferredLogoValue.source == ValueSource.valueRemote &&
        preferredLogo.isNotEmpty) {
      provider.flixQuestLogo = preferredLogo;
    } else if (legacyLogoValue.source == ValueSource.valueRemote) {
      provider.flixQuestLogo = legacyLogo;
    } else if (preferredLogoValue.source == ValueSource.valueRemote) {
      provider.flixQuestLogo = 'default';
    }

    final occasionalThemeValue = remoteConfig.getValue(occasionalThemeKey);
    if (occasionalThemeValue.source == ValueSource.valueRemote) {
      provider.applyRemoteOccasionalTheme(occasionalThemeValue.asString());
    }
    provider.displayWatchNowButton = remoteConfig.getBool(enableWatchNowKey);
    provider.displayDownloadButton = remoteConfig.getBool(enableDownloadKey);
    provider.displayLiveTV = _resolveLiveTv(remoteConfig);
    provider.setBannerConfigs(
        parseBannerConfigs(remoteConfig.getString(bannersKey)));

    final bannerSelection = resolveBannerNetworkSelection(
      remoteConfig.getString(bannerAdNetworkKey),
      remoteConfig.getString(bannerAdNetworkTestKey),
    );
    provider.setBannerAdNetwork(bannerSelection.network);
    provider.setBannerAdNetworkOverrides(bannerSelection.testMode
        ? const {}
        : parseBannerNetworkOverrides(
            remoteConfig.getString(bannerAdNetworkOverridesKey)));

    provider.setHostedBannerMode(
      bannerSelection.testMode
          ? HostedBannerMode.off
          : HostedBannerMode.parse(remoteConfig.getString(hostedBannerModeKey)),
    );

    // Every network's catalog is kept; `banner_ad_network` picks the live one.
    for (final (network, enabledKey, tvKey, catalogKey) in [
      (
        AdNetwork.adsterra,
        adsterraBannerEnabledKey,
        adsterraTvEnabledKey,
        adsterraBannersKey
      ),
      (
        AdNetwork.clickadu,
        clickaduBannerEnabledKey,
        clickaduTvEnabledKey,
        clickaduBannersKey
      ),
      (
        AdNetwork.exoclick,
        exoclickBannerEnabledKey,
        exoclickTvEnabledKey,
        exoclickBannersKey
      ),
    ]) {
      final testingNetwork =
          bannerSelection.testMode && bannerSelection.network == network.name;
      provider.setBannerAdsConfig(BannerAdsConfig.parse(
        remoteConfig.getString(catalogKey),
        network: network,
        enabled: testingNetwork || _remoteBool(remoteConfig, enabledKey),
        tvEnabled: testingNetwork || _remoteBool(remoteConfig, tvKey),
      ));
    }

    final instancesRaw = remoteConfig.getString(flixquestApiInstancesKey);
    final playbackEnabled = remoteConfig.getValue(adsterraPlaybackEnabledKey);
    provider.setAdsterraPlaybackAdsConfig(AdsterraPlaybackAdsConfig.parse(
      remoteConfig.getString(adsterraPlaybackAdsKey),
      enabled: playbackEnabled.source == ValueSource.valueRemote &&
          playbackEnabled.asBool(),
    ));
    for (final (network, enabledKey, catalogKey) in [
      (AdNetwork.clickadu, clickaduPlaybackEnabledKey, clickaduPlaybackAdsKey),
      (AdNetwork.monetag, monetagPlaybackEnabledKey, monetagPlaybackAdsKey),
      (AdNetwork.exoclick, exoclickPlaybackEnabledKey, exoclickPlaybackAdsKey),
    ]) {
      provider.setPopunderAdsConfig(PopunderAdsConfig.parse(
        remoteConfig.getString(catalogKey),
        network: network,
        enabled: _remoteBool(remoteConfig, enabledKey),
      ));
    }
    provider.setPlaybackPopunderNetwork(
        AdNetwork.parse(remoteConfig.getString(playbackPopunderNetworkKey)));
    provider.setPlaybackPopupFrequencyMinutes(
        remoteConfig.getValue(playbackPopupFrequencyMinutesKey).asInt());
    provider.setPlayerExitPopup(
      enabled: _remoteBool(remoteConfig, playerExitPopupEnabledKey),
      frequencyMinutes:
          remoteConfig.getValue(playerExitPopupFrequencyMinutesKey).asInt(),
      minWatchSeconds:
          remoteConfig.getValue(playerExitPopupMinWatchSecondsKey).asInt(),
    );
    // Android TV follows the phone selector and interval until its own keys
    // are published.
    final tvNetwork = remoteConfig.getValue(tvPlaybackPopunderNetworkKey);
    final tvNetworkPublished = tvNetwork.source == ValueSource.valueRemote;
    provider.setTvPlaybackPopunderNetwork(
      tvNetworkPublished ? AdNetwork.parse(tvNetwork.asString()) : null,
      followMobile: !tvNetworkPublished,
    );
    final tvFrequency =
        remoteConfig.getValue(tvPlaybackPopupFrequencyMinutesKey);
    provider.setTvPlaybackPopupFrequencyMinutes(
        tvFrequency.source == ValueSource.valueRemote
            ? tvFrequency.asInt()
            : null);
    if (kDebugMode) {
      final network = provider.playbackPopunderNetwork;
      final catalogKey = switch (network) {
        AdNetwork.adsterra => adsterraPlaybackAdsKey,
        AdNetwork.clickadu => clickaduPlaybackAdsKey,
        AdNetwork.monetag => monetagPlaybackAdsKey,
        AdNetwork.exoclick => exoclickPlaybackAdsKey,
        null => null,
      };
      final placement = network == AdNetwork.adsterra
          ? provider.adsterraPlaybackAds.forStage(PlaybackAdStage.streamFound)
          : network == null
              ? null
              : provider.popunderAdsFor(network).activePopunder;
      final enabled = network == AdNetwork.adsterra
          ? provider.adsterraPlaybackAds.enabled
          : network != null && provider.popunderAdsFor(network).enabled;
      final target =
          placement?.pageUrl ?? placement?.smartlinkUrl ?? placement?.scriptUrl;
      final source = catalogKey == null
          ? 'none'
          : remoteConfig.getValue(catalogKey).source.name;
      final interstitialEnabled =
          provider.adsterraPlaybackAds.forStage(PlaybackAdStage.beforeLoader) !=
              null;
      debugPrint('[PlaybackAdConfig] selected=${network?.name ?? 'none'} '
          'catalog=${catalogKey ?? 'none'} source=$source '
          'popupFrequencyMinutes=${provider.playbackPopupFrequencyMinutes} '
          'tvNetwork=${provider.tvPlaybackPopunderNetwork?.name ?? 'none'} '
          'tvPopupFrequencyMinutes=${provider.tvPlaybackPopupFrequencyMinutes} '
          'playerExit=${provider.playerExitPopup} '
          'enabled=$enabled interstitialEnabled=$interstitialEnabled '
          'mode=${placement?.mode ?? 'disabled/invalid'} '
          'target=${target == null ? 'none' : '${target.origin}${target.path}'}');
    }
    provider.setVastPrerollConfig(VastPrerollConfig.parse(
      remoteConfig.getString(vastPrerollKey),
      enabled: _remoteBool(remoteConfig, vastPrerollEnabledKey),
      networks:
          AdNetwork.parseList(remoteConfig.getString(vastPrerollNetworkKey)),
    ));
    if (kDebugMode) {
      final preroll = provider.vastPreroll;
      debugPrint('[VAST] config enabled=${preroll.enabled} order='
          '${preroll.sources.map((source) => source.network.name).join(',')}');
    }
    final parsedInstances = parseApiInstances(instancesRaw);
    final legacyUrl = remoteConfig.getString(flixquestApiUrlKey).trim();
    provider.setFlixquestApiConfig(
      instances: parsedInstances,
      url: legacyUrl.isNotEmpty ? legacyUrl : null,
    );

    provider.setUpdateConfiguration(
      forced: remoteConfig.getBool('forced_update'),
      latestVersion: remoteConfig.getString('latest_version'),
      latestBuild: remoteConfig.getInt('latest_build_number'),
      minimumBuild: remoteConfig.getInt('min_build_number'),
      downloadUrl: remoteConfig.getString(appDownloadUrlKey),
      abiDownloadUrls: {
        for (final abi in AppUpdateService.splitApkAbis)
          abi: remoteConfig.getString(abiDownloadUrlKey(abi)),
      },
      changeLog: remoteConfig.getString('change_log'),
    );
    provider.tmdbProxy = remoteConfig.getString('tmdb_proxy');
    provider
        .setTelegramChannelUrl(remoteConfig.getString(telegramChannelUrlKey));
    final remoteTmdbKey = remoteConfig.getString(tmdbApiKey).trim();
    if (remoteTmdbKey.isNotEmpty) {
      TMDB_API_KEY = remoteTmdbKey;
    }
  }

  static Map<String, BannerDisplayConfig> parseBannerConfigs(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) return const {};
    try {
      final decoded = jsonDecode(trimmed);
      final rawBanners =
          decoded is Map<String, dynamic> ? decoded['banners'] : decoded;
      final configs = <String, BannerDisplayConfig>{};
      if (rawBanners is List) {
        for (final item in rawBanners.whereType<Map>()) {
          for (final entry in item.entries) {
            if (entry.value is Map) {
              configs[entry.key.toString()] = BannerDisplayConfig.fromJson(
                entry.key.toString(),
                Map<String, dynamic>.from(entry.value as Map),
              );
            }
          }
        }
      } else if (rawBanners is Map) {
        for (final entry in rawBanners.entries) {
          if (entry.value is Map) {
            configs[entry.key.toString()] = BannerDisplayConfig.fromJson(
              entry.key.toString(),
              Map<String, dynamic>.from(entry.value as Map),
            );
          }
        }
      }
      return configs;
    } catch (_) {
      return const {};
    }
  }

  /// Ad switches count only when published: no default turns an ad on.
  static bool _remoteBool(FirebaseRemoteConfig remoteConfig, String key) {
    final value = remoteConfig.getValue(key);
    return value.source == ValueSource.valueRemote && value.asBool();
  }

  /// Resolves the Live TV toggle, preferring [enableLiveTvKey] and falling back
  /// to [legacyEnableLiveTvKey] for consoles that have not migrated yet. Only
  /// values actually published remotely win; otherwise the feature stays on.
  static bool _resolveLiveTv(FirebaseRemoteConfig remoteConfig) {
    final value = remoteConfig.getValue(enableLiveTvKey);
    if (value.source == ValueSource.valueRemote) return value.asBool();
    final legacy = remoteConfig.getValue(legacyEnableLiveTvKey);
    if (legacy.source == ValueSource.valueRemote) return legacy.asBool();
    return true;
  }
}
