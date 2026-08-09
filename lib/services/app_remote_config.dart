import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../models/occasional_theme.dart';
import '../provider/app_dependency_provider.dart';

class AppRemoteConfig {
  const AppRemoteConfig._();

  static const occasionalThemeKey = 'occasional_theme';
  static const appLogoKey = 'app_logo_url';
  static const legacyAppLogoKey = 'cinemax_logo';

  static Future<void> configure(FirebaseRemoteConfig remoteConfig) async {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );
    await remoteConfig.setDefaults(const <String, Object>{
      occasionalThemeKey: '{"enabled":false}',
      appLogoKey: '',
      legacyAppLogoKey: 'default',
    });
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
      provider.occasionalThemeCatalog = OccasionalThemeCatalog.fromJsonString(
        occasionalThemeValue.asString(),
      );
    }
    provider.displayWatchNowButton = remoteConfig.getBool('enable_stream');
    provider.displayOTTDrawer = remoteConfig.getBool('enable_ott');
    provider.flixquestAPIURL = remoteConfig.getString('flixquest_api_url_v2');
    provider.isForcedUpdate = remoteConfig.getBool('forced_update');
    provider.tmdbProxy = remoteConfig.getString('tmdb_proxy');
  }
}
