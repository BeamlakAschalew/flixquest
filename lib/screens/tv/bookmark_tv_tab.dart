import 'package:cached_network_image/cached_network_image.dart';
import '/screens/tv/tv_detail.dart';
import '../../constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '../../models/tv.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart';

class TVBookmark extends StatefulWidget {
  const TVBookmark({Key? key}) : super(key: key);

  @override
  State<TVBookmark> createState() => _TVBookmarkState();
}

class _TVBookmarkState extends State<TVBookmark> {
  List<TV>? tvList;
  int count = 0;
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    fetchBookmark();
    super.initState();
  }

  Future<void> setData() async {
    var tv = await tvDatabaseController.getTVList();
    setState(() {
      tvList = tv;
    });
  }

  void fetchBookmark() async {
    await setData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(isDark)
        : tvList == null && viewType == 'list'
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: mainPageVerticalScrollShimmer(
                    isDark: isDark,
                    scrollController: _scrollController,
                    isLoading: false))
            : tvList!.isEmpty
                ? const Center(
                    child: Text(
                      'You don\'t have any TV shows bookmarked :)',
                      textAlign: TextAlign.center,
                      style: kTextSmallHeaderStyle,
                      maxLines: 4,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Expanded(
                                  child: viewType == 'grid'
                                      ? GridView.builder(
                                          controller: _scrollController,
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 150,
                                            childAspectRatio: 0.48,
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 5,
                                          ),
                                          itemCount: tvList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return TVDetailPage(
                                                      tvSeries: tvList![index],
                                                      heroId:
                                                          '${tvList![index].id}');
                                                }));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      flex: 6,
                                                      child: Hero(
                                                        tag:
                                                            '${tvList![index].id}',
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: tvList![index]
                                                                          .posterPath ==
                                                                      null
                                                                  ? Image.asset(
                                                                      'assets/images/na_square.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : CachedNetworkImage(
                                                                      fadeOutDuration:
                                                                          const Duration(
                                                                              milliseconds: 300),
                                                                      fadeOutCurve:
                                                                          Curves
                                                                              .easeOut,
                                                                      fadeInDuration:
                                                                          const Duration(
                                                                              milliseconds: 700),
                                                                      fadeInCurve:
                                                                          Curves
                                                                              .easeIn,
                                                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                                                          imageQuality +
                                                                          tvList![index]
                                                                              .posterPath!,
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          scrollingImageShimmer(
                                                                              isDark),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Image
                                                                              .asset(
                                                                        'assets/images/na_sqaure.png',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              left: 0,
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(3),
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                width: 50,
                                                                height: 25,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    color: isDark
                                                                        ? Colors
                                                                            .black45
                                                                        : Colors
                                                                            .white60),
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .star,
                                                                    ),
                                                                    Text(tvList![
                                                                            index]
                                                                        .voteAverage!
                                                                        .toStringAsFixed(
                                                                            1))
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: -15,
                                                              right: 8,
                                                              child: Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      IconButton(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    onPressed:
                                                                        () async {
                                                                      tvDatabaseController
                                                                          .deleteTV(
                                                                              tvList![index].id!);
                                                                      //  movieList[index].favorite = false;
                                                                      if (mounted) {
                                                                        setState(
                                                                            () {
                                                                          setData();
                                                                        });
                                                                      }
                                                                    },
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .bookmark_remove,
                                                                        size:
                                                                            60),
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          tvList![index].name!,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                      : ListView.builder(
                                          controller: _scrollController,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: tvList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return TVDetailPage(
                                                    tvSeries: tvList![index],
                                                    heroId:
                                                        '${tvList![index].id}',
                                                  );
                                                }));
                                              },
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 0.0,
                                                    bottom: 3.0,
                                                    left: 10,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right:
                                                                        10.0),
                                                            child: SizedBox(
                                                              width: 85,
                                                              height: 130,
                                                              child: Hero(
                                                                tag:
                                                                    '${tvList![index].id}',
                                                                child:
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10.0),
                                                                        child: Stack(
                                                                            children: [
                                                                              tvList![index].posterPath == null
                                                                                  ? Image.asset(
                                                                                      'assets/images/na_logo.png',
                                                                                      fit: BoxFit.cover,
                                                                                    )
                                                                                  : CachedNetworkImage(
                                                                                      fadeOutDuration: const Duration(milliseconds: 300),
                                                                                      fadeOutCurve: Curves.easeOut,
                                                                                      fadeInDuration: const Duration(milliseconds: 700),
                                                                                      fadeInCurve: Curves.easeIn,
                                                                                      imageUrl: TMDB_BASE_IMAGE_URL + imageQuality + tvList![index].posterPath!,
                                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                                        decoration: BoxDecoration(
                                                                                          image: DecorationImage(
                                                                                            image: imageProvider,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      placeholder: (context, url) => mainPageVerticalScrollImageShimmer(isDark),
                                                                                      errorWidget: (context, url, error) => Image.asset(
                                                                                        'assets/images/na_logo.png',
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                              Positioned(
                                                                                left: -18,
                                                                                top: -15,
                                                                                child: Container(
                                                                                    alignment: Alignment.topLeft,
                                                                                    child: IconButton(
                                                                                      onPressed: () async {
                                                                                        tvDatabaseController.deleteTV(tvList![index].id!);
                                                                                        //  movieList[index].favorite = false;
                                                                                        if (mounted) {
                                                                                          setState(() {
                                                                                            setData();
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                      icon: const Icon(Icons.bookmark_remove, size: 50),
                                                                                    )),
                                                                              ),
                                                                            ])),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  tvList![index]
                                                                      .name!,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'PoppinsSB',
                                                                      fontSize:
                                                                          15,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    const Icon(
                                                                      Icons
                                                                          .star,
                                                                    ),
                                                                    Text(
                                                                      tvList![index]
                                                                          .voteAverage!
                                                                          .toStringAsFixed(
                                                                              1),
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Poppins'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: !isDark
                                                            ? Colors.black54
                                                            : Colors.white54,
                                                        thickness: 1,
                                                        endIndent: 20,
                                                        indent: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          })),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
  }
}
