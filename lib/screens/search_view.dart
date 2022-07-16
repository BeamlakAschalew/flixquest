import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/modals/function.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../constants/api_constants.dart';
import '../modals/person.dart';
import '/screens/common_widgets.dart';
import 'package:flutter/material.dart';
import '/modals/movie.dart';
import '/modals/tv.dart';
import 'movie_detail.dart';
import 'searchedperson.dart';
import 'tv_detail.dart';

class Search extends SearchDelegate<String> {
  final Mixpanel mixpanel;
  Search({required this.mixpanel})
      : super(
          searchFieldLabel: 'Search for a movie, TV show or a person',
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF000000)),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Poppins'),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      textTheme: const TextTheme(
        headline6: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      ),
      colorScheme: const ColorScheme(
        primary: Color(0xFFF57C00),
        primaryContainer: Color(0xFF8f4700),
        secondary: Color(0xFF202124),
        secondaryContainer: Color(0xFF141517),
        surface: Color(0xFFF57C00),
        background: Color(0xFF202124),
        error: Color(0xFFFF0000),
        onPrimary: Color(0xFF202124),
        onSecondary: Color(0xFF141517),
        onSurface: Color(0xFF141517),
        onBackground: Color(0xFFF57C00),
        onError: Color(0xFFFFFFFF),
        brightness: Brightness.dark,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFF57C00),
        selectionHandleColor: Color(0xFFFFFFFF),
        selectionColor: Colors.white12,
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
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    child:
                        Text('Movies', style: TextStyle(fontFamily: 'Poppins')),
                  ),
                  Tab(
                    text: 'TV',
                  ),
                  Tab(
                    text: 'Actor / Actress',
                  )
                ],
              ),
              Expanded(
                  child: TabBarView(children: [
                FutureBuilder<List<Movie>>(
                  future: fetchMovies(Endpoints.movieSearchUrl(query)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return Text('search a damn thing');

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return ErrorMessageWidget();
                        } else {
                          return activeMovieSearch(snapshot.data!, mixpanel);
                        }
                    }
                  },
                ),
                FutureBuilder<List<TV>>(
                  future: fetchTV(Endpoints.tvSearchUrl(query)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return Text('search a damn thing');

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return Container(
                            child: Text('no data'),
                          );
                        } else {
                          return activeTVSearch(snapshot.data!);
                        }
                    }
                  },
                ),
                FutureBuilder<List<Person>>(
                  future: fetchPerson(Endpoints.personSearchUrl(query)),
                  builder: (context, snapshot) {
                    if (query.isEmpty) return Text('search a damn thing');

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError || snapshot.data!.isEmpty) {
                          return Container(
                            child: Text('no data'),
                          );
                        } else {
                          return activePersonSearch(snapshot.data!);
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

  Widget ErrorMessageWidget() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/404.png'),
            Text('The term you entered didn\'t bring any results')
          ],
        ),
      ),
    );
  }

  Widget activeMovieSearch(List<Movie> moviesList, Mixpanel mixpanel) {
    return Container(
        color: const Color(0xFF202124),
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
                          color: const Color(0xFF202124),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 8.0,
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
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            moviesList[index]
                                                                .posterPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
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
                                const Divider(
                                  color: Colors.white,
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

  Widget activeTVSearch(List<TV> tvList) {
    return Container(
        color: const Color(0xFF202124),
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
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return TVDetailPage(
                                tvSeries: tvList[index],
                                heroId: '${tvList[index].id}');
                          }));
                        },
                        child: Container(
                          color: const Color(0xFF202124),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 8.0,
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
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            tvList[index]
                                                                .posterPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
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
                                const Divider(
                                  color: Colors.white,
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

  Widget activePersonSearch(List<Person>? personList) {
    return Container(
        color: const Color(0xFF202124),
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return SearchedPersonDetailPage(
                        person: personList[index],
                        heroId: '${personList[index].id}');
                  }));
                },
                child: Container(
                  color: const Color(0xFF202124),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      bottom: 15.0,
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
                                            'assets/images/na_square.png',
                                            fit: BoxFit.cover,
                                          )
                                        : FadeInImage(
                                            image: NetworkImage(
                                                TMDB_BASE_IMAGE_URL +
                                                    'w500/' +
                                                    personList[index]
                                                        .profilePath!),
                                            fit: BoxFit.cover,
                                            placeholder: const AssetImage(
                                                'assets/images/loading.gif'),
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
        body: Container(
          child: Column(
            children: [
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
              Expanded(
                child: TabBarView(children: [
                  ListView.builder(
                      itemCount: moviesList.length,
                      itemBuilder: (context, index) {
                        final movieName = moviesList[index].originalName;
                        return Text(movieName!);
                      }),
                  Center(
                    child: Text('2'),
                  ),
                  Center(
                    child: Text('3'),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
