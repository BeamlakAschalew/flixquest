// ignore_for_file: avoid_unnecessary_containers

import 'package:easy_localization/easy_localization.dart';

import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';

import '/models/genres.dart';
import '/widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import '/api/endpoints.dart';

class TVGenre extends StatelessWidget {
  final Genres genres;
  const TVGenre({Key? key, required this.genres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(
          "genre_tv_title",
          namedArgs: {"g": genres.genreName ?? "Null"},
        )),
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
          includeAdult: Provider.of<SettingsProvider>(context).isAdult,
          genreId: genres.genreID!,
          api: Endpoints.getTVShowsForGenre(genres.genreID!, 1, lang),
        ),
      ),
    );
  }
}
