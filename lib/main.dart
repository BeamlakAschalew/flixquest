// ignore_for_file: avoid_unnecessary_containers
import 'dart:io';
import 'package:cinemax/models/download_manager.dart';
import 'package:cinemax/models/translation.dart';
import 'package:cinemax/screens/common/video_download_screen.dart';
import 'package:easy_localization/easy_localization.dart';
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
DownloadProvider downloadProvider = DownloadProvider();
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
  await _initialization;
}

void main() async {
  await appInitialize();
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: Translation.all[0],
    startLocale: const Locale('en'),
    child: Cinemax(
      settingsProvider: settingsProvider,
      downloadProvider: downloadProvider,
    ),
  ));
}

class Cinemax extends StatefulWidget {
  const Cinemax(
      {required this.settingsProvider,
      required this.downloadProvider,
      Key? key})
      : super(key: key);

  final SettingsProvider settingsProvider;
  final DownloadProvider downloadProvider;

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

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {});
    FirebaseMessaging.onMessageOpenedApp.listen((message) {});
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    fileDelete();
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
            const MaterialApp(
              debugShowCheckedModeBanner: true,
              home: Scaffold(
                body: Center(
                  child: Text('Error occurred'),
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
                  return widget.downloadProvider;
                })
              ],
              child: Consumer2<SettingsProvider, DownloadProvider>(builder:
                  (context, settingsProvider, downloadProvider, snapshot) {
                return DynamicColorBuilder(
                  builder: (lightDynamic, darkDynamic) {
                    return MaterialApp(
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      debugShowCheckedModeBanner: true,
                      title: 'Cinemax',
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

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          elevation: 1,
          title: const Text(
            'Cinemax',
            style: TextStyle(
              fontFamily: 'PoppinsSB',
            ),
          ),
          actions: [
            IconButton(
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
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return const VideoDownloadScreen();
                  })));
                },
                icon: const Icon(Icons.download))
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
                      text: 'Movies',
                      iconColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    GButton(
                      icon: FontAwesomeIcons.tv,
                      text: ' TV Shows',
                      iconColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    GButton(
                      icon: FontAwesomeIcons.compass,
                      text: 'Discover',
                      iconColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    GButton(
                      icon: FontAwesomeIcons.user,
                      text: 'Profile',
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
