import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '../../models/tv.dart';
import '../../services/globle_method.dart';
import '../../ui_components/tv_ui_components.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;
  List<int> movieIds = [];
  List<int> onlineSyncMovieIds = [];
  List<int> tvIds = [];
  List<int> onlineSyncTVIds = [];
  bool? isLoading;
  List<Movie> movieList = [];
  List<TV> tvList = [];
  double firebaseProgress = 0.00;
  double sqliteProgress = 0.00;
  double newSqlitePr = 0.00;
  final scrollController = ScrollController();
  double newFirebasePr = 0.00;
  bool isOfflineMovieSyncFinished = true;
  bool isOfflineTVSyncFinished = true;
  final GlobalMethods globalMethods = GlobalMethods();
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  late DocumentSnapshot subscription;
  List<Movie>? offlineSavedMovies;
  List<TV>? offlineSavedTV;
  String? uid;
  bool isOnlineMovieSyncFinished = true;
  bool isOnlineTVSyncFinished = true;

  @override
  void initState() {
    super.initState();
    getSavedMoviesAndTV();
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('bookmarks');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  void getSavedMoviesAndTV() async {
    User? user = _auth.currentUser;
    uid = user!.uid;
    movieIds = [];
    movieList = [];
    setState(() {
      isLoading = true;
    });

    if (await checkIfDocExists(uid!) == false) {
      //TODO remove
      // print('user doesnt exist');
      await firebaseInstance.collection('bookmarks').doc(uid!).set({});
    }

    subscription = await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(uid!)
        .get();
    final docData = subscription.data() as Map<String, dynamic>;

    if (docData.containsKey('movies') == false) {
      //TODO remove
      //  print('field doesnt exist');
      await firebaseInstance.collection('bookmarks').doc(uid!).update(
        {'movies': []},
      );
    }

    if (docData.containsKey('tv') == false) {
      //TODO remove
      //  print('field doesnt exist');
      await firebaseInstance.collection('bookmarks').doc(uid!).update(
        {'tv': []},
      );
    }

    await firebaseInstance
        .collection('bookmarks')
        .doc(uid!)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          for (int? element in List.from(value.get('movies'))) {
            movieIds.add(element!);
          }
          //TODO remove
          //  print(movieIds.toList());
        });
      }
    });

    await firebaseInstance
        .collection('bookmarks')
        .doc(uid!)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          for (int? element in List.from(value.get('tv'))) {
            tvIds.add(element!);
          } //TODO remove
          // print(tvIds.toList());
        });
      }
    });

    for (int i = 0; i < movieIds.length; i++) {
      await getMovie(Endpoints.getMovieDetails(movieIds[i])).then((value) {
        if (mounted) {
          setState(() {
            movieList.add(value);
            //TODO remove
            //  print(movieList);
            firebaseProgress = i / movieIds.length + tvIds.length;
            newFirebasePr = firebaseProgress * 100;
          });
        }
      });
    }

    for (int i = 0; i < tvIds.length; i++) {
      await getTV(Endpoints.getTVDetails(tvIds[i])).then((value) {
        if (mounted) {
          setState(() {
            tvList.add(value);
            //TODO remove
            // print(movieList);
            firebaseProgress = i / movieIds.length + tvIds.length;
            newFirebasePr = firebaseProgress * 100;
          });
        }
      });
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void offlineMovieSync(List<Movie> movieList) async {
    setState(() {
      isOfflineMovieSyncFinished = false;
    });
    try {
      for (int i = 0; i < movieList.length; i++) {
        bool? isBookmarked;
        // checks if a movie exists in sqlite database and assigns a true or false value to it
        var iB = await movieDatabaseController.contain(movieList[i].id!);

        setState(() {
          isBookmarked = iB;
        });

        // adds a movie if isBookmarked is false
        if (isBookmarked == false) {
          await movieDatabaseController.insertMovie(movieList[i]).then((value) {
            setState(() {
              isBookmarked = true;
              sqliteProgress = i / movieList.length;
              newSqlitePr = sqliteProgress * 100;
              //TODO remove
              // print(sqliteProgress);
              // print('added movie ${movieList[i].originalTitle}');
            });
          });
        }
      }
    } finally {
      setState(() {
        isOfflineMovieSyncFinished = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finished syncing to local/offline bookmark',
            maxLines: 3,
            style: kTextSmallBodyStyle,
          ),
          duration: Duration(seconds: 2),
        ),
      );
      //  print(isOfflineMovieSyncFinished);
    }
  }

  void offlineTVSync(List<TV> tvList) async {
    setState(() {
      isOfflineTVSyncFinished = false;
    });
    try {
      for (int i = 0; i < tvList.length; i++) {
        bool? isBookmarked;
        // checks if a movie exists in sqlite database and assigns a true or false value to it
        var iB = await tvDatabaseController.contain(tvList[i].id!);

        setState(() {
          isBookmarked = iB;
        });

        // adds a movie if isBookmarked is false
        if (isBookmarked == false) {
          await tvDatabaseController.insertTV(tvList[i]).then((value) {
            setState(() {
              isBookmarked = true;
              sqliteProgress = i / movieList.length;
              newSqlitePr = sqliteProgress * 100;
              //TODO remove
              //  print(sqliteProgress);
              //  print('added movie ${tvList[i].name}');
            });
          });
        }
      }
    } finally {
      setState(() {
        isOfflineTVSyncFinished = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finished syncing to local/offline bookmark',
            style: kTextSmallBodyStyle,
          ),
          duration: Duration(seconds: 2),
        ),
      ); //TODO remove
      // print(isOfflineTVSyncFinished);
    }
  }

  void onlineMovieSync() async {
    setState(() {
      isOnlineMovieSyncFinished = false;
    });
    onlineSyncMovieIds = [];
    try {
      await firebaseInstance
          .collection('bookmarks')
          .doc(uid!)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {
            for (int? element in List.from(value.get('movies'))) {
              onlineSyncMovieIds.add(element!);
            }
            print('from firebase $onlineSyncMovieIds.toList()}');
          });
        }
      });

      var mov = await movieDatabaseController.getMovieList();
      if (mounted) {
        setState(() {
          offlineSavedMovies = mov;
        });
      }

      List<int> offlineMovieId = [];

      for (int i = 0; i < offlineSavedMovies!.length; i++) {
        offlineMovieId.add(offlineSavedMovies![i].id!);
      }
      print('Offline movie id: ${offlineMovieId.toList()}');

      List<int> difference = offlineMovieId
          .toSet()
          .difference(onlineSyncMovieIds.toSet())
          .toList();

      difference.insertAll(0, onlineSyncMovieIds);
      print('newList: ${difference.toList()}');

      await firebaseInstance.collection('bookmarks').doc(uid!).update(
        {'movies': difference},
      );
    } finally {
      setState(() {
        isOnlineMovieSyncFinished = true;
      });
      getSavedMoviesAndTV();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: Column(
        children: [
          Expanded(
            child: isLoading!
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Fetching your saved movies and TV shows from server...',
                            style: kTextSmallHeaderStyle,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(
                              value: firebaseProgress,
                            ),
                          ),
                          Text('${newFirebasePr.toStringAsFixed(2)}%'),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: movieIds.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text(
                                      'You don\'t have any Movies synced to online account',
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      style: kTextSmallBodyStyle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 310,
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          onlineMovieSync();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                                'Sync movies to your online account'),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Visibility(
                                                visible:
                                                    !isOnlineMovieSyncFinished,
                                                child: const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Movies you have bookmarked online:',
                                    style: kTextSmallHeaderStyle,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 250,
                                    child: HorizontalScrollingMoviesList(
                                        scrollController: scrollController,
                                        movieList: movieList,
                                        imageQuality: imageQuality,
                                        isDark: isDark),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          offlineMovieSync(movieList);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                                'Sync to offline movie bookmark'),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Visibility(
                                                visible:
                                                    !isOfflineMovieSyncFinished,
                                                child: const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                  SizedBox(
                                    width: 310,
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          onlineMovieSync();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                                'Sync movies to your online account'),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Visibility(
                                                visible:
                                                    !isOnlineMovieSyncFinished,
                                                child: const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  )
                                ],
                              ),
                      ),
                      const Divider(thickness: 2, color: Colors.white54),
                      Expanded(
                        child: tvIds.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text(
                                      'You don\'t have any TV shows synced to online account',
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      style: kTextSmallBodyStyle,
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {},
                                      child: const Text(
                                          'Sync TV shows to your online account'))
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'TV shows you have bookmarked online:',
                                    style: kTextSmallHeaderStyle,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 250,
                                    child: HorizontalScrollingTVList(
                                        scrollController: scrollController,
                                        tvList: tvList,
                                        imageQuality: imageQuality,
                                        isDark: isDark),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          offlineTVSync(tvList);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                                'Sync to offline tv bookmark'),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Visibility(
                                                visible:
                                                    !isOfflineTVSyncFinished,
                                                child: const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {},
                                      child: const Text(
                                          'Sync TV shows to your online account'))
                                ],
                              ),
                      ),
                    ],
                  ),
          ),
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
