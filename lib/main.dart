// ignore_for_file: avoid_unnecessary_containers
//TODO: finished until password changes, set the translation arguments to named arguments
import 'dart:io';
import 'package:cinemax/models/translation.dart';
import 'package:cinemax/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:path_provider/path_provider.dart';
import '/screens/user/user_state.dart';
import '/screens/user/user_info.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '/constants/theme_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'provider/recently_watched_provider.dart';
import 'widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'widgets/common_widgets.dart';
import 'widgets/movie_widgets.dart';
import 'screens/common/search_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'provider/settings_provider.dart';
import 'screens/common/discover.dart';

Future<void> _messageHandler(RemoteMessage message) async {}

SettingsProvider settingsProvider = SettingsProvider();
RecentProvider recentProvider = RecentProvider();
AppDependencyProvider appDependencyProvider = AppDependencyProvider();
final Future<FirebaseApp> _initialization = Firebase.initializeApp();

Future<void> appInitialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await settingsProvider.getCurrentThemeMode();
  await settingsProvider.getCurrentMaterial3Mode();
  await settingsProvider.initMixpanel();
  await settingsProvider.getCurrentAdultMode();
  await settingsProvider.getCurrentDefaultScreen();
  await settingsProvider.getCurrentImageQuality();
  await settingsProvider.getCurrentWatchCountry();
  await settingsProvider.getCurrentViewType();
  await settingsProvider.getSeekDuration();
  await settingsProvider.getMaxBufferDuration();
  await settingsProvider.getVideoResolution();
  await settingsProvider.getSubtitleLanguage();
  await settingsProvider.getViewMode();
  await recentProvider.fetchMovies();
  await recentProvider.fetchEpisodes();
  await appDependencyProvider.getConsumetUrl();
  await appDependencyProvider.getCinemaxLogo();
  await settingsProvider.getSubtitleSize();
  await settingsProvider.getForegroundSubtitleColor();
  await settingsProvider.getBackgroundSubtitleColor();
  await _initialization;
}

void main() async {
  await appInitialize();
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: Translation.all[0],
    startLocale: const Locale('ar'),
    child: Cinemax(
      settingsProvider: settingsProvider,
      recentProvider: recentProvider,
      appDependencyProvider: appDependencyProvider,
    ),
  ));
}

class Cinemax extends StatefulWidget {
  const Cinemax(
      {required this.settingsProvider,
      required this.recentProvider,
      required this.appDependencyProvider,
      Key? key})
      : super(key: key);

  final SettingsProvider settingsProvider;
  final RecentProvider recentProvider;
  final AppDependencyProvider appDependencyProvider;

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

  void _fetchConfig() async {
    await _remoteConfig.fetchAndActivate();
    appDependencyProvider.consumetUrl = _remoteConfig.getString('consumet_url');
    appDependencyProvider.cinemaxLogo = _remoteConfig.getString('cinemax_logo');
  }

  @override
  void initState() {
    super.initState();
    _initConfig();
    fileDelete();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {});
    FirebaseMessaging.onMessageOpenedApp.listen((message) {});
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
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
                              .isAdult));
                },
                icon: const Icon(Icons.search)),
            // IconButton(
            //     color: Theme.of(context).primaryColor,
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: ((context) {
            //         return const VideoDownloadScreen();
            //       })));
            //     },
            //     icon: const Icon(Icons.download))
          ],
        ),
        bottomNavigationBar: Container(
          child: Container(
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
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  activeColor: Colors.black,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.black,
                  tabs: [
                    GButton(
                      icon: FontAwesomeIcons.clapperboard,
                      text: tr("movies"),
                      iconColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    GButton(
                      icon: FontAwesomeIcons.tv,
                      text: tr("tv_shows"),
                      iconColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    GButton(
                      icon: FontAwesomeIcons.compass,
                      text: tr("discover"),
                      iconColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    GButton(
                      icon: FontAwesomeIcons.user,
                      text: tr("profile"),
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
        ),
        body: Container(
          child: IndexedStack(
            index: selectedIndex,
            children: const <Widget>[
              MainMoviesDisplay(),
              MainTVDisplay(),
              DiscoverPage(),
              UserInfo()
            ],
          ),
        ));
  }
}
