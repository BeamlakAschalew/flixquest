// ignore_for_file: avoid_unnecessary_containers
import 'package:cinemax/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'screens/common_widgets.dart';
import 'screens/movie_widgets.dart';
import 'screens/search_view.dart';

void main() {
  runApp(const Cinemax());
}

class Cinemax extends StatelessWidget {
  const Cinemax({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Cinemax',
      theme: ThemeData.dark().copyWith(
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
      home: const CinemaxHomePage(title: 'Cinemax'),
    );
  }
}

class CinemaxHomePage extends StatefulWidget {
  const CinemaxHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<CinemaxHomePage> createState() => _CinemaxHomePageState();
}

class _CinemaxHomePageState extends State<CinemaxHomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late Mixpanel mixpanel;
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
        bottom: TabBar(
          tabs: [
            Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.movie_creation_rounded),
                ),
                Text(
                  'Movies',
                ),
              ],
            )),
            Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.live_tv_rounded)),
                Text(
                  'TV series',
                ),
              ],
            ))
          ],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          //isScrollable: true,
          labelStyle: const TextStyle(
            fontFamily: 'PoppinsSB',
            color: Colors.black,
            fontSize: 17,
          ),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
          labelColor: Colors.black,
          controller: tabController,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          MainMoviesDisplay(),
          MainTVDisplay(),
        ],
      ),
    );
  }
}
