import 'package:flutter/material.dart';
import 'package:cinemax/modals/movie.dart';
import 'package:cinemax/screens/widgets.dart';

class MovieSearch extends SearchDelegate<Movie?> {
  MovieSearch();

  @override
  ThemeData appBarTheme(BuildContext context) {
    // final ThemeData theme = (
    // hintColor: themeData!.accentColor,
    // primaryColor: Colors(0xFFF57C00),
    // textTheme: TextTheme(
    //   headline6: themeData!.textTheme.bodyText1,
    // ));
    return ThemeData(
      // primaryColor: Color(0xFFF57C00),
      // appBarTheme: AppBarTheme(backgroundColor: Color(0xFFF57C00)),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      textTheme: const TextTheme(
          headline6: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
      colorScheme: const ColorScheme(
        primary: Color(0xFFF57C00),
        primaryVariant: Color(0xFF8f4700),
        secondary: Color(0xFF202124),
        secondaryVariant: Color(0xFF141517),
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
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(
          Icons.clear,
          color: Colors.black,
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
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchMovieWidget(
      query: query,
      onTap: (movie) {
        close(context, movie);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: const Color(0xFF202124),
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              Icons.search,
              size: 50,
              color: Color(0xFFF57C00),
            ),
          ),
          Text(
            'Enter a Movie to search.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
        ],
      )),
    );
  }
}
