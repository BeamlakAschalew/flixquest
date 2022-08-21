import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/models/function.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/constants/api_constants.dart';
import '/models/person.dart';
import 'package:flutter/material.dart';
import '/models/movie.dart';
import '/models/tv.dart';
import 'movie_detail.dart';
import 'searchedperson.dart';
import 'tv_detail.dart';

class Search extends SearchDelegate<String> {
  final Mixpanel mixpanel;
  final bool includeAdult;
  Search({required this.mixpanel, required this.includeAdult})
      : super(
          searchFieldLabel: 'Search for a movie, TV show or a person',
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return ThemeData(
      appBarTheme: AppBarTheme(
          backgroundColor: isDark ? Color(0xFF000000) : Color(0xFFFFFFFF)),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
            color: isDark ? Colors.white24 : Colors.black26,
            fontFamily: 'Poppins'),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      textTheme: TextTheme(
        headline6: TextStyle(
            color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins'),
      ),
      // colorScheme: const ColorScheme(
      //   primary: Color(0xFFF57C00),
      //   primaryContainer: Color(0xFF8f4700),
      //   secondary: Color(0xFF202124),
      //   secondaryContainer: Color(0xFF141517),
      //   surface: Color(0xFFF57C00),
      //   background: Color(0xFF202124),
      //   error: Color(0xFFFF0000),
      //   onPrimary: Color(0xFF202124),
      //   onSecondary: Color(0xFF141517),
      //   onSurface: Color(0xFF141517),
      //   onBackground: Color(0xFFF57C00),
      //   onError: Color(0xFFFFFFFF),
      //   brightness: Brightness.dark,
      // ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFFF57C00),
        selectionHandleColor: isDark ? Color(0xFFFFFFFF) : Color(0xFF000000),
        selectionColor: isDark ? Colors.white12 : Colors.black12,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(
          Icons.clear,
          color: Color(0xFFF57C00),
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFFF57C00)),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Container(
          color: isDark ? Colors.black : Colors.white,
          child: Column(
            children: [
              TabBar(
                indicatorColor: Color(0xFFF57C00),
                tabs: [
                  Tab(
                    child: Text('Movies',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text('TV Shows',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text('Person',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  )
                ],
              ),
              Expanded(
                  child: TabBarView(children: [
                FutureBuilder<List<Movie>>(
                  future: fetchMovies(
                      Endpoints.movieSearchUrl(query, includeAdult)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return searchATermWidget(isDark);

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return searchLoadingWidget(isDark);
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return errorMessageWidget(isDark);
                        } else {
                          return activeMovieSearch(snapshot.data!, isDark);
                        }
                    }
                  },
                ),
                FutureBuilder<List<TV>>(
                  future: fetchTV(Endpoints.tvSearchUrl(query, includeAdult)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return searchATermWidget(isDark);

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return searchLoadingWidget(isDark);
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return errorMessageWidget(isDark);
                        } else {
                          return activeTVSearch(snapshot.data!, isDark);
                        }
                    }
                  },
                ),
                FutureBuilder<List<Person>>(
                  future: fetchPerson(
                      Endpoints.personSearchUrl(query, includeAdult)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return searchATermWidget(isDark);
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return searchLoadingWidget(isDark);
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return errorMessageWidget(isDark);
                        } else {
                          return activePersonSearch(snapshot.data!, isDark);
                        }
                    }
                  },
                ),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget errorMessageWidget(bool isDark) {
    return Container(
      color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/404.png'),
            const Text(
              'The term you entered didn\'t bring any results',
              style: TextStyle(fontFamily: 'Poppins'),
            )
          ],
        ),
      ),
    );
  }

  Widget searchLoadingWidget(bool isDark) {
    return Container(
      color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFF57C00)),
      ),
    );
  }

  Widget searchATermWidget(bool isDark) {
    return Container(
      color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/search.png'),
            const Padding(padding: EdgeInsets.only(top: 10, bottom: 5)),
            Text('Enter a word to search',
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: 'Poppins'))
          ],
        ),
      ),
    );
  }

  Widget activeMovieSearch(List<Movie> moviesList, bool isDark) {
    return Container(
        color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: moviesList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed movie pages', properties: {
                            'Movie name': '${moviesList[index].originalTitle}',
                            'Movie id': '${moviesList[index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MovieDetailPage(
                              movie: moviesList[index],
                              heroId: '${moviesList[index].id}',
                            );
                          }));
                        },
                        child: Container(
                          color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
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
                                          const EdgeInsets.only(right: 10.0),
                                      child: SizedBox(
                                        width: 85,
                                        height: 130,
                                        child: Hero(
                                          tag: '${moviesList[index].id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: moviesList[index]
                                                        .posterPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            moviesList[index]
                                                                .posterPath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            moviesList[index].title!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 15,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              const Icon(Icons.star,
                                                  color: Color(0xFFF57C00)),
                                              Text(
                                                moviesList[index]
                                                    .voteAverage!
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
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
            ),
          ],
        ));
  }

  Widget activeTVSearch(List<TV> tvList, bool isDark) {
    return Container(
        color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tvList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          mixpanel.track('Most viewed TV pages', properties: {
                            'TV series name': '${tvList[index].originalName}',
                            'TV series id': '${tvList[index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return TVDetailPage(
                                tvSeries: tvList[index],
                                heroId: '${tvList[index].id}');
                          }));
                        },
                        child: Container(
                          color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
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
                                          const EdgeInsets.only(right: 10.0),
                                      child: SizedBox(
                                        width: 85,
                                        height: 130,
                                        child: Hero(
                                          tag: '${tvList[index].id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: tvList[index].posterPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            tvList[index]
                                                                .posterPath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tvList[index].originalName!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 15,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              const Icon(Icons.star,
                                                  color: Color(0xFFF57C00)),
                                              Text(
                                                tvList[index]
                                                    .voteAverage!
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
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
            ),
          ],
        ));
  }

  Widget activePersonSearch(List<Person>? personList, bool isDark) {
    return Container(
        color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: personList!.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  mixpanel.track('Most viewed person pages', properties: {
                    'Person name': '${personList[index].name}',
                    'Person id': '${personList[index].id}'
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SearchedPersonDetailPage(
                        person: personList[index],
                        heroId: '${personList[index].id}');
                  }));
                },
                child: Container(
                  color: isDark ? Color(0xFF202124) : Color(0xFFDFDEDE),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 3.0,
                      bottom: 3.0,
                      left: 15,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: Hero(
                                  tag: '${personList[index].id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: personList[index].profilePath == null
                                        ? Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            fadeOutDuration: const Duration(
                                                milliseconds: 300),
                                            fadeOutCurve: Curves.easeOut,
                                            fadeInDuration: const Duration(
                                                milliseconds: 700),
                                            fadeInCurve: Curves.easeIn,
                                            imageUrl: TMDB_BASE_IMAGE_URL +
                                                'w500/' +
                                                personList[index].profilePath!,
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
                                                Image.asset(
                                              'assets/images/loading.gif',
                                              fit: BoxFit.cover,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
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
                                    personList[index].name!,
                                    style: const TextStyle(
                                        fontFamily: 'PoppinsSB', fontSize: 17),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Divider(
                          color: !isDark ? Colors.black54 : Colors.white54,
                          thickness: 1,
                          endIndent: 20,
                          indent: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  Widget buildSuggestionsSuccess(List<TV> moviesList) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Column(
          children: const [
            TabBar(
              tabs: [
                Tab(
                  text: 'Movies',
                ),
                Tab(
                  text: 'TV',
                ),
                Tab(
                  text: 'Person',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
