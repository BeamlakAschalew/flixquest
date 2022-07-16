// ignore_for_file: avoid_unnecessary_containers
import 'package:cinemax/screens/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'screens/common_widgets.dart';
import 'screens/movie_widgets.dart';
import 'screens/search_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const Cinemax());
}

class Cinemax extends StatefulWidget {
  const Cinemax({Key? key}) : super(key: key);

  @override
  State<Cinemax> createState() => _CinemaxState();
}

class _CinemaxState extends State<Cinemax> {
  late bool isFirstLaunch = true;
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
    firstTimeCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cinemax',
        theme: ThemeData.dark().copyWith(
            useMaterial3: true,
            textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Poppins',
                ),
            //primaryColor: const Color(0xFFF57C00),
            iconTheme: const IconThemeData(color: Color(0xFFF57C00)),
            //backgroundColor: Colors.black,
            colorScheme: const ColorScheme(
                primary: Color(0xFFF57C00),
                primaryContainer: Color(0xFF8f4700),
                secondary: Color(0xFF202124),
                secondaryContainer: Color(0xFF141517),
                surface: Color(0xFFF57C00),
                background: Color(0xFF202124),
                error: Color(0xFFFF0000),
                onPrimary: Color(0xFF202124),
                onSecondary: Color(0xFF141517),
                onSurface: Color(0xFF141517),
                onBackground: Color(0xFFF57C00),
                onError: Color(0xFFFFFFFF),
                brightness: Brightness.dark)),
        home: isFirstLaunch ? const LandingScreen() : const CinemaxHomePage());
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
  late Mixpanel mixpanel;
  late int _selectedIndex = 0;
  bool isAdult = false;

  @override
  void initState() {
    super.initState();
    initMixpanel();
    getAdultbool();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  void getAdultbool() async {
    final prefs = await SharedPreferences.getInstance();
    isAdult = prefs.getBool('adultMode') == null ? false : true;
    // print(isAdult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      backgroundColor: const Color(0xFF1f1f1e),
      appBar: AppBar(
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
                    delegate:
                        Search(mixpanel: mixpanel, includeAdult: isAdult));
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      bottomNavigationBar: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
      body: IndexedStack(
        children: const <Widget>[
          MainMoviesDisplay(),
          MainTVDisplay(),
          Center(
            child: Text('Coming soon'),
          ),
        ],
        index: _selectedIndex,
      ),
    );
  }
}
