import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cinemax/constants/api_constants.dart';
import 'package:flutter/services.dart';

class MovieStream extends StatefulWidget {
  final int id;
  const MovieStream({Key? key, required this.id}) : super(key: key);

  @override
  _MovieStreamState createState() => _MovieStreamState();
}

class _MovieStreamState extends State<MovieStream> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: WebView(
            initialUrl: "$EMBED_BASE_URL${widget.id}",
            navigationDelegate: (NavigationRequest request) {
              return NavigationDecision.prevent;
            },
            javascriptMode: JavascriptMode.unrestricted,
            zoomEnabled: false,
          ),
        ),
      ),
    );
  }
}
