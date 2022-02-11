// ignore_for_file: avoid_unnecessary_containers

import 'package:cinemax/modals/tv_genres.dart';
import 'package:cinemax/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cinemax/api/endpoints.dart';

class TVGenreMovies extends StatelessWidget {
  final TVGenres tvGenres;
  const TVGenreMovies({Key? key, required this.tvGenres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tvGenres.genreName!,
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
          genreId: tvGenres.genreID!,
          api: Endpoints.getTVForGenre(tvGenres.genreID!, 1),
        ),
      ),
    );
  }
}
