import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/endpoints.dart';
import '/widgets/movie_widgets.dart';
import '/models/genres.dart';

class GenreMovies extends StatelessWidget {
  final Genres genres;
  const GenreMovies({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('genre_movie_title', namedArgs: {'g': genres.genreName ?? 'Null'}),
        ),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.caretLeft(),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ParticularGenreMovies(
        includeAdult: Provider.of<SettingsProvider>(context).isAdult,
        genreId: genres.genreID!,
        api: Endpoints.getMoviesForGenre(genres.genreID!, 1, lang),
        watchRegion: Provider.of<SettingsProvider>(context).defaultCountry,
      ),
    );
  }
}
