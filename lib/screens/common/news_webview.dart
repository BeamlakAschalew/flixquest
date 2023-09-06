// // ignore_for_file: avoid_print
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:share_plus/share_plus.dart';

// class NewsWebView extends StatefulWidget {
//   final String articleUrl;
//   final String articleName;
//   const NewsWebView({
//     Key? key,
//     required this.articleUrl,
//     required this.articleName,
//   }) : super(key: key);

//   @override
//   NewsWebViewState createState() => NewsWebViewState();
// }

// class NewsWebViewState extends State<NewsWebView> {
//   final GlobalKey webViewKey = GlobalKey();

//   InAppWebViewController? webViewController;
//   InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
//       crossPlatform: InAppWebViewOptions(
//         useShouldOverrideUrlLoading: true,
//         mediaPlaybackRequiresUserGesture: false,
//         supportZoom: false,
//       ),
//       android: AndroidInAppWebViewOptions(
//         useHybridComposition: true,
//       ),
//       ios: IOSInAppWebViewOptions(
//         allowsInlineMediaPlayback: true,
//       ));

//   late PullToRefreshController pullToRefreshController;
//   String url = "";
//   double progress = 0;
//   final urlController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     pullToRefreshController = PullToRefreshController(
//       options: PullToRefreshOptions(
//         color: Theme.of(context).colorScheme.primary,
//       ),
//       onRefresh: () async {
//         if (Platform.isAndroid) {
//           webViewController?.reload();
//         } else if (Platform.isIOS) {
//           webViewController?.loadUrl(
//               urlRequest: URLRequest(url: await webViewController?.getUrl()));
//         }
//       },
//     );

//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Cinemax news'),
//           actions: [
//             IconButton(
//                 onPressed: () async {
//                   await Share.share(
//                       '${widget.articleName} \n${widget.articleUrl}');
//                 },
//                 icon: const Icon(Icons.share))
//           ],
//         ),
//         body: SafeArea(
//           child: Column(children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   InAppWebView(
//                     key: webViewKey,
//                     initialUrlRequest:
//                         URLRequest(url: Uri.parse(widget.articleUrl)),
//                     initialOptions: options,
//                     pullToRefreshController: pullToRefreshController,
//                     onWebViewCreated: (controller) {
//                       webViewController = controller;
//                     },
//                     onLoadStart: (controller, url) {
//                       setState(() {
//                         this.url = url.toString();
//                         urlController.text = this.url;
//                       });
//                     },
//                     androidOnPermissionRequest:
//                         (controller, origin, resources) async {
//                       return PermissionRequestResponse(
//                           resources: resources,
//                           action: PermissionRequestResponseAction.GRANT);
//                     },
//                     onLoadStop: (controller, url) async {
//                       pullToRefreshController.endRefreshing();
//                       setState(() {
//                         this.url = url.toString();
//                         urlController.text = this.url;
//                       });
//                     },
//                     onLoadError: (controller, url, code, message) {
//                       pullToRefreshController.endRefreshing();
//                     },
//                     onProgressChanged: (controller, progress) {
//                       if (progress == 100) {
//                         pullToRefreshController.endRefreshing();
//                       }
//                       setState(() {
//                         this.progress = progress / 100;
//                         urlController.text = url;
//                       });
//                     },
//                     onUpdateVisitedHistory: (controller, url, androidIsReload) {
//                       setState(() {
//                         this.url = url.toString();
//                         urlController.text = this.url;
//                       });
//                     },
//                     onConsoleMessage: (controller, consoleMessage) {
//                       print(consoleMessage);
//                     },
//                   ),
//                   progress < 1.0
//                       ? LinearProgressIndicator(
//                           value: progress,
//                         )
//                       : Container(),
//                 ],
//               ),
//             ),
//           ]),
//         ));
//   }
// }
