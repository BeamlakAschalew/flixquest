// ignore_for_file: avoid_unnecessary_containers
import 'package:cinemax/screens/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'screens/common_widgets.dart';
import 'screens/movie_widgets.dart';
import 'screens/search_view.dart';

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

  // void sharedState() {
  //   MySharedPreferences.instance
  //       .getBooleanValue('isfirstRun')
  //       .then((value) => setState(() {
  //             isFirstLaunch = true;
  //           }));
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: true,
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
  late TabController tabController;
  late Mixpanel mixpanel;
  late int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const MainMoviesDisplay(),
    //MainTVDisplay(),
    Container(),
    const Center(
      child: Text('Coming soon'),
    )
  ];

  @override
  void initState() {
    super.initState();
    initMixpanel();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
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
                showSearch(context: context, delegate: MovieSearch());
              },
              icon: const Icon(Icons.search)),
        ],
        // bottom: TabBar(
        //   tabs: [
        //     Tab(
        //         child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: const [
        //         Padding(
        //           padding: EdgeInsets.only(right: 8.0),
        //           child: Icon(Icons.movie_creation_rounded),
        //         ),
        //         Text(
        //           'Movies',
        //         ),
        //       ],
        //     )),
        //     Tab(
        //         child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: const [
        //         Padding(
        //             padding: EdgeInsets.only(right: 8.0),
        //             child: Icon(Icons.live_tv_rounded)),
        //         Text(
        //           'TV series',
        //         ),
        //       ],
        //     ))
        //   ],
        //   indicatorColor: Colors.white,
        //   indicatorWeight: 3,
        //   //isScrollable: true,
        //   labelStyle: const TextStyle(
        //     fontFamily: 'PoppinsSB',
        //     color: Colors.black,
        //     fontSize: 17,
        //   ),
        //   unselectedLabelStyle:
        //       const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
        //   labelColor: Colors.black,
        //   controller: tabController,
        //   indicatorSize: TabBarIndicatorSize.tab,
        // ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_creation_rounded), label: 'Movies'),
          BottomNavigationBarItem(
              icon: Icon(Icons.live_tv_rounded), label: 'TV Shows'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded), label: 'Discover')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      // body: TabBarView(
      //   controller: tabController,
      //   children: const [
      //     MainMoviesDisplay(),
      //     MainTVDisplay(),
      //   ],
      // ),
      body: IndexedStack(
        children: const <Widget>[
          MainMoviesDisplay(),
          MainTVDisplay(),
          Center(
            child: Text('Coming soon'),
          )
        ],
        index: _selectedIndex,
      ),
    );
  }
}
