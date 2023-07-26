import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                  'Cinemax v2.1.1',
                  style: TextStyle(
                    fontSize: 27.0,
                  ),
                ),
                const Text(
                  'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 20.0, overflow: TextOverflow.visible),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(
                        Uri.parse(
                          'https://themoviedb.org',
                        ),
                        mode: LaunchMode.externalApplication);
                  },
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset('assets/images/tmdb_logo.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: const Text(
                      'Noticed any bugs? Inform me on Telegram, click here',
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid),
                    ),
                    onTap: () {
                      launchUrl(Uri.parse('https://t.me/birrle'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      'Follow Cinemax on various platforms',
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      style: kTextSmallHeaderStyle,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black26,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.twitter,
                            uri: 'https://twitter.com/cinemaxapp',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.instagram,
                            uri: 'https://instagram.com/cinemaxhq',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.telegram,
                            uri: 'https://t.me/cinemaxapp',
                          ),
                          SocialIconContainer(
                              platformIcon: FontAwesomeIcons.tiktok,
                              uri: 'https://www.tiktok.com/@cinemaxapp'),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.facebook,
                            uri:
                                'https://m.facebook.com/profile.php?id=100086435380480',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.github,
                            uri: 'https://github.com/beamlakaschalew/cinemax',
                          ),
                          SocialIconContainer(
                              platformIcon: Icons.mail,
                              uri: 'mailto:cinemaxappinfo@gmail.com'),
                        ],
                      ),
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 30,
                    left: 7.0,
                    right: 7.0,
                  ),
                  child: Text(
                    'Made with ❤️ by Beamlak Aschalew',
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('2015 EC, 2023 GC'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialIconContainer extends StatelessWidget {
  const SocialIconContainer({
    required this.platformIcon,
    required this.uri,
    Key? key,
  }) : super(key: key);

  final IconData platformIcon;
  final String uri;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: PlatformIcon(platformIcon: platformIcon, uri: uri),
    );
  }
}

class PlatformIcon extends StatelessWidget {
  const PlatformIcon({
    required this.platformIcon,
    required this.uri,
    Key? key,
  }) : super(key: key);

  final IconData platformIcon;
  final String uri;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
      },
      child: Icon(
        platformIcon,
      ),
    );
  }
}
