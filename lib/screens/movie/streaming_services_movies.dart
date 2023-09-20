// ignore_for_file: avoid_unnecessary_containers

import 'package:easy_localization/easy_localization.dart';

import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/endpoints.dart';
import '/widgets/movie_widgets.dart';

class StreamingServicesMovies extends StatelessWidget {
  final int providerId;
  final String providerName;
  const StreamingServicesMovies(
      {Key? key, required this.providerId, required this.providerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("streaming_service_movie", namedArgs: {"provider": providerName}),
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
        child: ParticularStreamingServiceMovies(
          includeAdult: Provider.of<SettingsProvider>(context).isAdult,
          providerID: providerId,
          api: Endpoints.watchProvidersMovies(providerId, 1, lang),
          watchRegion: Provider.of<SettingsProvider>(context).defaultCountry,
        ),
      ),
    );
  }
}
