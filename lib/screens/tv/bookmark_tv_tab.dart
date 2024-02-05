import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import '/screens/tv/tv_detail.dart';
import '../../constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/bookmark_database_controller.dart';
import '../../models/tv.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart';

class TVBookmark extends StatefulWidget {
  const TVBookmark({Key? key, required this.tvList}) : super(key: key);

  final List<TV>? tvList;

  @override
  State<TVBookmark> createState() => _TVBookmarkState();
}

class _TVBookmarkState extends State<TVBookmark> {
  int count = 0;
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return widget.tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(themeMode)
        : widget.tvList == null && viewType == 'list'
            ? mainPageVerticalScrollShimmer(
                themeMode: themeMode,
                scrollController: _scrollController,
                isLoading: false)
            : widget.tvList!.isEmpty
                ? Center(
                    child: Text(
                      tr("no_tv_bookmarked"),
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
                                          itemCount: widget.tvList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return TVDetailPage(
                                                      tvSeries:
                                                          widget.tvList![index],
                                                      heroId:
                                                          '${widget.tvList![index].id}');
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
                                                            '${widget.tvList![index].id}',
                                                        child: Material(
                                                          type: MaterialType
                                                              .transparency,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: widget
                                                                            .tvList![
                                                                                index]
                                                                            .posterPath ==
                                                                        null
                                                                    ? Image.asset(
                                                                        'assets/images/na_logo.png',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        height:
                                                                            double.infinity)
                                                                    : CachedNetworkImage(
                                                                        cacheManager:
                                                                            cacheProp(),
                                                                        fadeOutDuration:
                                                                            const Duration(milliseconds: 300),
                                                                        fadeOutCurve:
                                                                            Curves.easeOut,
                                                                        fadeInDuration:
                                                                            const Duration(milliseconds: 700),
                                                                        fadeInCurve:
                                                                            Curves.easeIn,
                                                                        imageUrl: TMDB_BASE_IMAGE_URL +
                                                                            imageQuality +
                                                                            widget.tvList![index].posterPath!,
                                                                        imageBuilder:
                                                                            (context, imageProvider) =>
                                                                                Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image:
                                                                                DecorationImage(
                                                                              image: imageProvider,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                scrollingImageShimmer(themeMode),
                                                                        errorWidget: (context, url, error) => Image.asset(
                                                                            'assets/images/na_logo.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            height: double.infinity),
                                                                      ),
                                                              ),
                                                              Positioned(
                                                                top: 0,
                                                                left: 0,
                                                                child:
                                                                    Container(
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
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: themeMode == "dark" ||
                                                                              themeMode ==
                                                                                  "amoled"
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
                                                                      Text(widget
                                                                          .tvList![
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
                                                                child:
                                                                    Container(
                                                                        alignment:
                                                                            Alignment
                                                                                .topRight,
                                                                        child:
                                                                            IconButton(
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          onPressed:
                                                                              () async {
                                                                            tvDatabaseController.deleteTV(widget.tvList![index].id!);
                                                                            //  movieList[index].favorite = false;
                                                                            if (mounted) {
                                                                              setState(() {
                                                                                widget.tvList!.removeAt(index);
                                                                              });
                                                                            }
                                                                          },
                                                                          icon: const Icon(
                                                                              Icons.bookmark_remove,
                                                                              size: 60),
                                                                        )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          widget.tvList![index]
                                                              .name!,
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
                                          itemCount: widget.tvList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return TVDetailPage(
                                                    tvSeries:
                                                        widget.tvList![index],
                                                    heroId:
                                                        '${widget.tvList![index].id}',
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
                                                                    '${widget.tvList![index].id}',
                                                                child: Material(
                                                                  type: MaterialType
                                                                      .transparency,
                                                                  child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                      child: Stack(children: [
                                                                        widget.tvList![index].posterPath ==
                                                                                null
                                                                            ? Image.asset('assets/images/na_rect.png',
                                                                                fit: BoxFit.cover,
                                                                                width: double.infinity)
                                                                            : CachedNetworkImage(
                                                                                cacheManager: cacheProp(),
                                                                                fadeOutDuration: const Duration(milliseconds: 300),
                                                                                fadeOutCurve: Curves.easeOut,
                                                                                fadeInDuration: const Duration(milliseconds: 700),
                                                                                fadeInCurve: Curves.easeIn,
                                                                                imageUrl: TMDB_BASE_IMAGE_URL + imageQuality + widget.tvList![index].posterPath!,
                                                                                imageBuilder: (context, imageProvider) => Container(
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                      image: imageProvider,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                placeholder: (context, url) => mainPageVerticalScrollImageShimmer(themeMode),
                                                                                errorWidget: (context, url, error) => Image.asset('assets/images/na_rect.png', fit: BoxFit.cover, width: double.infinity),
                                                                              ),
                                                                        Positioned(
                                                                          left:
                                                                              -18,
                                                                          top:
                                                                              -15,
                                                                          child: Container(
                                                                              alignment: Alignment.topLeft,
                                                                              child: IconButton(
                                                                                onPressed: () async {
                                                                                  tvDatabaseController.deleteTV(widget.tvList![index].id!);
                                                                                  //  movieList[index].favorite = false;
                                                                                  if (mounted) {
                                                                                    setState(() {
                                                                                      widget.tvList!.removeAt(index);
                                                                                    });
                                                                                  }
                                                                                },
                                                                                icon: const Icon(Icons.bookmark_remove_rounded, size: 50),
                                                                              )),
                                                                        ),
                                                                      ])),
                                                                ),
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
                                                                  widget
                                                                      .tvList![
                                                                          index]
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
                                                                  children: <Widget>[
                                                                    const Icon(
                                                                      Icons
                                                                          .star,
                                                                    ),
                                                                    Text(
                                                                      widget
                                                                          .tvList![
                                                                              index]
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
                                                        color: themeMode ==
                                                                "light"
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
