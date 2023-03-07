import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '../../models/tv.dart';
import '../../services/globle_method.dart';
import '../../widgets/common_widgets.dart';
import '../movie/movie_detail.dart';
import '../tv/tv_detail.dart';
import '/api/endpoints.dart';
import '/models/function.dart';
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
  List<Movie> onlineSyncMovies = [];
  List<Map<String, dynamic>> onlineMovieMap = [];
  List<Map<String, dynamic>> onlineTVMap = [];
  List<TV> firebaseTvShows = [];
  List<TV> onlineSyncTVShows = [];
  List<Map<String, dynamic>> offineMovieMap = [];
  List<Map<String, dynamic>> offlineTVMap = [];
  bool? isLoading;
  final scrollController = ScrollController();
  bool isOfflineMovieSyncFinished = true;
  bool isOfflineTVSyncFinished = true;
  final GlobalMethods globalMethods = GlobalMethods();
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  late DocumentSnapshot subscription;
  List<Movie>? offlineSavedMovies;
  List<TV>? offlineSavedTV;
  Map<String, dynamic>? offlineSavedMoviesMap = {};
  Map<String, dynamic>? offlineSavedTVMap = {};
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

    if (await checkIfDocExists(uid!) == false) {
      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).set({});
    }

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

  void offlineMovieSync(List<Movie> movieList) async {
    setState(() {
      isOfflineMovieSyncFinished = false;
    });
    try {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finished syncing to local/offline bookmark',
            style: kTextSmallBodyStyle,
            maxLines: 3,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void onlineMovieSync() async {
    setState(() {
      isOnlineMovieSyncFinished = false;
    });
    onlineMovieMap = [];
    try {
      await firebaseInstance
          .collection('bookmarks-v2.0')
          .doc(uid!)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {
            for (List<Map<String, dynamic>>? element
                in List.from(value.get('movies'))) {
              onlineMovieMap = element!;
            }
          });
        }
      });

      var mov = await movieDatabaseController.getMovieList();
      if (mounted) {
        setState(() {
          offlineSavedMovies = mov;

          for (int i = 0; i < offlineSavedMovies!.length; i++) {
            Map<String, dynamic> movMap = offlineSavedMovies![i].toMap();
            offineMovieMap.add(movMap);
          }
        });
      }

      List<Map<String, dynamic>> difference =
          offineMovieMap.toSet().difference(onlineMovieMap.toSet()).toList();

      difference.insertAll(0, onlineMovieMap);

      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).update(
        {'movies': difference},
      );
    } finally {
      setState(() {
        isOnlineMovieSyncFinished = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finished syncing to online bookmark',
            maxLines: 3,
            style: kTextSmallBodyStyle,
          ),
          duration: Duration(seconds: 2),
        ),
      );
      getSavedMoviesAndTV();
    }
  }

  void onlineTVSync() async {
    setState(() {
      isOnlineTVSyncFinished = false;
    });
    onlineSyncTVShows = [];
    try {
      await firebaseInstance
          .collection('bookmarks-v2.0')
          .doc(uid!)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {
            for (List<Map<String, dynamic>>? element
                in List.from(value.get('tvShows'))) {
              onlineTVMap = element!;
            }
          });
        }
      });

      var tv = await tvDatabaseController.getTVList();
      if (mounted) {
        setState(() {
          offlineSavedTV = tv;
          for (int i = 0; i < offlineSavedTV!.length; i++) {
            Map<String, dynamic> movMap = offlineSavedTV![i].toMap();
            offlineTVMap.add(movMap);
          }
        });
      }

      List<Map<String, dynamic>> difference =
          offlineTVMap.toSet().difference(onlineSyncTVShows.toSet()).toList();

      difference.insertAll(0, onlineTVMap);

      await firebaseInstance.collection('bookmarks-v2.0').doc(uid!).update(
        {'tvShows': difference},
      );
    } finally {
      setState(() {
        isOnlineTVSyncFinished = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finished syncing to online bookmark',
            maxLines: 3,
            style: kTextSmallBodyStyle,
          ),
          duration: Duration(seconds: 2),
        ),
      );
      getSavedMoviesAndTV();
    }
  }

  void deleteMovieFromFirebase(int index) async {
    DocumentReference documentReference =
        firebaseInstance.collection('bookmarks-v2.0').doc(uid!);

    List<dynamic> array = (await documentReference.get()).get('movies');
    array.removeAt(index);
    await documentReference
        .update({'movies': array}).then((value) => setState(() {
              firebaseMovies.removeAt(index);
            }));
  }

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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync'),
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
                                    const Center(
                                      child: Text(
                                        'You don\'t have any Movies synced to online account',
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
                                              const Expanded(
                                                child: Text(
                                                  'Sync movies to your online account',
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
                                    const Text(
                                      'Movies you have bookmarked online:',
                                      style: kTextSmallHeaderStyle,
                                    ),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 250,
                                        child: horizontalSyncedMovies(
                                            imageQuality, isDark)),
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
                                              const Expanded(
                                                child: Text(
                                                  'Sync to offline movie bookmark',
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
                                              const Expanded(
                                                child: Text(
                                                  'Sync movies to your online account',
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
                                    const Center(
                                      child: Text(
                                        'You don\'t have any TV shows synced to online account',
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
                                              const Expanded(
                                                child: Text(
                                                  'Sync TV shows to your online account',
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
                                    const Text(
                                      'TV shows you have bookmarked online:',
                                      style: kTextSmallHeaderStyle,
                                    ),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 250,
                                        child: horizontalSyncedTV(
                                            imageQuality, isDark)),
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
                                              const Expanded(
                                                child: Text(
                                                  'Sync to offline tv bookmark',
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
                                              const Expanded(
                                                child: Text(
                                                  'Sync TV shows to your online account',
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

  Widget horizontalSyncedTV(String imageQuality, bool isDark) {
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
                                ? Image.asset(
                                    'assets/images/na_sqaure.png',
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
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
                                        : TMDB_BASE_IMAGE_URL +
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
                                        scrollingImageShimmer(isDark),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/na_square.png',
                                      fit: BoxFit.cover,
                                    ),
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

  Widget horizontalSyncedMovies(String imageQuality, bool isDark) {
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
                                ? Image.asset(
                                    'assets/images/na_square.png',
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    fadeOutDuration:
                                        const Duration(milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration:
                                        const Duration(milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl:
                                        firebaseMovies[index].posterPath == null
                                            ? ''
                                            : TMDB_BASE_IMAGE_URL +
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
                                        scrollingImageShimmer(isDark),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/na_square.png',
                                      fit: BoxFit.cover,
                                    ),
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
                                //         isDark ? Colors.black45 : Colors.white60),
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
