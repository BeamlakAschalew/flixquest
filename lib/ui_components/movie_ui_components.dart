import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../functions/function.dart';
import '../models/movie.dart';
import '../provider/app_dependency_provider.dart';
import '../provider/settings_provider.dart';
import '../screens/movie/movie_detail.dart';
import '../widgets/common_widgets.dart';

class HorizontalScrollingMoviesList extends StatelessWidget {
  const HorizontalScrollingMoviesList({
    super.key,
    required ScrollController scrollController,
    required this.movieList,
    required this.imageQuality,
    required this.themeMode,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<Movie>? movieList;
  final String imageQuality;
  final String themeMode;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: movieList!.length,
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
                          movie: movieList![index],
                          heroId: '${movieList![index].id}')));
            },
            child: SizedBox(
              width: 100,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${movieList![index].id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: movieList![index].posterPath == null
                                  ? Image.asset('assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity)
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration:
                                          const Duration(milliseconds: 700),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl:
                                          movieList![index].posterPath == null
                                              ? ''
                                              : buildImageUrl(
                                                      TMDB_BASE_IMAGE_URL,
                                                      proxyUrl,
                                                      isProxyEnabled,
                                                      context) +
                                                  imageQuality +
                                                  movieList![index].posterPath!,
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
                                          Image.asset(
                                              'assets/images/na_logo.png',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity),
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                alignment: Alignment.topLeft,
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: themeMode == 'dark' ||
                                            themeMode == 'amoled'
                                        ? Colors.black45
                                        : Colors.white60),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                    ),
                                    Text(movieList![index].voteAverage! % 1 == 0
                                        ? movieList![index]
                                            .voteAverage!
                                            .toInt()
                                            .toString()
                                        : movieList![index]
                                            .voteAverage!
                                            .toStringAsFixed(1))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        movieList![index].title!,
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

class MovieListView extends StatelessWidget {
  const MovieListView({
    super.key,
    required ScrollController scrollController,
    required this.moviesList,
    required this.themeMode,
    required this.imageQuality,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<Movie>? moviesList;
  final String themeMode;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: moviesList!.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MovieDetailPage(
                  movie: moviesList![index],
                  heroId: '${moviesList![index].id}',
                );
              }));
            },
            child: Container(
              color: Colors.transparent,
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
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            width: 85,
                            height: 130,
                            child: Hero(
                              tag: '${moviesList![index].id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: moviesList![index].posterPath == null
                                    ? Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        cacheManager: cacheProp(),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 300),
                                        fadeOutCurve: Curves.easeOut,
                                        fadeInDuration:
                                            const Duration(milliseconds: 700),
                                        fadeInCurve: Curves.easeIn,
                                        imageUrl: buildImageUrl(
                                                TMDB_BASE_IMAGE_URL,
                                                proxyUrl,
                                                isProxyEnabled,
                                                context) +
                                            imageQuality +
                                            moviesList![index].posterPath!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            mainPageVerticalScrollImageShimmer(
                                                themeMode),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                moviesList![index].title!,
                                style: const TextStyle(
                                    fontFamily: 'FigtreeSB',
                                    fontSize: 15,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.star_rounded,
                                  ),
                                  Text(
                                    moviesList![index].voteAverage! % 1 == 0
                                        ? moviesList![index]
                                            .voteAverage!
                                            .toInt()
                                            .toString()
                                        : moviesList![index]
                                            .voteAverage!
                                            .toStringAsFixed(1),
                                    style:
                                        const TextStyle(fontFamily: 'Figtree'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: themeMode == 'light'
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
        });
  }
}

class MovieGridView extends StatelessWidget {
  const MovieGridView({
    super.key,
    required ScrollController scrollController,
    required this.moviesList,
    required this.imageQuality,
    required this.themeMode,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<Movie>? moviesList;
  final String imageQuality;
  final String themeMode;

  @override
  Widget build(BuildContext context) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          childAspectRatio: 0.48,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: moviesList!.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MovieDetailPage(
                    movie: moviesList![index],
                    heroId: '${moviesList![index].id}');
              }));
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Hero(
                      tag: '${moviesList![index].id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: moviesList![index].posterPath == null
                                  ? Image.asset('assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity)
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration:
                                          const Duration(milliseconds: 700),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          moviesList![index].posterPath!,
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
                                          Image.asset(
                                              'assets/images/na_logo.png',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity),
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: themeMode == 'dark' ||
                                            themeMode == 'amoled'
                                        ? Colors.black45
                                        : Colors.white60),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                    ),
                                    Text(
                                        moviesList![index].voteAverage! % 1 == 0
                                            ? moviesList![index]
                                                .voteAverage!
                                                .toInt()
                                                .toString()
                                            : moviesList![index]
                                                .voteAverage!
                                                .toStringAsFixed(1))
                                  ],
                                ),
                              ),
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
                        moviesList![index].title!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          );
        });
  }
}
