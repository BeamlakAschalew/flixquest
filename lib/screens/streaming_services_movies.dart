// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/screens/widgets.dart';

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
          providerName,
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
          providerID: providerId,
          api: Endpoints.watchProvidersMovies(providerId, 1),
        ),
      ),
    );
  }
}
