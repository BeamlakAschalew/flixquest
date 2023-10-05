import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'constants/theme_data.dart';
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

class Cinemax extends StatefulWidget {
  const Cinemax(
      {required this.settingsProvider,
      required this.recentProvider,
      required this.appDependencyProvider,
      required this.init,
      Key? key})
      : super(key: key);

  final SettingsProvider settingsProvider;
  final RecentProvider recentProvider;
  final AppDependencyProvider appDependencyProvider;
  final Future<FirebaseApp> init;

  @override
  State<Cinemax> createState() => _CinemaxState();
}

class _CinemaxState extends State<Cinemax>
    with ChangeNotifier, WidgetsBindingObserver {
  void fileDelete() async {
    for (int i = 0; i < appNames.length; i++) {
      File file = File(
          "${(await getApplicationSupportDirectory()).path}${appNames[i]}");
      if (file.existsSync()) {
        file.delete();
      }
    }
  }

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
      appDependencyProvider.cinemaxLogo =
          _remoteConfig.getString('cinemax_logo');
      appDependencyProvider.opensubtitlesKey =
          _remoteConfig.getString('opensubtitles_key');
      appDependencyProvider.streamingServer =
          _remoteConfig.getString('streaming_server');
      appDependencyProvider.enableADS = _remoteConfig.getBool('ads_enabled');
    }
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
                  child: Text(tr("error_occured")),
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
                      title: tr("cinemax"),
                      theme: Styles.themeData(
                          isDarkTheme: settingsProvider.darktheme,
                          isM3Enabled: settingsProvider.isMaterial3Enabled,
                          lightDynamicColor: lightDynamic,
                          darkDynamicColor: darkDynamic,
                          context: context),
                      home: const UserState(),
                    );
                  },
                );
              }));
        });
  }
}

class CinemaxHomePage extends StatefulWidget {
  const CinemaxHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<CinemaxHomePage> createState() => _CinemaxHomePageState();
}

class _CinemaxHomePageState extends State<CinemaxHomePage>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    defHome();
    super.initState();
  }

  void defHome() {
    final defaultHome =
        Provider.of<SettingsProvider>(context, listen: false).defaultValue;
    setState(() {
      selectedIndex = defaultHome;
    });
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
              Icons.menu,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Text(
            tr("cinemax"),
            style: TextStyle(
              fontFamily: 'PoppinsSB',
              color: Theme.of(context).primaryColor,
            ),
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
                icon: const Icon(Icons.search)),
            // IconButton(
            //     color: Theme.of(context).primaryColor,
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: ((context) {
            //         return PlayerTest(
            //           sources: const {
            //             "360":
            //                 "https://xex.stluserehtem.com/_v10/fa30abc4407274dca7128712e25a9f130ca2637f701bb593fa6d10dc0fe8c39f36abbffc57ebbc55d3a4dbb8e1eaaae014ba19c1aa3c63d442da66eec391ebe92a028a57aebad199903df23a666d5cd98fe3419057aae7fd688fb39b6e99aad17c474471927382f10f094e4effa9a609368d1ea135ae8a0006b27c2cfd66672b957411c500b30cfaba8130eb92f7d319/360/index.m3u8"
            //           },
            //           subs: [
            //             BetterPlayerSubtitlesSource(
            //                 name: 'English',
            //                 type: BetterPlayerSubtitlesSourceType.network,
            //                 urls: ['http://cinemax.beamlak.dev/eng-3.srt'])
            //           ],
            //         );
            //       })));
            //     },
            //     icon: const Icon(Icons.play_arrow))
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
                color: Colors.black.withOpacity(.1),
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ignoreVersion = prefs.getString('ignore_version') ?? '';
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
                  prefs: prefs,
                );
              },
            );
          },
        );
      }


*/
