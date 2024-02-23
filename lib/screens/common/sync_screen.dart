import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../controllers/bookmark_database_controller.dart';
import '../../functions/function.dart';
import '../../models/tv.dart';
import '../../provider/app_dependency_provider.dart';
import '../../services/globle_method.dart';
import '../../widgets/common_widgets.dart';
import '../movie/movie_detail.dart';
import '../tv/tv_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;
  List<Movie> firebaseMovies = [];
  List<TV> firebaseTvShows = [];
  bool? isLoading;
  final scrollController = ScrollController();
  bool isOfflineMovieSyncFinished = true;
  bool isOfflineTVSyncFinished = true;
  final GlobalMethods globalMethods = GlobalMethods();
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  late DocumentSnapshot subscription;
  String? uid;
  bool isOnlineMovieSyncFinished = true;
  bool isOnlineTVSyncFinished = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getSavedMoviesAndTV();
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = firebaseInstance.collection('bookmarks-v2.0');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  void getSavedMoviesAndTV() async {
    User? user = _auth.currentUser;
    uid = user!.uid;
    firebaseMovies = [];
    firebaseTvShows = [];
    setState(() {
      isLoading = true;
    });

    // Checks if a bookmark document exists for a signed in user
    if (await checkIfDocExists(uid!) == false) {
      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).set({});
    }

    // Checks if a movie and tvShow collection exists for a signed in user and creates a collection if it doesn't exist
    subscription =
        await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).get();
    final docData = subscription.data() as Map<String, dynamic>;

    if (docData.containsKey('movies') == false) {
      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).update(
        {'movies': []},
      );
    }

    if (docData.containsKey('tvShows') == false) {
      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).update(
        {'tvShows': []},
      );
    }

    // Fetches movies and tvShows of the signed in user and converts the map into a Movie/TV object/list
    await firebaseInstance
        .collection('bookmarks-v2.0')
        .doc(uid!)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          for (Map<String, dynamic>? element
              in List.from(value.get('movies'))) {
            firebaseMovies.add(Movie.fromJson(element!));
          }
        });
      }
    });

    await firebaseInstance
        .collection('bookmarks-v2.0')
        .doc(uid!)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          for (Map<String, dynamic>? element
              in List.from(value.get('tvShows'))) {
            firebaseTvShows.add(TV.fromJson(element!));
          }
        });
      }
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function for transferring movie and tv items to sqlite db
  void offlineMovieSync(List<Movie> movieList) async {
    setState(() {
      isOfflineMovieSyncFinished = false;
    });
    try {
      // loops for the movielist passed to the function and adds to the databse if it doesn't exist
      for (int i = 0; i < movieList.length; i++) {
        bool? isBookmarked;
        var iB = await movieDatabaseController.contain(movieList[i].id!);
        setState(() {
          isBookmarked = iB;
        });
        if (isBookmarked == false) {
          await movieDatabaseController.insertMovie(movieList[i]).then((value) {
            setState(() {
              isBookmarked = true;
            });
          });
        }
      }
    } finally {
      setState(() {
        isOfflineMovieSyncFinished = true;
      });
      if (mounted) {
        GlobalMethods.showCustomScaffoldMessage(
            SnackBar(
              content: Text(
                tr("finished_sync_local"),
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: const Duration(seconds: 2),
            ),
            context);
      }
      //  print(isOfflineMovieSyncFinished);
    }
  }

  // Same functionality with offlineMovieSync
  void offlineTVSync(List<TV> tvList) async {
    setState(() {
      isOfflineTVSyncFinished = false;
    });
    try {
      for (int i = 0; i < tvList.length; i++) {
        bool? isBookmarked;
        var iB = await tvDatabaseController.contain(tvList[i].id!);

        setState(() {
          isBookmarked = iB;
        });
        if (isBookmarked == false) {
          await tvDatabaseController.insertTV(tvList[i]).then((value) {
            setState(() {
              isBookmarked = true;
            });
          });
        }
      }
    } finally {
      setState(() {
        isOfflineTVSyncFinished = true;
      });
      if (mounted) {
        GlobalMethods.showCustomScaffoldMessage(
            SnackBar(
              content: Text(
                tr("finished_sync_local"),
                style: kTextSmallBodyStyle,
                maxLines: 3,
              ),
              duration: const Duration(seconds: 2),
            ),
            context);
      }
    }
  }

  // Function to transfer sqlite movie and tv items to firebase firestore
  void onlineMovieSync() async {
    setState(() {
      isOnlineMovieSyncFinished = false;
    });

    // define three lists for those who come from firebase, sqlite and one to convert to a list of string
    List<Movie> firebaseMovieForOnlineSync = [];
    List<Movie> sqliteMovieForOnlineSync = [];
    List<Map<String, dynamic>> toFirebase = [];
    try {
      // fetches movie map from firebase and converts it into a list of movie
      await firebaseInstance
          .collection('bookmarks-v2.0')
          .doc(uid!)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {
            for (Map<String, dynamic>? element
                in List.from(value.get('movies'))) {
              firebaseMovieForOnlineSync.add(Movie.fromJson(element!));
            }
          });
        }
      });

      // fetch movies from sqlite
      var mov = await movieDatabaseController.getMovieList();
      if (mounted) {
        setState(() {
          sqliteMovieForOnlineSync.addAll(mov);
        });
      }

      List<Movie> difference = [];

      difference.addAll(firebaseMovieForOnlineSync);

      bool containsById(List<Movie> list, int id) {
        return list.any((item) => item.id == id);
      }

      for (var movie in sqliteMovieForOnlineSync) {
        if (!containsById(difference, movie.id!)) {
          difference.add(movie);
        }
      }
      // Calculates the differences between the converted firebase items and sqlite items
      // List<Movie> difference = sqliteMovieForOnlineSync
      //     .toSet()
      //     .difference(firebaseMovieForOnlineSync.toSet())
      //     .toList();

      // Loops through all items of difference and converts it to a list of map
      for (int i = 0; i < difference.length; i++) {
        toFirebase.add(difference[i].toMap());
      }

      // finally update the firebase collection with the new difference list of maps
      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).update(
        {'movies': toFirebase},
      );
    } finally {
      setState(() {
        isOnlineMovieSyncFinished = true;
      });
      if (mounted) {
        GlobalMethods.showCustomScaffoldMessage(
            SnackBar(
              content: Text(
                tr("finished_sync_online"),
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: const Duration(seconds: 2),
            ),
            context);
      }
      getSavedMoviesAndTV();
    }
  }

  // same functionality with onlineMovieSync()
  void onlineTVSync() async {
    setState(() {
      isOnlineTVSyncFinished = false;
    });
    List<TV> firebaseTVForOnlineSync = [];
    List<TV> sqliteTVForOnlineSync = [];
    List<Map<String, dynamic>> toFirebase = [];
    try {
      await firebaseInstance
          .collection('bookmarks-v2.0')
          .doc(uid!)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {
            for (Map<String, dynamic>? element
                in List.from(value.get('tvShows'))) {
              firebaseTVForOnlineSync.add(TV.fromJson(element!));
            }
          });
        }
      });

      var tv = await tvDatabaseController.getTVList();
      if (mounted) {
        setState(() {
          sqliteTVForOnlineSync.addAll(tv);
        });
      }

      List<TV> difference = [];
      difference.addAll(firebaseTVForOnlineSync);

      bool containsById(List<TV> list, int id) {
        return list.any((item) => item.id == id);
      }

      for (var tv in sqliteTVForOnlineSync) {
        if (!containsById(difference, tv.id!)) {
          difference.add(tv);
        }
      }

      // List<TV> difference = sqliteTVForOnlineSync
      //     .toSet()
      //     .difference(firebaseTVForOnlineSync.toSet())
      //     .toList();

      for (int i = 0; i < difference.length; i++) {
        toFirebase.add(difference[i].toMap());
      }

      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).update(
        {'tvShows': toFirebase},
      );
    } finally {
      setState(() {
        isOnlineTVSyncFinished = true;
      });
      if (mounted) {
        GlobalMethods.showCustomScaffoldMessage(
            SnackBar(
              content: Text(
                tr("finished_sync_online"),
                maxLines: 3,
                style: kTextSmallBodyStyle,
              ),
              duration: const Duration(seconds: 2),
            ),
            context);
      }
      getSavedMoviesAndTV();
    }
  }

  // function to delete a specific map from firebase
  void deleteMovieFromFirebase(int index) async {
    // Get the document
    DocumentReference documentReference =
        firebaseInstance.collection('bookmarks-v2.0').doc(uid!);

    // Get all list of map/array from firebase
    List<dynamic> array = (await documentReference.get()).get('movies');
    // remove the array at a specific index, the index will be hooked to a bookmark-minus button
    array.removeAt(index);

    // updates the movies with the new list of array in the firestore and removes items at a specific index for the end user
    await documentReference
        .update({'movies': array}).then((value) => setState(() {
              firebaseMovies.removeAt(index);
            }));
  }

  // Same functionality with deleteMovieFromFirebase()
  void deleteTVFromFirebase(int index) async {
    DocumentReference documentReference =
        firebaseInstance.collection('bookmarks-v2.0').doc(uid!);

    List<dynamic> array = (await documentReference.get()).get('tvShows');
    array.removeAt(index);
    await documentReference
        .update({'tvShows': array}).then((value) => setState(() {
              firebaseTvShows.removeAt(index);
            }));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("sync")),
      ),
      body: isLoading!
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
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
                    indicatorColor: themeMode == "dark" || themeMode == "amoled"
                        ? Colors.white
                        : Colors.black,
                    indicatorWeight: 3,
                    //isScrollable: true,
                    labelStyle: const TextStyle(
                      fontFamily: 'PoppinsSB',
                      color: Colors.black,
                      fontSize: 17,
                    ),
                    unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins', color: Colors.black87),
                    labelColor: Colors.black,
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
                Expanded(
                    child: TabBarView(
                  controller: tabController,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: firebaseMovies.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        tr("no_movies_online"),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        style: kTextSmallBodyStyle,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 270,
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
                                              Expanded(
                                                child: Text(
                                                  tr("online_movie_sync"),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                ),
                                              ),
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
                                    Text(
                                      tr("movies_online"),
                                      style: kTextSmallHeaderStyle,
                                    ),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 250,
                                        child: horizontalSyncedMovies(
                                            imageQuality, themeMode)),
                                    SizedBox(
                                      width: 220,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            offlineMovieSync(firebaseMovies);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tr("offline_movie_sync"),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                ),
                                              ),
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
                                      width: 220,
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
                                              Expanded(
                                                child: Text(
                                                  tr("online_movie_sync"),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                ),
                                              ),
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
                                ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: firebaseTvShows.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        tr("no_tv_online"),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        style: kTextSmallBodyStyle,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 270,
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            onlineTVSync();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tr("online_tv_sync"),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Visibility(
                                                  visible:
                                                      !isOnlineTVSyncFinished,
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
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tr("tv_online"),
                                      style: kTextSmallHeaderStyle,
                                    ),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 250,
                                        child: horizontalSyncedTV(
                                            imageQuality, themeMode)),
                                    SizedBox(
                                      width: 270,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            offlineTVSync(firebaseTvShows);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tr("offline_tv_sync"),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                ),
                                              ),
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
                                    SizedBox(
                                      width: 200,
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            onlineTVSync();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tr("online_tv_sync"),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Visibility(
                                                  visible:
                                                      !isOnlineTVSyncFinished,
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
                      ],
                    ),
                  ],
                )),
              ],
            ),
    );
  }

  Widget horizontalSyncedTV(String imageQuality, String themeMode) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: firebaseTvShows.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TVDetailPage(
                          tvSeries: firebaseTvShows[index],
                          heroId: '${firebaseTvShows[index].id}')));
            },
            child: SizedBox(
              width: 100,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${firebaseTvShows[index].id}',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: firebaseTvShows[index].posterPath == null
                                ? Image.asset('assets/images/na_logo.png',
                                    fit: BoxFit.cover, height: double.infinity)
                                : CachedNetworkImage(
                                    cacheManager: cacheProp(),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration:
                                        const Duration(milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl: firebaseTvShows[index]
                                                .posterPath ==
                                            null
                                        ? ''
                                        : buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled, context) +
                                            imageQuality +
                                            firebaseTvShows[index].posterPath!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        scrollingImageShimmer(themeMode),
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                            height: double.infinity),
                                  ),
                          ),
                          Positioned(
                            top: -14,
                            left: -18.2,
                            child: Container(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () {
                                    deleteTVFromFirebase(index);
                                  },
                                  icon: const Icon(
                                    Icons.bookmark_remove,
                                    size: 50,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        firebaseTvShows[index].name!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget horizontalSyncedMovies(String imageQuality, String themeMode) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: firebaseMovies.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MovieDetailPage(
                          movie: firebaseMovies[index],
                          heroId: '${firebaseMovies[index].id}')));
            },
            child: SizedBox(
              width: 100,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${firebaseMovies[index].id}',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: firebaseMovies[index].posterPath == null
                                ? Image.asset('assets/images/na_logo.png',
                                    fit: BoxFit.cover, height: double.infinity)
                                : CachedNetworkImage(
                                    cacheManager: cacheProp(),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration:
                                        const Duration(milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl:
                                        firebaseMovies[index].posterPath == null
                                            ? ''
                                            : buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled, context) +
                                                imageQuality +
                                                firebaseMovies[index]
                                                    .posterPath!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        scrollingImageShimmer(themeMode),
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                            height: double.infinity),
                                  ),
                          ),
                          Positioned(
                            top: -14,
                            left: -18.2,
                            child: Container(
                                alignment: Alignment.topLeft,
                                // width: 100,
                                // height: 75,
                                // decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(8),
                                //     color:
                                //         themeMode ? Colors.black45 : Colors.white60),
                                child: IconButton(
                                  onPressed: () {
                                    deleteMovieFromFirebase(index);
                                  },
                                  icon: const Icon(
                                    Icons.bookmark_remove,
                                    size: 50,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        firebaseMovies[index].title!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
