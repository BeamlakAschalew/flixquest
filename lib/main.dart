// ignore_for_file: avoid_unnecessary_containers
import 'package:cinemax/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'screens/movie_widgets.dart';
import 'screens/search_view.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
              primaryVariant: Color(0xFF8f4700),
              secondary: Color(0xFF202124),
              secondaryVariant: Color(0xFF141517),
              surface: Color(0xFFF57C00),
              background: Color(0xFF202124),
              error: Color(0xFFFF0000),
              onPrimary: Color(0xFF202124),
              onSecondary: Color(0xFF141517),
              onSurface: Color(0xFF141517),
              onBackground: Color(0xFFF57C00),
              onError: Color(0xFFFFFFFF),
              brightness: Brightness.dark)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late Mixpanel mixpanel;
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    initMixpanel();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("8625a1817d0551c18fc6297b294978b2",
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
          style: TextStyle(fontFamily: 'PoppinsSB'),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: MovieSearch());
                // if (result != null) {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => MovieDetailPage(
                //               movie: result, heroId: '${result.id}search')));
                // }
              },
              icon: const Icon(Icons.search)),
        ],
        bottom: TabBar(
          tabs: const [
            Tab(
                child: Text(
              'Movies',
            )),
            Tab(
                child: Text(
              'TV Series',
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
