import 'dart:io';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:isolate';
import 'dart:ui';

import 'package:provider/provider.dart';

class HeroPhotoView extends StatefulWidget {
  const HeroPhotoView(
      {required this.imageProvider,
      required this.currentIndex,
      required this.name,
      required this.heroId,
      Key? key})
      : super(key: key);
  final ImageProvider imageProvider;
  final String heroId;
  final String currentIndex;
  final String name;

  @override
  State<HeroPhotoView> createState() => _HeroPhotoViewState();
}

class _HeroPhotoViewState extends State<HeroPhotoView> {
  final ReceivePort _port = ReceivePort();

  Future<String> createFolder(
      String cinemaxFolderName,
      String imageTypeFolderName,
      String posterFolder,
      String stillFolder,
      String personImageFolder) async {
    final cinefolderName = cinemaxFolderName;
    final imagefolderName = imageTypeFolderName;
    final posterFolderName = posterFolder;
    final stillFolderName = stillFolder;
    final personImageFolderName = personImageFolder;
    final cinemaxPath = Directory("storage/emulated/0/$cinefolderName");
    final imageTypePath =
        Directory("storage/emulated/0/Cinemax/$imagefolderName");
    final posterPath =
        Directory("storage/emulated/0/Cinemax/$posterFolderName");
    final stillPath = Directory("storage/emulated/0/Cinemax/$stillFolderName");
    final personImagePath =
        Directory("storage/emulated/0/Cinemax/$personImageFolderName");
    var storageStatus = await Permission.storage.status;
    var externalStatus = await Permission.manageExternalStorage.status;
    var mediaStatus = await Permission.accessMediaLocation.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    if (!externalStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if (!mediaStatus.isGranted) {
      await Permission.accessMediaLocation.request();
    }
    if ((await cinemaxPath.exists())) {
      imageTypePath.create();
      posterPath.create();
      stillPath.create();
      personImagePath.create();
      return cinemaxPath.path;
    } else {
      cinemaxPath.create();
      posterPath.create();
      imageTypePath.create();
      stillPath.create();
      personImagePath.create();
      return cinemaxPath.path;
    }
  }

//TODO: uncomment this on release @pragma('vm:entry-point')
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

  void _download(String url, String currentIndex, bool isDark) async {
    final status = await Permission.storage.request();
    // final status2 = await Permission.accessMediaLocation.request();

    if (status.isGranted) {
      await createFolder(
          'Cinemax', 'Backdrops', 'Posters', 'Stills', 'Person Images');
      await FlutterDownloader.enqueue(
        url: url,
        fileName: '${widget.name}_$currentIndex.jpg',
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: '/storage/emulated/0/Cinemax/Person Images/',
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } else {
      print('Permission Denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'File permission isn\'t given to Cinemax, therefore image couldn\'t be downloaded.',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'PoppinsSB'),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.name.endsWith('s')
                ? '${widget.name}\' image'
                : '${widget.name}\'s image'),
          ),
          body: Column(
            children: [
              Expanded(
                flex: 10,
                child: PhotoView(
                  imageProvider: widget.imageProvider,
                  backgroundDecoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
                  ),
                  enableRotation: true,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.heroId),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {},
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 50)),
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFFF57C00))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.save),
                      ),
                      Text('DOWNLOAD'),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
