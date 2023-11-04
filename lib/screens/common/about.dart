import 'package:easy_localization/easy_localization.dart';

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
        title: Text(tr("about")), // Translate "About"
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
                          'assets/images/logo.png',
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  tr("app_version", namedArgs: {"version": "2.5.0"}),
                  style: const TextStyle(
                    fontSize: 27.0,
                  ),
                ),
                Text(
                  tr("endorsment"),
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20.0, overflow: TextOverflow.visible),
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
                    child: Text(
                      tr("bug_notice"), // Translate "Noticed any bugs? Inform me on Telegram, click here"
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                    onTap: () {
                      launchUrl(Uri.parse('https://t.me/flixquestcommunity'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                Column(
                  children: [
                    Text(
                      tr("follow_cinemax"),
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
                            platformIcon: FontAwesomeIcons.instagram,
                            uri: 'https://instagram.com/flixquestapp',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.telegram,
                            uri: 'https://t.me/flixquestapp',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.github,
                            uri: 'https://github.com/beamlakaschalew/cinemax',
                          ),
                          SocialIconContainer(
                              platformIcon: Icons.mail,
                              uri: 'mailto:flixquestapp@gmail.com'),
                        ],
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 7.0,
                    right: 7.0,
                  ),
                  child: Text(
                    tr("made_with"), // Translate "Made with ❤️ by Beamlak Aschalew"
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(tr("year_range", namedArgs: {
                    "startYear": "2016",
                    "endYear": "2023"
                  })), // Translate "2015 EC, 2023 GC"
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
