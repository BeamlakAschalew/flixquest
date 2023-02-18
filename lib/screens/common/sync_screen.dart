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
  List<int> firebaseMovieIds = [];
  List<int> onlineSyncMovieIds = [];
  List<int> firebaseTvIds = [];
  List<int> onlineSyncTVIds = [];
  bool? isLoading;
  List<Movie> apiFetchedMovieList = [];
  List<TV> apiFetchedTVList = [];
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
  late TabController tabController;
  int totalProg = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getSavedMoviesAndTV();
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = firebaseInstance.collection('bookmarks');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  void getSavedMoviesAndTV() async {
    User? user = _auth.currentUser;
    uid = user!.uid;
    firebaseMovieIds = [];
    firebaseTvIds = [];
    apiFetchedMovieList = [];
    apiFetchedTVList = [];
    totalProg = 0;
    setState(() {
      isLoading = true;
    });

    if (await checkIfDocExists(uid!) == false) {
      await firebaseInstance.collection('bookmarks').doc(uid!).set({});
    }

    subscription =
        await firebaseInstance.collection('bookmarks').doc(uid!).get();
    final docData = subscription.data() as Map<String, dynamic>;

    if (docData.containsKey('movies') == false) {
      await firebaseInstance.collection('bookmarks').doc(uid!).update(
        {'movies': []},
      );
    }

    if (docData.containsKey('tv') == false) {
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
            firebaseMovieIds.add(element!);
          }
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
            firebaseTvIds.add(element!);
          }
        });
      }
    });

    for (int i = 0; i < firebaseMovieIds.length; i++) {
      await getMovie(Endpoints.getMovieDetails(firebaseMovieIds[i]))
          .then((value) {
        if (mounted) {
          setState(() {
            apiFetchedMovieList.add(value);
            firebaseProgress = i / firebaseMovieIds.length;
            newFirebasePr = firebaseProgress * 100;
          });
        }
      });
    }

    setState(() {
      totalProg = 1;
    });

    for (int i = 0; i < firebaseTvIds.length; i++) {
      await getTV(Endpoints.getTVDetails(firebaseTvIds[i])).then((value) {
        if (mounted) {
          setState(() {
            apiFetchedTVList.add(value);
            firebaseProgress = i / firebaseTvIds.length;
            newFirebasePr = firebaseProgress * 100;
          });
        }
      });
    }

    setState(() {
      totalProg = 2;
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

      List<int> difference = offlineMovieId
          .toSet()
          .difference(onlineSyncMovieIds.toSet())
          .toList();

      difference.insertAll(0, onlineSyncMovieIds);

      await firebaseInstance.collection('bookmarks').doc(uid!).update(
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
    onlineSyncTVIds = [];
    try {
      await firebaseInstance
          .collection('bookmarks')
          .doc(uid!)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {
            for (int? element in List.from(value.get('tv'))) {
              onlineSyncTVIds.add(element!);
            }
          });
        }
      });

      var tv = await tvDatabaseController.getTVList();
      if (mounted) {
        setState(() {
          offlineSavedTV = tv;
        });
      }

      List<int> offlineTVId = [];

      for (int i = 0; i < offlineSavedTV!.length; i++) {
        offlineTVId.add(offlineSavedTV![i].id!);
      }

      List<int> difference =
          offlineTVId.toSet().difference(onlineSyncTVIds.toSet()).toList();

      difference.insertAll(0, onlineSyncTVIds);

      await firebaseInstance.collection('bookmarks').doc(uid!).update(
        {'tv': difference},
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

  void deleteMovieFromFirebase(int movieId, int index) async {
    List<int> deletedId = [movieId];
    await firebaseInstance
        .collection('bookmarks')
        .doc(uid)
        .update({'movies': FieldValue.arrayRemove(deletedId)}).then((value) {
      setState(() {
        apiFetchedMovieList.removeAt(index);
      });
    });
  }

  void deleteTVFromFirebase(int tvId, int index) async {
    List<int> deletedId = [tvId];
    await firebaseInstance
        .collection('bookmarks')
        .doc(uid)
        .update({'tv': FieldValue.arrayRemove(deletedId)}).then((value) {
      setState(() {
        apiFetchedTVList.removeAt(index);
      });
    });
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${newFirebasePr.toStringAsFixed(2)}%'),
                        Text('$totalProg / 2')
                      ],
                    ),
                  ],
                ),
              ),
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
                          child: firebaseMovieIds.isEmpty
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
                                            offlineMovieSync(
                                                apiFetchedMovieList);
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
                          child: firebaseTvIds.isEmpty
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
                                            offlineTVSync(apiFetchedTVList);
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
      itemCount: apiFetchedTVList.length,
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
                          tvSeries: apiFetchedTVList[index],
                          heroId: '${apiFetchedTVList[index].id}')));
            },
            child: SizedBox(
              width: 100,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${apiFetchedTVList[index].id}',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: apiFetchedTVList[index].posterPath == null
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
                                    imageUrl: apiFetchedTVList[index]
                                                .posterPath ==
                                            null
                                        ? ''
                                        : TMDB_BASE_IMAGE_URL +
                                            imageQuality +
                                            apiFetchedTVList[index].posterPath!,
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
                                    deleteTVFromFirebase(
                                        apiFetchedTVList[index].id!, index);
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
                        apiFetchedTVList[index].name!,
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
      itemCount: apiFetchedMovieList.length,
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
                          movie: apiFetchedMovieList[index],
                          heroId: '${apiFetchedMovieList[index].id}')));
            },
            child: SizedBox(
              width: 100,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${apiFetchedMovieList[index].id}',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: apiFetchedMovieList[index].posterPath == null
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
                                        apiFetchedMovieList[index].posterPath ==
                                                null
                                            ? ''
                                            : TMDB_BASE_IMAGE_URL +
                                                imageQuality +
                                                apiFetchedMovieList[index]
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
                                    deleteMovieFromFirebase(
                                        apiFetchedMovieList[index].id!, index);
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
                        apiFetchedMovieList[index].title!,
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
