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
  }) : super(key: key);

  @override
  State<MovieBookmark> createState() => _MovieBookmarkState();
}

class _MovieBookmarkState extends State<MovieBookmark> {
  List<Movie>? movieList;
  int count = 0;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    fetchBookmark();
    super.initState();
  }

  Future<void> setData() async {
    var mov = await movieDatabaseController.getMovieList();
    setState(() {
      movieList = mov;
    });
  }

  void fetchBookmark() async {
    await setData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return movieList == null
        ? Container(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            child: mainPageVerticalScrollShimmer(
                isDark: isDark,
                isLoading: false,
                scrollController: _scrollController))
        : movieList!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                    'You don\'t have any movies bookmarked :)',
                    textAlign: TextAlign.center,
                    style: kTextSmallHeaderStyle,
                  ),
                ),
              )
            : Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: movieList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return MovieDetailPage(
                                            movie: movieList![index],
                                            heroId: '${movieList![index].id}',
                                          );
                                        }));
                                      },
                                      child: Container(
                                        color: isDark
                                            ? const Color(0xFF000000)
                                            : const Color(0xFFFFFFFF),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
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
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: SizedBox(
                                                      width: 85,
                                                      height: 130,
                                                      child: Hero(
                                                        tag:
                                                            '${movieList![index].id}',
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child: movieList![
                                                                          index]
                                                                      .posterPath ==
                                                                  null
                                                              ? Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Stack(
                                                                  children: [
                                                                      CachedNetworkImage(
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
                                                                            movieList![index].posterPath!,
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
                                                                                mainPageVerticalScrollImageShimmer(isDark),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
                                                                          'assets/images/na_logo.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        left:
                                                                            -15,
                                                                        top:
                                                                            -10,
                                                                        child: Container(
                                                                            alignment: Alignment.topLeft,
                                                                            child: GestureDetector(
                                                                              onTap: () async {
                                                                                movieDatabaseController.deleteMovie(movieList![index].id!);
                                                                                //  movieList[index].favorite = false;
                                                                                if (mounted) {
                                                                                  setState(() {
                                                                                    setData();
                                                                                  });
                                                                                }
                                                                              },
                                                                              child: const Icon(Icons.bookmark_remove, size: 60),
                                                                            )),
                                                                      ),
                                                                    ]),
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
                                                          movieList![index]
                                                              .title!,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'PoppinsSB',
                                                              fontSize: 15,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            const Icon(
                                                                Icons.star,
                                                                color: Color(
                                                                    0xFFF57C00)),
                                                            Text(
                                                              movieList![index]
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
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ));
  }
}
