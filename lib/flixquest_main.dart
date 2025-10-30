import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flixquest/constants/app_constants.dart';
import 'package:flixquest/models/app_colors.dart';
import 'package:flixquest/screens/common/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'constants/theme_data.dart';
import 'functions/function.dart';
import 'main.dart';
import 'provider/app_dependency_provider.dart';
import 'provider/recently_watched_provider.dart';
import 'provider/settings_provider.dart';
import 'screens/common/discover.dart';
import 'screens/common/search_view.dart';
import 'screens/user/user_info.dart';
import 'screens/user/user_state.dart';
import 'widgets/common_widgets.dart';
import 'widgets/movie_widgets.dart';
import 'widgets/tv_widgets.dart';

class FlixQuest extends StatefulWidget {
  const FlixQuest(
      {required this.settingsProvider,
      required this.recentProvider,
      required this.appDependencyProvider,
      required this.init,
      super.key});

  final SettingsProvider settingsProvider;
  final RecentProvider recentProvider;
  final AppDependencyProvider appDependencyProvider;
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
      appDependencyProvider.consumetUrl =
          _remoteConfig.getString('consumet_url');
      appDependencyProvider.flixQuestLogo =
          _remoteConfig.getString('cinemax_logo');
      appDependencyProvider.opensubtitlesKey =
          _remoteConfig.getString('opensubtitles_key');
      appDependencyProvider.streamingServerFlixHQ =
          _remoteConfig.getString('streaming_server_flixhq');
      appDependencyProvider.streamingServerDCVA =
          _remoteConfig.getString('streaming_server_dcva');
      appDependencyProvider.enableADS = _remoteConfig.getBool('ads_enabled');
      appDependencyProvider.fetchRoute = _remoteConfig.getString('route_v241');
      appDependencyProvider.useExternalSubtitles =
          _remoteConfig.getBool('use_external_subtitles');
      appDependencyProvider.enableOTTADS =
          _remoteConfig.getBool('ott_ads_enabled');
      appDependencyProvider.displayWatchNowButton =
          _remoteConfig.getBool('enable_stream');
      appDependencyProvider.displayOTTDrawer =
          _remoteConfig.getBool('enable_ott');
      appDependencyProvider.flixquestAPIURL =
          _remoteConfig.getString('flixquest_api_url');
      appDependencyProvider.streamingServerZoro =
          _remoteConfig.getString('streaming_server_zoro');
      appDependencyProvider.isForcedUpdate =
          _remoteConfig.getBool('forced_update');
      appDependencyProvider.flixhqZoeServer =
          _remoteConfig.getString('flixhq_zoe_server');
      appDependencyProvider.goMoviesServer =
          _remoteConfig.getString('gomovies_server');
      appDependencyProvider.vidSrcServer =
          _remoteConfig.getString('vidsrc_server');
      appDependencyProvider.vidSrcToServer =
          _remoteConfig.getString('vidsrcto_server');
      appDependencyProvider.tmdbProxy = _remoteConfig.getString('tmdb_proxy');
      appDependencyProvider.fetchSubtitles =
          _remoteConfig.getBool('fetch_subtitles');
      appDependencyProvider.newFlixHQUrl =
          _remoteConfig.getString('new_flixhq_url');
      appDependencyProvider.newFlixhqServer =
          _remoteConfig.getString('new_flixhq_server');
    }
    await requestNotificationPermissions();
  }

  @override
  void initState() {
    super.initState();
    _initConfig();
    fileDelete();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {});
    FirebaseMessaging.onMessageOpenedApp.listen((message) {});
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
                  return widget.appDependencyProvider;
                })
              ],
              child: Consumer3<SettingsProvider, RecentProvider,
                      AppDependencyProvider>(
                  builder: (context, settingsProvider, recentProvider,
                      appDependencyProvider, snapshot) {
                return DynamicColorBuilder(
                  builder: (lightDynamic, darkDynamic) {
                    return MaterialApp(
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
                          appColor: AppColor(
                              cs: AppColorsList()
                                  .appColors(settingsProvider.appTheme ==
                                              'dark' ||
                                          settingsProvider.appTheme == 'amoled'
                                      ? true
                                      : false)
                                  .firstWhere((element) =>
                                      element.index ==
                                      settingsProvider.appColorIndex)
                                  .cs,
                              index: settingsProvider.appColorIndex)),
                      home: const UserState(),
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
      appDep.consumetUrl = remoteConfig.getString('consumet_url');
      appDep.flixQuestLogo = remoteConfig.getString('cinemax_logo');
      appDep.opensubtitlesKey = remoteConfig.getString('opensubtitles_key');
      appDep.streamingServerFlixHQ =
          remoteConfig.getString('streaming_server_flixhq');
      appDep.streamingServerDCVA =
          remoteConfig.getString('streaming_server_dcva');
      appDep.enableADS = remoteConfig.getBool('ads_enabled');
      appDep.fetchRoute = remoteConfig.getString('route_v241');
      appDep.useExternalSubtitles =
          remoteConfig.getBool('use_external_subtitles');
      appDep.enableOTTADS = remoteConfig.getBool('ott_ads_enabled');
      appDep.displayWatchNowButton = remoteConfig.getBool('enable_stream');
      appDep.displayOTTDrawer = remoteConfig.getBool('enable_ott');
      appDep.flixquestAPIURL = remoteConfig.getString('flixquest_api_url');
      appDep.streamingServerZoro =
          remoteConfig.getString('streaming_server_zoro');
      appDep.isForcedUpdate = remoteConfig.getBool('forced_update');
      appDep.flixhqZoeServer = remoteConfig.getString('flixhq_zoe_server');
      appDep.goMoviesServer = remoteConfig.getString('gomovies_server');
      appDep.vidSrcServer = remoteConfig.getString('vidsrc_server');
      appDep.vidSrcToServer = remoteConfig.getString('vidsrcto_server');
      appDep.tmdbProxy = remoteConfig.getString('tmdb_proxy');
    }
  }

  void defHome() {
    final defaultHome =
        Provider.of<SettingsProvider>(context, listen: false).defaultValue;
    setState(() {
      selectedIndex = defaultHome;
    });
  }

  void checkForcedUpdate() async {
    await FirebaseRemoteConfig.instance.ensureInitialized();
    String appVersion =
        FirebaseRemoteConfig.instance.getString('latest_version');
    bool isForcedUpdate =
        FirebaseRemoteConfig.instance.getBool('forced_update');
    if (isForcedUpdate && (currentAppVersion != appVersion)) {
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
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Scaffold(
        key: _scaffoldKey,
        drawer: const Drawer(child: DrawerWidget()),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              FontAwesomeIcons.barsStaggered,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/images/fq_svg.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              Text(
                tr('flixquest_appbar'),
                style: TextStyle(
                  fontFamily: 'FigtreeSB',
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            IconButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: Search(
                          mixpanel: mixpanel,
                          includeAdult: Provider.of<SettingsProvider>(context,
                                  listen: false)
                              .isAdult,
                          lang: lang));
                },
                icon: const Icon(FontAwesomeIcons.magnifyingGlass)),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withValues(alpha: .1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 7.5),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                activeColor: Colors.black,
                iconSize: 35,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey[100]!,
                color: Colors.black,
                tabs: [
                  GButton(
                    icon: FontAwesomeIcons.clapperboard,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.tv,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.compass,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.user,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
                selectedIndex: selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: const <Widget>[
            MainMoviesDisplay(),
            MainTVDisplay(),
            DiscoverPage(),
            UserInfo()
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
