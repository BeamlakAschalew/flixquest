// ignore_for_file: avoid_unnecessary_containers

import '../modals/movie.dart';
import '/modals/genres.dart' as gen;
import '/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import '/api/endpoints.dart';

class TVGenre extends StatelessWidget {
  final Genres genres;
  const TVGenre({Key? key, required this.genres}) : super(key: key);

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
        child: ParticularGenreTV(
          genreId: genres.genreID!,
          api: Endpoints.getTVShowsForGenre(genres.genreID!, 1),
        ),
      ),
    );
  }
}
