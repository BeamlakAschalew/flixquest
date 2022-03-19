// ignore_for_file: avoid_unnecessary_containers

import 'package:cinemax/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cinemax/api/endpoints.dart';

class StreamingServicesTVShows extends StatelessWidget {
  final int providerId;
  final String providerName;
  const StreamingServicesTVShows(
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
        child: ParticularStreamingServiceTVShows(
          providerID: providerId,
          api: Endpoints.watchProvidersTVShows(providerId, 1),
        ),
      ),
    );
  }
}
