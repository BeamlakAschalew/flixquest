// ignore_for_file: avoid_unnecessary_containers

import 'package:cinemax/provider/adultmode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/endpoints.dart';
import '/screens/movie_widgets.dart';

class StreamingServicesMovies extends StatelessWidget {
  final int providerId;
  final String providerName;
  const StreamingServicesMovies(
      {Key? key, required this.providerId, required this.providerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movies from $providerName',
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
          includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
          providerID: providerId,
          api: Endpoints.watchProvidersMovies(providerId, 1),
        ),
      ),
    );
  }
}
