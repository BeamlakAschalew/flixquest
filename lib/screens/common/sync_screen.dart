import '/api/endpoints.dart';
import '/models/function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/movie_ui_components.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<int> movieIds = [];
  bool? isLoading;
  List<Movie> movieList = [];
  double progress = 0.0;
  final scrollController = ScrollController();
  double newPr = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getSavedMovies();
  }

  void getSavedMovies() async {
    movieIds = [];
    movieList = [];
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc('movies')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          for (int? element
              in List.from(value.get('zDo2o0uqQTgxICRddRhVHe2rOYm2'))) {
            movieIds.add(element!);
          }
          print(movieIds.toList());
        });
      }
    });
    for (int i = 0; i < movieIds.length; i++) {
      await getMovie(Endpoints.getMovieDetails(movieIds[i])).then((value) {
        if (mounted) {
          setState(() {
            movieList.add(value);
            print(movieList);
            progress = i / movieIds.length;
            newPr = progress * 100;
          });
        }
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            child: TabBar(
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
                      'TV Series',
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
              isLoading!
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                          ),
                          Text(newPr.toStringAsFixed(1)),
                          ElevatedButton(
                              onPressed: () {
                                getSavedMovies();
                              },
                              child: Text('GET'))
                        ],
                      ),
                    )
                  : movieIds.isEmpty
                      ? Center(
                          child: Text('no data'),
                        )
                      : Column(
                          children: [
                            Text('Movies you have bookmarked online'),
                            SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: HorizontalScrollingMoviesList(
                                  scrollController: scrollController,
                                  movieList: movieList,
                                  imageQuality: imageQuality,
                                  isDark: isDark),
                            ),
                          ],
                        ),
              Container()
            ],
          ))
        ],
      ),
    );
  }
}

// class SyncedMovies extends StatefulWidget {
//   SyncedMovies({Key? key, required this.movieIds}) : super(key: key);

//   List<int> movieIds = [];

//   @override
//   State<SyncedMovies> createState() => _SyncedMoviesState();
// }

// class _SyncedMoviesState extends State<SyncedMovies> {
//   final _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Provider.of<SettingsProvider>(context).darktheme;
//     final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
//     final viewType = Provider.of<SettingsProvider>(context).defaultView;
//     return movieList == null && viewType == 'grid'
//         ? Container(child: moviesAndTVShowGridShimmer(isDark))
//         : movieList == null && viewType == 'list'
//             ? Container(
//                 child: mainPageVerticalScrollShimmer(
//                     isDark: isDark,
//                     isLoading: false,
//                     scrollController: _scrollController))
//             : movieList!.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'You don\'t have any movies bookmarked :)',
//                       textAlign: TextAlign.center,
//                       style: kTextSmallHeaderStyle,
//                       maxLines: 4,
//                     ),
//                   )
//                 : Column(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: Column(
//                             children: [
//                               Expanded(
//                                   child: viewType == 'grid'
//                                       ? MovieGridView(
//                                           scrollController: _scrollController,
//                                           moviesList: movieList,
//                                           imageQuality: imageQuality,
//                                           isDark: isDark)
//                                       : MovieListView(
//                                           imageQuality: imageQuality,
//                                           isDark: isDark,
//                                           moviesList: movieList,
//                                           scrollController: _scrollController,
//                                         )),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//   }
// }
