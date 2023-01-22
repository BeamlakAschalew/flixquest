// ignore_for_file: avoid_unnecessary_containers
import 'package:cinemax/screens/user/user_state.dart';
import 'package:cinemax/screens/user/user_info.dart';
import '/constants/theme_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'widgets/common_widgets.dart';
import 'widgets/movie_widgets.dart';
import 'screens/search_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'provider/settings_provider.dart';
import 'screens/discover.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  // print('background message ${message.notification!.body}');
}

SettingsProvider settingsProvider = SettingsProvider();
final Future<FirebaseApp> _initialization = Firebase.initializeApp();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await settingsProvider.getCurrentThemeMode();
  await settingsProvider.initMixpanel();
  await settingsProvider.getCurrentAdultMode();
  await settingsProvider.getCurrentDefaultScreen();
  await settingsProvider.getCurrentImageQuality();
  await settingsProvider.getCurrentWatchCountry();
  await settingsProvider.getCurrentViewType();
  await _initialization;

  runApp(Cinemax(
    settingsProvider: settingsProvider,
  ));
}

class Cinemax extends StatefulWidget {
  const Cinemax({required this.settingsProvider, Key? key}) : super(key: key);

  final SettingsProvider settingsProvider;

  @override
  State<Cinemax> createState() => _CinemaxState();
}

class _CinemaxState extends State<Cinemax>
    with ChangeNotifier, WidgetsBindingObserver {
  bool? isFirstLaunch;

  // late FirebaseMessaging messaging;

  void firstTimeCheck() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getBool('isFirstRun') == null) {
        isFirstLaunch = true;
      } else {
        isFirstLaunch = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      // print("message recieved");
      // print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //  print('Message clicked!');
    });
    firstTimeCheck();
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
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error occured'),
                ),
              ),
            );
          }
          return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) {
                  return widget.settingsProvider;
                })
              ],
              child: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, snapshot) {
                //  final isDark = Provider.of<SettingsProvider>(context).darktheme;
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Cinemax',
                  theme: Styles.themeData(settingsProvider.darktheme, context),
                  home: const UserState(),
                  // home: isFirstLaunch == null
                  //     ? Scaffold(
                  //         body: Container(
                  //           color: isDark
                  //               ? const Color(0xFF000000)
                  //               : const Color(0xFFF7F7F7),
                  //           child: const Center(
                  //             child: SizedBox(
                  //                 height: 50,
                  //                 width: 50,
                  //                 child: CircularProgressIndicator(
                  //                     color: Color(0xFFF57C00))),
                  //           ),
                  //         ),
                  //       )
                  //     : isFirstLaunch == true
                  //         ? const LandingScreen()
                  //         : const CinemaxHomePage(),
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
          ],
        ),
        bottomNavigationBar: Container(
          color: isDark ? const Color(0xFF000000) : const Color(0xFFF7F7F7),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: const Color(0xFFF57C00),
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
                  tabs: const [
                    GButton(
                      icon: FontAwesomeIcons.clapperboard,
                      text: 'Movies',
                    ),
                    GButton(
                      icon: FontAwesomeIcons.tv,
                      text: ' TV Shows',
                    ),
                    GButton(
                      icon: FontAwesomeIcons.compass,
                      text: 'Discover',
                    ),
                    GButton(
                      icon: FontAwesomeIcons.user,
                      text: 'Profile',
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
          color: isDark ? const Color(0xFF000000) : const Color(0xFFF7F7F7),
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
