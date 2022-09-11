import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class HeroPhotoView extends StatefulWidget {
  const HeroPhotoView(
      {required this.imageProvider, required this.heroId, Key? key})
      : super(key: key);
  final ImageProvider imageProvider;
  final String heroId;

  @override
  State<HeroPhotoView> createState() => _HeroPhotoViewState();
}

class _HeroPhotoViewState extends State<HeroPhotoView> {
  Future<String> createFolder(String passedFolderName, pa2) async {
    final folderName = passedFolderName;
    final folderName2 = pa2;
    final path = Directory("storage/emulated/0/$folderName/$pa2");
    var status = await Permission.storage.status;
    var status2 = await Permission.manageExternalStorage.status;
    print(status2);
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if (!status2.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if ((await path.exists())) {
      return path.path;
    } else {
      path.create();
      return path.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          Expanded(
            flex: 10,
            child: PhotoView(
              imageProvider: widget.imageProvider,
              heroAttributes: PhotoViewHeroAttributes(tag: widget.heroId),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              child: const Text('DOWNLOAD'),
              onPressed: () async {
                await createFolder('Cinemax', 'movie backdrops');
                final taskId = await FlutterDownloader.enqueue(
                  url: widget.heroId,
                  headers: {}, // optional: header send with url (auth token etc)
                  savedDir: '/storage/emulated/0/Cinemax/movie backdrops/',
                  showNotification:
                      true, // show download progress in status bar (for Android)
                  openFileFromNotification:
                      true, // click on notification to open downloaded file (for Android)
                );
              },
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      const Size(double.infinity, 50)),
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFFF57C00))),
            ),
          ),
        ],
      )),
    );
  }
}
