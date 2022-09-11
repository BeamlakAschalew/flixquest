import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40.0),
                        child: Image.asset(
                          'assets/images/logo_shadow.png',
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Cinemax 1.3.0',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
                const Text(
                  'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 20.0, overflow: TextOverflow.visible),
                ),
                SizedBox(
                  child: Image.asset('assets/images/tmdb_logo.png'),
                  height: 100,
                  width: 100,
                ),
                GestureDetector(
                  child: const Text(
                    'https://themoviedb.org',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                  ),
                  onTap: () {
                    launchUrl(
                        Uri.parse(
                          'https://themoviedb.org',
                        ),
                        mode: LaunchMode.externalApplication);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: const Text(
                      'Noticed any bugs? Inform me on Telegram, click here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid),
                    ),
                    onTap: () {
                      launchUrl(Uri.parse('https://t.me/beamlakaschalew'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 30,
                    left: 7.0,
                    right: 7.0,
                  ),
                  child: Text(
                    'Made with ❤️ by Beamlak Aschalew',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('2014 EC, 2022 GC'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// 
