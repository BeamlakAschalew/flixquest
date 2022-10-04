// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:cinemax/constants/api_constants.dart';
import 'package:cinemax/constants/app_constants.dart';
import 'package:cinemax/models/function.dart';
import 'package:cinemax/models/update.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:provider/provider.dart';
import '../provider/darktheme_provider.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  UpdateChecker? updateChecker;
  var downloadManager = DownloadManager();
  var savedDir = "";

  @override
  void initState() {
    checkForUpdate(CINEMAX_UPDATE_URL).then((value) {
      setState(() {
        updateChecker = value;
      });
    });
    getApplicationSupportDirectory().then((value) {
      setState(() {
        savedDir = value.path;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check for update'),
      ),
      body: Container(
          color: isDark ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
          child: updateChecker == null
              ? const Center(child: CircularProgressIndicator())
              : updateChecker!.versionNumber != currentAppVersion
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Update is available!',
                            style: kTextHeaderStyle,
                          ),
                          Text(
                            'New update version: ${updateChecker!.versionNumber!}',
                            style: kTextSmallBodyStyle,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return SimpleDialog(
                                          title: const Text('Changelogs'),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  updateChecker!.changeLog!),
                                            )
                                          ]);
                                    });
                              },
                              child: const Text('See changelogs')),
                          ListItem(
                              appVersion: updateChecker!.versionNumber!,
                              onDownloadPlayPausedPressed: (url) async {
                                setState(() {
                                  var task = downloadManager.getDownload(url);

                                  if (task != null &&
                                      !task.status.value.isCompleted) {
                                    switch (task.status.value) {
                                      case DownloadStatus.downloading:
                                        downloadManager.pauseDownload(url);
                                        break;
                                      case DownloadStatus.paused:
                                        downloadManager.resumeDownload(url);
                                        break;
                                      case DownloadStatus.queued:
                                        break;
                                      case DownloadStatus.completed:
                                        break;
                                      case DownloadStatus.failed:
                                        break;
                                      case DownloadStatus.canceled:
                                        break;
                                    }
                                  } else {
                                    downloadManager.addDownload(url,
                                        "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
                                  }
                                });
                              },
                              onOpen: (url) async {
                                // OpenFile.open(
                                //     "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
                                var fileName =
                                    "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
                                var file = File(fileName);
                                OpenFile.open(file.path);
                              },
                              onDelete: (url) async {
                                var fileName =
                                    "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
                                var file = File(fileName);
                                file.delete();
                              },
                              url: updateChecker!.downloadLink!,
                              downloadTask: downloadManager
                                  .getDownload(updateChecker!.downloadLink!)),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No need to download anything, Your app version is up-to-date!',
                        textAlign: TextAlign.center,
                        style: kTextHeaderStyle,
                      ),
                    )),
    );
  }
}

class ListItem extends StatefulWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onOpen;
  final Function(String) onDelete;
  DownloadTask? downloadTask;
  String url = "";
  String appVersion;

  ListItem(
      {Key? key,
      required this.url,
      required this.onDownloadPlayPausedPressed,
      required this.onOpen,
      required this.appVersion,
      required this.onDelete,
      this.downloadTask})
      : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFF57C00),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Cinemax v${widget.appVersion}',
                      overflow: TextOverflow.ellipsis,
                      style: kTextSmallBodyStyle,
                    ),
                    if (widget.downloadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.downloadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                  value == DownloadStatus.downloading
                                      ? 'downloading file...'
                                      : value == DownloadStatus.completed
                                          ? 'file downloaded'
                                          : value == DownloadStatus.failed
                                              ? 'downloading failed'
                                              : value == DownloadStatus.paused
                                                  ? 'downloading paused'
                                                  : value ==
                                                          DownloadStatus
                                                              .canceled
                                                      ? 'download cancelled'
                                                      : value.toString(),
                                  style: const TextStyle(fontSize: 16)),
                            );
                          }),
                  ],
                )),
              ],
            ), // if (widget.item.isDownloadingOrPaused)
            if (widget.downloadTask != null &&
                !widget.downloadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: widget.downloadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: widget.downloadTask!.progress.value,
                        color: widget.downloadTask!.status.value ==
                                DownloadStatus.paused
                            ? Colors.grey
                            : const Color(0xFFF57C00),
                      ),
                    );
                  }),
            widget.downloadTask != null
                ? ValueListenableBuilder(
                    valueListenable: widget.downloadTask!.status,
                    builder: (context, value, child) {
                      switch (widget.downloadTask!.status.value) {
                        case DownloadStatus.downloading:
                          return ElevatedButton(
                              onPressed: () {
                                widget.onDownloadPlayPausedPressed(widget.url);
                              },
                              child: const Text('PAUSE'));

                        case DownloadStatus.paused:
                          return ElevatedButton(
                              onPressed: () {
                                widget.onDownloadPlayPausedPressed(widget.url);
                              },
                              child: const Text('RESUME'));

                        case DownloadStatus.completed:
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      widget.onOpen(widget.url);
                                    },
                                    child: const Text('INSTALL')),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    widget.onDelete(widget.url);
                                  },
                                  child: const Text('DELETE')),
                            ],
                          );
                        case DownloadStatus.failed:
                        case DownloadStatus.canceled:
                          return ElevatedButton(
                              onPressed: () {
                                widget.onDownloadPlayPausedPressed(widget.url);
                              },
                              child: const Text('DOWNLOAD'));
                        case DownloadStatus.queued:
                          break;
                      }
                      return Text("$value",
                          style: const TextStyle(fontSize: 16));
                    })
                : ElevatedButton(
                    onPressed: () {
                      widget.onDownloadPlayPausedPressed(widget.url);
                    },
                    child: const Text('DOWNLOAD'))
          ],
        ),
      ),
    );
  }
}
