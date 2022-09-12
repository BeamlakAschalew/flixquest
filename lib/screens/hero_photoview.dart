import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:isolate';
import 'dart:ui';

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
    final path = Directory("storage/emulated/0/$folderName/$folderName2");
    var status = await Permission.storage.status;
    var status2 = await Permission.manageExternalStorage.status;
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

  final ReceivePort _port = ReceivePort();

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  void _download(String url) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      await createFolder('Cinemax', 'movie backdrops');
      await FlutterDownloader.enqueue(
        url: widget.heroId,
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: '/storage/emulated/0/Cinemax/movie backdrops/',
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } else {
      print('Permission Denied');
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
                _download(widget.heroId);
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
