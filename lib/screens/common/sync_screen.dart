import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '../../services/globle_method.dart';
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
  bool? isLoading;
  List<Movie> movieList = [];
  double firebaseProgress = 0.00;
  double sqliteProgress = 0.00;
  double newSqlitePr = 0.00;
  final scrollController = ScrollController();
  double newFirebasePr = 0.00;
  bool isFinished = true;
  List<int> dummyIds = [];
  final GlobalMethods globalMethods = GlobalMethods();
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  late StreamSubscription<DocumentSnapshot> subscription;
  String? uid;

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
      print('user doesnt exist');
      await firebaseInstance.collection('bookmarks').doc(uid!).set({});
    }

    subscription = FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(uid!)
        .snapshots()
        .listen((datasnapshot) async {
      final docData = datasnapshot.data() as Map<String, dynamic>;

      if (docData.containsKey('movies') == false) {
        print('field doesnt exist');
        await firebaseInstance.collection('bookmarks').doc(uid!).set(
          {'movies': dummyIds},
        );
      }

      if (docData.containsKey('tv') == false) {
        print('field doesnt exist');
        await firebaseInstance.collection('bookmarks').doc(uid!).set(
          {'movies': dummyIds},
        );
      }
    });

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
          print(movieIds.toList());
        });
      }
    });
    for (int i = 0; i < movieIds.length; i++) {
      await retryOptions.retry(
        () => getMovie(Endpoints.getMovieDetails(movieIds[i])).then((value) {
          if (mounted) {
            setState(() {
              movieList.add(value);
              print(movieList);
              firebaseProgress = i / movieIds.length;
              newFirebasePr = firebaseProgress * 100;
            });
          }
        }),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void offlineMovieSync(List<Movie> movieList) async {
    setState(() {
      isFinished = false;
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
              print(sqliteProgress);
              print('added movie ${movieList[i].originalTitle}');
            });
          });
        }
      }
    } finally {
      setState(() {
        isFinished = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finished syncing to local/offline bookmark',
            style: kTextSmallBodyStyle,
          ),
          duration: Duration(seconds: 2),
        ),
      );
      print(isFinished);
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
                            ? const Center(
                                child: Text('no data'),
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
                                                visible: !isFinished,
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
                                      onPressed: () async {
                                        offlineMovieSync(movieList);
                                      },
                                      child: const Text(
                                          'Sync movies to your online account'))
                                ],
                              ),
                      ),
                      const Divider(thickness: 2, color: Colors.white54),
                      // Expanded(
                      //   child: movieIds.isEmpty
                      //       ? const Center(
                      //           child: Text('no data'),
                      //         )
                      //       : Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             const Text(
                      //               'Movies you have bookmarked online:',
                      //               style: kTextSmallHeaderStyle,
                      //             ),
                      //             SizedBox(
                      //               width: double.infinity,
                      //               height: 250,
                      //               child: HorizontalScrollingMoviesList(
                      //                   scrollController: scrollController,
                      //                   movieList: movieList,
                      //                   imageQuality: imageQuality,
                      //                   isDark: isDark),
                      //             ),
                      //           ],
                      //         ),
                      // ),
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
