import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:cinemax/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:flutter/material.dart';
import 'about.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;
  @override
  void initState() {
    super.initState();
    startAppSdk
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAd = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFFFFFFFF) : Color(0xFF363636),
                  ),
                  child: Image.asset('assets/images/logo_shadow.png'),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: Color(0xFFF57C00),
                ),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return const Settings();
                  })));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFF57C00),
                ),
                title: const Text('About'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AboutPage();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.share_sharp,
                  color: Color(0xFFF57C00),
                ),
                title: const Text('Share the app'),
                onTap: () async {
                  await Share.share(
                      'Download the Cinemax app for free and watch your favorite movies and TV shows for free! Download the app from the link below.\nhttps://cinemax.rf.gd/');
                },
              ),
            ],
          ),
          bannerAd != null ? StartAppBanner(bannerAd!) : Container(),
        ],
      ),
    );
  }
}
