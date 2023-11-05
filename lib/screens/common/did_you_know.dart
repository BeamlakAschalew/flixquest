// import 'dart:async';
// import 'dart:io';
// import '/constants/app_constants.dart';
// import '/provider/settings_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:web_scraper/web_scraper.dart';

// class DidYouKnowScreen extends StatefulWidget {
//   const DidYouKnowScreen(
//       {Key? key,
//       required this.dataType,
//       required this.dataName,
//       required this.imdbId})
//       : super(key: key);
//   final String dataType;
//   final String dataName;
//   final String imdbId;

//   @override
//   State<DidYouKnowScreen> createState() => _DidYouKnowScreenState();
// }

// class _DidYouKnowScreenState extends State<DidYouKnowScreen> {
//   final WebScraper? webScraper = WebScraper('https://imdb.com');
//   List<Map<String, dynamic>>? dataDetail;
//   List<Map<String, dynamic>>? likedNumberOfData;

//   Future<void> getData(String dataType) async {
//     try {
//       if (await retryOptions.retry(
//         () => webScraper!.loadWebPage('/title/${widget.imdbId}/$dataType/'),
//         retryIf: (e) =>
//             e is SocketException ||
//             e is TimeoutException ||
//             e is WebScraperException,
//       )) {
//         if (mounted) {
//           setState(() {
//             dataDetail = webScraper!.getElement(
//                 dataType == 'alternateversions' ||
//                         dataType == 'movieconnections'
//                     ? 'div.soda'
//                     : dataType == 'soundtrack'
//                         ? '.ipc-metadata-list__item'
//                         : 'div.sodatext',
//                 ['class']);
//             likedNumberOfData = webScraper!.getElement(
//                 'div.did-you-know-actions > a.interesting-count-text',
//                 ['href']);
//           });
//         }
//       }
//     } finally {
//       client.close();
//     }
//   }

//   @override
//   void initState() {
//     getData(widget.dataType);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeMode = Provider.of<SettingsProvider>(context).appTheme;
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.dataName),
//         ),
//         body: Container(
//           child: dataDetail == null
//               ? const Center(child: CircularProgressIndicator())
//               : dataDetail!.isEmpty
//                   ? Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Center(
//                         child: Text(
//                           'There are no ${widget.dataName} available for this title :(',
//                           textAlign: TextAlign.center,
//                           style: kTextHeaderStyle,
//                         ),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: dataDetail!.length,
//                       itemBuilder: ((context, index) {
//                         return Container(
//                           color: themeMode == "light"
//                               ? index.isEven
//                                   ? Colors.grey.shade300
//                                   : Colors.grey.shade100
//                               : themeMode
//                                   ? index.isEven
//                                       ? Colors.grey.shade900
//                                       : Colors.grey.shade800
//                                   : Colors.blue,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   dataDetail![index]['title'],
//                                   textAlign: TextAlign.start,
//                                 ),
//                               )
//                             ],
//                           ),
//                         );
//                       })),
//         ));
//   }
// }
