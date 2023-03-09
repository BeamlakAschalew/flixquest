import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart';
import 'movie_detail.dart';

class MovieBookmark extends StatefulWidget {
  const MovieBookmark({
    Key? key,
    required this.movieList,
  }) : super(key: key);

  final List<Movie>? movieList;

  @override
  State<MovieBookmark> createState() => _MovieBookmarkState();
}

class _MovieBookmarkState extends State<MovieBookmark> {
  int count = 0;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return widget.movieList == null && viewType == 'grid'
        ? Container(child: moviesAndTVShowGridShimmer(isDark))
        : widget.movieList == null && viewType == 'list'
            ? Container(
                child: mainPageVerticalScrollShimmer(
                    isDark: isDark,
                    isLoading: false,
                    scrollController: _scrollController))
            : widget.movieList!.isEmpty
                ? const Center(
                    child: Text(
                      'You don\'t have any movies bookmarked :)',
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
                                          itemCount: widget.movieList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return MovieDetailPage(
                                                      movie: widget
                                                          .movieList![index],
                                                      heroId:
                                                          '${widget.movieList![index].id}');
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
                                                            '${widget.movieList![index].id}',
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: widget
                                                                          .movieList![
                                                                              index]
                                                                          .posterPath ==
                                                                      null
                                                                  ? Image.asset(
                                                                      'assets/images/na_rect.png',
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
                                                                          widget
                                                                              .movieList![index]
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
                                                                        'assets/images/na_rect.png',
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
                                                                    Text(widget
                                                                        .movieList![
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
                                                                      movieDatabaseController.deleteMovie(widget
                                                                          .movieList![
                                                                              index]
                                                                          .id!);
                                                                      //  movieList[index].favorite = false;
                                                                      if (mounted) {
                                                                        setState(
                                                                            () {
                                                                          widget
                                                                              .movieList!
                                                                              .removeAt(index);
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
                                                          widget
                                                              .movieList![index]
                                                              .title!,
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
                                          itemCount: widget.movieList!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return MovieDetailPage(
                                                    movie: widget
                                                        .movieList![index],
                                                    heroId:
                                                        '${widget.movieList![index].id}',
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
                                                                    '${widget.movieList![index].id}',
                                                                child:
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10.0),
                                                                        child: Stack(
                                                                            children: [
                                                                              widget.movieList![index].posterPath == null
                                                                                  ? Image.asset(
                                                                                      'assets/images/na_logo.png',
                                                                                      fit: BoxFit.cover,
                                                                                    )
                                                                                  : CachedNetworkImage(
                                                                                      fadeOutDuration: const Duration(milliseconds: 300),
                                                                                      fadeOutCurve: Curves.easeOut,
                                                                                      fadeInDuration: const Duration(milliseconds: 700),
                                                                                      fadeInCurve: Curves.easeIn,
                                                                                      imageUrl: TMDB_BASE_IMAGE_URL + imageQuality + widget.movieList![index].posterPath!,
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
                                                                                        movieDatabaseController.deleteMovie(widget.movieList![index].id!);
                                                                                        //  movieList[index].favorite = false;
                                                                                        if (mounted) {
                                                                                          setState(() {
                                                                                            widget.movieList!.removeAt(index);
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
                                                                  widget
                                                                      .movieList![
                                                                          index]
                                                                      .title!,
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
                                                                      widget
                                                                          .movieList![
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
