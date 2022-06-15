// ignore_for_file: avoid_unnecessary_containers
import 'package:flutter/material.dart';
import '../modals/movie.dart';
import '/api/endpoints.dart';
import '/screens/movie_widgets.dart';
import '/modals/genres.dart' as gen;

class GenreMovies extends StatelessWidget {
  final Genres genres;
  const GenreMovies({Key? key, required this.genres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          genres.genreName!,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: ParticularGenreMovies(
          genreId: genres.genreID!,
          api: Endpoints.getMoviesForGenre(genres.genreID!, 1),
        ),
      ),
    );
  }
}
