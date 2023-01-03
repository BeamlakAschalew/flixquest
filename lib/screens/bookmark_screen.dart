import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/constants/app_constants.dart';
import 'package:cinemax/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/api_constants.dart';
import '../controllers/database_controller.dart';
import '../models/movie.dart';
import '../widgets/common_widgets.dart';
import 'movie/movie_detail.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Movie>? movieList;
  int count = 0;
  DatabaseController databaseController = DatabaseController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchBookmark();
  }

  Future<void> setData() async {
    var mov = await databaseController.getMovieList();
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
    // print(movieList!.length);
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          title: Text('Bookmarks')),
      body: movieList == null
          ? Container(
              color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
              child: mainPageVerticalScrollShimmer(
                  isDark: isDark,
                  isLoading: false,
                  scrollController: _scrollController))
          : movieList!.isEmpty
              ? Container(
                  color: isDark
                      ? const Color(0xFF202124)
                      : const Color(0xFFFFFFFF),
                  child: const Center(
                    child: Text(
                      'You don\'t have any movies bookmarked :)',
                      textAlign: TextAlign.center,
                      style: kTextSmallHeaderStyle,
                    ),
                  ),
                )
              : Container(
                  color: isDark
                      ? const Color(0xFF202124)
                      : const Color(0xFFFFFFFF),
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
                                              ? const Color(0xFF202124)
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
                                                                          imageBuilder: (context, imageProvider) =>
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              image: DecorationImage(
                                                                                image: imageProvider,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          placeholder: (context, url) =>
                                                                              mainPageVerticalScrollImageShimmer(isDark),
                                                                          errorWidget: (context, url, error) =>
                                                                              Image.asset(
                                                                            'assets/images/na_logo.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          left:
                                                                              -15,
                                                                          top:
                                                                              -15,
                                                                          child: Container(
                                                                              alignment: Alignment.topLeft,
                                                                              child: IconButton(
                                                                                onPressed: () async {
                                                                                  databaseController.deleteMovie(movieList![index].id!);
                                                                                  //  movieList[index].favorite = false;
                                                                                  if (mounted) {
                                                                                    setState(() {
                                                                                      setData();
                                                                                    });
                                                                                  }
                                                                                },
                                                                                icon: Icon(Icons.bookmark_remove, size: 45),
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
                                                                movieList![
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
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
    );
  }
}
