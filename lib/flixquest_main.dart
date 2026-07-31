import 'package:package_info_plus/package_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flixquest/models/app_colors.dart';
import 'package:flixquest/screens/common/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme_data.dart';
import 'functions/function.dart';
import 'main.dart';
import 'provider/app_dependency_provider.dart';
import 'provider/recently_watched_provider.dart';
import 'provider/settings_provider.dart';
import 'screens/common/discover.dart';
import 'screens/common/bookmark_screen.dart';
import 'screens/common/search_view.dart';
import 'screens/user/user_info.dart';
import 'screens/user/user_state.dart';
import 'widgets/common_widgets.dart';
import 'widgets/movie_widgets.dart';
import 'widgets/tv_widgets.dart';
import 'provider/bookmark_provider.dart';
import 'services/in_app_messaging_service.dart';
import 'tv/platform/device_presentation.dart';

class FlixQuest extends StatefulWidget {
  const FlixQuest(
      {required this.settingsProvider,
      required this.recentProvider,
      required this.bookmarkProvider,
      required this.appDependencyProvider,
      required this.devicePresentation,
      required this.init,
      super.key});

  final SettingsProvider settingsProvider;
  final RecentProvider recentProvider;
  final BookmarkProvider bookmarkProvider;
  final AppDependencyProvider appDependencyProvider;
  final DevicePresentation devicePresentation;
  final Future<FirebaseApp> init;

  @override
  State<FlixQuest> createState() => _FlixQuestState();
}

class _FlixQuestState extends State<FlixQuest>
    with ChangeNotifier, WidgetsBindingObserver {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  Future<void> _initConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 1),
    ));

    _fetchConfig();
  }

  Future _fetchConfig() async {
    await _remoteConfig.fetchAndActivate();
    if (mounted) {
      appDependencyProvider.flixQuestLogo =
          _remoteConfig.getString('cinemax_logo');
      appDependencyProvider.displayWatchNowButton =
          _remoteConfig.getBool('enable_stream');
      appDependencyProvider.displayOTTDrawer =
          _remoteConfig.getBool('enable_ott');
      appDependencyProvider.flixquestAPIURL =
          _remoteConfig.getString('flixquest_api_url_v2');
      appDependencyProvider.isForcedUpdate =
          _remoteConfig.getBool('forced_update');
      appDependencyProvider.tmdbProxy = _remoteConfig.getString('tmdb_proxy');
    }
    await requestNotificationPermissions();
  }

  @override
  void initState() {
    super.initState();
    _initConfig();
    fileDelete();
    InAppMessagingService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   isTablet(context)
    //       ? DeviceOrientation.landscapeLeft
    //       : DeviceOrientation.portraitUp,
    // ]);
    return FutureBuilder(
        future: widget.init,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: true,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            MaterialApp(
              debugShowCheckedModeBanner: true,
              home: Scaffold(
                body: Center(
                  child: Text(tr('error_occured')),
                ),
              ),
            );
          }
          return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) {
                  return widget.settingsProvider;
                }),
                ChangeNotifierProvider(create: (_) {
                  return widget.recentProvider;
                }),
                ChangeNotifierProvider(create: (_) {
                  return widget.bookmarkProvider;
                }),
                ChangeNotifierProvider(create: (_) {
                  return widget.appDependencyProvider;
                })
              ],
              child: Consumer3<SettingsProvider, RecentProvider,
                      AppDependencyProvider>(
                  builder: (context, settingsProvider, recentProvider,
                      appDependencyProvider, snapshot) {
                return DynamicColorBuilder(
                  builder: (lightDynamic, darkDynamic) {
                    final palette = AppColorsList().appColors(
                      settingsProvider.appTheme == 'dark' ||
                          settingsProvider.appTheme == 'amoled',
                    );
                    final selectedAppColor = palette.firstWhere(
                      (color) => color.index == settingsProvider.appColorIndex,
                      orElse: () => palette.first,
                    );
                    return MaterialApp(
                      navigatorKey: InAppMessagingService.navigatorKey,
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      debugShowCheckedModeBanner: true,
                      theme: Styles.themeData(
                          appThemeMode: settingsProvider.appTheme,
                          isM3Enabled: settingsProvider.isMaterial3Enabled,
                          lightDynamicColor: lightDynamic,
                          darkDynamicColor: darkDynamic,
                          context: context,
                          appColor: selectedAppColor),
                      home: UserState(
                        devicePresentation: widget.devicePresentation,
                      ),
                    );
                  },
                );
              }));
        });
  }
}

class FlixQuestHomePage extends StatefulWidget {
  const FlixQuestHomePage({
    super.key,
  });

  @override
  State<FlixQuestHomePage> createState() => _FlixQuestHomePageState();
}

class _FlixQuestHomePageState extends State<FlixQuestHomePage>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    defHome();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        checkForcedUpdate();
        remoteConfig.onConfigUpdated.listen(onFirebaseRemoteConfigUpdate);
      },
    );
    super.initState();
  }

  Future<void> onFirebaseRemoteConfigUpdate(RemoteConfigUpdate rcu) async {
    await remoteConfig.activate();
    if (mounted) {
      final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
      appDep.flixQuestLogo = remoteConfig.getString('cinemax_logo');
      appDep.displayWatchNowButton = remoteConfig.getBool('enable_stream');
      appDep.displayOTTDrawer = remoteConfig.getBool('enable_ott');
      appDep.flixquestAPIURL = remoteConfig.getString('flixquest_api_url_v2');
      appDep.isForcedUpdate = remoteConfig.getBool('forced_update');
      appDep.tmdbProxy = remoteConfig.getString('tmdb_proxy');
    }
  }

  void defHome() {
    final defaultHome =
        Provider.of<SettingsProvider>(context, listen: false).defaultValue;
    setState(() {
      // `3` was historically Profile. Keep existing saved preferences valid
      // after inserting Bookmarks as the fourth navigation destination.
      selectedIndex = defaultHome == 3 ? 4 : defaultHome;
    });
  }

  void checkForcedUpdate() async {
    await FirebaseRemoteConfig.instance.ensureInitialized();
    bool isForcedUpdate =
        FirebaseRemoteConfig.instance.getBool('forced_update');
    if (!isForcedUpdate) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

    int remoteBuildNumber =
        FirebaseRemoteConfig.instance.getInt('latest_build_number');
    if (remoteBuildNumber == 0) {
      remoteBuildNumber =
          FirebaseRemoteConfig.instance.getInt('min_build_number');
    }
    if (remoteBuildNumber == 0) {
      remoteBuildNumber =
          int.tryParse(FirebaseRemoteConfig.instance.getString('latest_version')) ?? 0;
    }

    if (currentBuildNumber < remoteBuildNumber) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const UpdateScreen(
            isForced: true,
          );
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        key: _scaffoldKey,
        drawer: const Drawer(child: DrawerWidget()),
        bottomNavigationBar: Align(
          heightFactor: 1,
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: .18),
                  )
                ],
              ),
              child: SafeArea(
                minimum: const EdgeInsets.symmetric(vertical: 4),
                child: NavigationBar(
                  height: 66,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: [
                    NavigationDestination(
                      icon: Icon(PhosphorIcons.house()),
                      selectedIcon: Icon(
                          PhosphorIcons.house(PhosphorIconsStyle.fill),
                          color: colorScheme.primary),
                      label: tr('movies'),
                    ),
                    NavigationDestination(
                      icon: Icon(PhosphorIcons.television()),
                      selectedIcon: Icon(
                          PhosphorIcons.television(PhosphorIconsStyle.fill),
                          color: colorScheme.primary),
                      label: tr('tv_series'),
                    ),
                    NavigationDestination(
                      icon: Icon(PhosphorIcons.compass()),
                      selectedIcon: Icon(
                          PhosphorIcons.compass(PhosphorIconsStyle.fill),
                          color: colorScheme.primary),
                      label: tr('discover'),
                    ),
                    NavigationDestination(
                      icon: Icon(PhosphorIcons.bookmarkSimple()),
                      selectedIcon: Icon(
                          PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill),
                          color: colorScheme.primary),
                      label: tr('bookmarks'),
                    ),
                    NavigationDestination(
                      icon: Icon(PhosphorIcons.user()),
                      selectedIcon: Icon(
                          PhosphorIcons.user(PhosphorIconsStyle.fill),
                          color: colorScheme.primary),
                      label: tr('profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: <Widget>[
            MainMoviesDisplay(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onSearchPressed: () {
                showSearch(
                  context: context,
                  delegate: Search(
                    includeAdult:
                        Provider.of<SettingsProvider>(context, listen: false)
                            .isAdult,
                    lang: lang,
                  ),
                );
              },
            ),
            MainTVDisplay(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onSearchPressed: () {
                showSearch(
                  context: context,
                  delegate: Search(
                    includeAdult:
                        Provider.of<SettingsProvider>(context, listen: false)
                            .isAdult,
                    lang: lang,
                  ),
                );
              },
            ),
            const DiscoverPage(),
            const BookmarkScreen(embedded: true),
            const UserInfo()
          ],
        ));
  }
}

/*

String? appVersion = _remoteConfig.getString('latest_version');
      SharedPreferences sharedPrefsSingleton = await SharedPreferences.getInstance();
      String? ignoreVersion = sharedPrefsSingleton.getString('ignore_version') ?? '';
      if (mounted &&
          appVersion != currentAppVersion &&
          (ignoreVersion == '' || ignoreVersion != currentAppVersion)) {
        showBottomSheet(
          context: context,
          builder: (context) {
            return Builder(
              builder: (BuildContext innerContext) {
                return UpdateBottom(
                  appVersion: appVersion,
                  ignoreVersion: ignoreVersion,
                  sharedPrefsSingleton: sharedPrefsSingleton,
                );
              },
            );
          },
        );
      }


*/
