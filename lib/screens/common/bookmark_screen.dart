import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_constants.dart';
import '../../controllers/bookmark_database_controller.dart';
import '../../models/movie.dart';
import '../../models/tv.dart';
import '/screens/common/sync_screen.dart';
import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../movie/bookmark_movies_tab.dart';
import '../tv/bookmark_tv_tab.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String? uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  List<TV>? tvList;
  List<Movie>? movieList;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getData();
    fetchMovieBookmark();
    fetchTVBookmark();
  }

  void getData() async {
    user = _auth.currentUser;
    uid = user!.uid;
  }

  Future<void> setMovieData() async {
    var mov = await movieDatabaseController.getMovieList();
    if (mounted) {
      setState(() {
        movieList = mov;
      });
    }
  }

  void fetchMovieBookmark() async {
    await setMovieData();
  }

  Future<void> setTVData() async {
    var tv = await tvDatabaseController.getTVList();
    setState(() {
      tvList = tv;
    });
  }

  void fetchTVBookmark() async {
    await setTVData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    // print(movieList!.length);
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text(tr("bookmarks")),
          actions: [
            IconButton(
                onPressed: () {
                  if (user!.isAnonymous) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr("bookmark_feature_notice"),
                          style: kTextVerySmallBodyStyle,
                          maxLines: 6,
                        ),
                        duration: const Duration(seconds: 10),
                      ),
                    );
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return const SyncScreen();
                    }))).then((value) async {
                      fetchMovieBookmark();
                      fetchTVBookmark();
                    });
                  }
                },
                icon: const Icon(Icons.sync_sharp))
          ]),
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            child: TabBar(
              tabs: [
                Tab(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.movie_creation_rounded),
                    ),
                    Text(
                      tr("movies"),
                    ),
                  ],
                )),
                Tab(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.live_tv_rounded)),
                    Text(
                      tr("tv_series"),
                    ),
                  ],
                ))
              ],
              indicatorColor: isDark ? Colors.white : Colors.black,
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
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                MovieBookmark(movieList: movieList),
                TVBookmark(
                  tvList: tvList,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
