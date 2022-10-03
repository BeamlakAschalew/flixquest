import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/api_constants.dart';
import '../models/images.dart';
import '../provider/imagequality_provider.dart';

class HeroPhotoView extends StatefulWidget {
  const HeroPhotoView(
      {required this.imageType,
      this.name,
      this.stills,
      this.posters,
      this.backdrops,
      Key? key})
      : super(key: key);
  final List<Backdrops>? backdrops;
  final List<Posters>? posters;
  final List<Stills>? stills;
  final String? name;
  final String imageType;

  @override
  State<HeroPhotoView> createState() => _HeroPhotoViewState();
}

class _HeroPhotoViewState extends State<HeroPhotoView> {
  int currentIndex = 0;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<String> createFolder(
      String cinemaxFolderName,
      String imageTypeFolderName,
      String posterFolder,
      String stillFolder) async {
    final cinefolderName = cinemaxFolderName;
    final imagefolderName = imageTypeFolderName;
    final posterFolderName = posterFolder;
    final stillFolderName = stillFolder;
    final cinemaxPath = Directory("storage/emulated/0/$cinefolderName");
    final imageTypePath =
        Directory("storage/emulated/0/Cinemax/$imagefolderName");
    final posterPath =
        Directory("storage/emulated/0/Cinemax/$posterFolderName");
    final stillPath = Directory("storage/emulated/0/Cinemax/$stillFolderName");
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
      return cinemaxPath.path;
    } else {
      cinemaxPath.create();
      posterPath.create();
      imageTypePath.create();
      stillPath.create();
      return cinemaxPath.path;
    }
  }

  void _download(String url, String currentIndex, bool isDark) async {
    final status = await Permission.storage.request();
    // final status2 = await Permission.accessMediaLocation.request();

    if (status.isGranted) {
      await createFolder('Cinemax', 'Backdrops', 'Posters', 'Stills');
      await FlutterDownloader.enqueue(
        url: url,
        fileName: '${widget.name}_${widget.imageType}_$currentIndex.jpg',
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: widget.imageType == 'backdrop'
            ? '/storage/emulated/0/Cinemax/Backdrops/'
            : widget.imageType == 'poster'
                ? '/storage/emulated/0/Cinemax/Stills/'
                : '/storage/emulated/0/Cinemax/Posters/',
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

  final ReceivePort _port = ReceivePort();

  //TODO: uncomment this on release @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.imageType == 'backdrop'
              ? '${currentIndex + 1} / ${widget.backdrops!.length}'
              : widget.imageType == 'still'
                  ? '${currentIndex + 1} / ${widget.stills!.length}'
                  : '${currentIndex + 1} / ${widget.posters!.length}'),
          actions: [
            IconButton(
              onPressed: () async {
                _download(
                    widget.imageType == 'backdrop'
                        ? TMDB_BASE_IMAGE_URL +
                            imageQuality +
                            widget.backdrops![currentIndex].filePath!
                        : widget.imageType == 'poster'
                            ? TMDB_BASE_IMAGE_URL +
                                imageQuality +
                                widget.posters![currentIndex].posterPath!
                            : TMDB_BASE_IMAGE_URL +
                                imageQuality +
                                widget.stills![currentIndex].stillPath!,
                    currentIndex.toString(),
                    isDark);
              },
              icon: Icon(Icons.download),
            )
          ]),
      body: Container(
          child: Stack(alignment: Alignment.bottomRight, children: [
        PhotoViewGallery.builder(
          allowImplicitScrolling: true,
          backgroundDecoration: BoxDecoration(
            color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
          ),
          gaplessPlayback: true,
          wantKeepAlive: true,
          enableRotation: true,
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(
                widget.imageType == 'backdrop'
                    ? TMDB_BASE_IMAGE_URL +
                        imageQuality +
                        widget.backdrops![currentIndex].filePath!
                    : widget.imageType == 'poster'
                        ? TMDB_BASE_IMAGE_URL +
                            imageQuality +
                            widget.posters![currentIndex].posterPath!
                        : TMDB_BASE_IMAGE_URL +
                            imageQuality +
                            widget.stills![currentIndex].stillPath!,
              ),

              // imageProvider: NetworkImage(
              //
              // ),
              initialScale: PhotoViewComputedScale.contained * 0.95,
              // heroAttributes: PhotoViewHeroAttributes(
              //   // tag: widget.imageType == 'backdrop'
              //   //     ? widget.backdrops![index].filePath!
              //   //     : widget.posters![index].posterPath!,
              // ),
            );
          },
          itemCount: widget.imageType == 'backdrop'
              ? widget.backdrops!.length
              : widget.imageType == 'poster'
                  ? widget.posters!.length
                  : widget.stills!.length,
          onPageChanged: onPageChanged,
          // loadingBuilder: (context, chuck) {
          //   return Center(
          //     child: CircularProgressIndicator(),
          //   );
          // },
          loadingBuilder: (context, event) => Container(
            color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
            child: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Image ${currentIndex + 1}",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 17.0,
              decoration: null,
            ),
          ),
        )
      ])),
    );
  }
}
