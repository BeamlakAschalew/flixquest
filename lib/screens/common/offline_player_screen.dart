import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/offline_download.dart';

class OfflinePlayerScreen extends StatelessWidget {
  const OfflinePlayerScreen({super.key, required this.download});

  final OfflineDownload download;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(download.title),
      ),
      body: AndroidView(
        viewType: 'dev.beamlak.flixquest/offline_player',
        creationParams: {'id': download.id},
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
