import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
                  'Cinemax 1.2.1',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
                const Text(
                  'This app uses TMDB as a data provider',
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
                    launch('https://themoviedb.org');
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
                      launch('https://t.me/beamlakaschalew');
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
                  child: Text('2014 EC, 2021 GC'),
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
