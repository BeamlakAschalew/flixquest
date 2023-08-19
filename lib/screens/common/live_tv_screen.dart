import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/models/live_tv.dart';
import 'package:cinemax/screens/common/live_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/function.dart';
import 'package:startapp_sdk/startapp.dart';

import '../../provider/settings_provider.dart';

class LiveTV extends StatefulWidget {
  const LiveTV({Key? key}) : super(key: key);

  @override
  State<LiveTV> createState() => _LiveTVState();
}

class _LiveTVState extends State<LiveTV> {
  var startAppSdk = StartAppSdk();

  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    startAppSdk
        .loadBannerAd(StartAppBannerType.BANNER,
            prefs: const StartAppAdPreferences(minCPM: 0.01))
        .then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
    super.initState();
  }

  final List<CatImage> categories = [
    CatImage(categoryName: 'General', imagePath: 'assets/images/general.png'),
    CatImage(
        categoryName: 'Entertainment',
        imagePath: 'assets/images/entertainment.png'),
    CatImage(categoryName: 'Sport', imagePath: 'assets/images/sport.png'),
    CatImage(categoryName: 'Family', imagePath: 'assets/images/family.png'),
    CatImage(categoryName: 'Movie', imagePath: 'assets/images/movie.png'),
    CatImage(categoryName: 'TV_Series', imagePath: 'assets/images/series.png'),
    CatImage(categoryName: 'Music', imagePath: 'assets/images/music.png'),
    CatImage(categoryName: 'News', imagePath: 'assets/images/news.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Live TV')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: Center(
                      child: GridView.count(
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                childAspectRatio: 2,
                shrinkWrap: true,
                crossAxisCount: 2, // Maximum of 3 items horizontally
                children: List.generate(categories.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (((context) {
                        return ChannelList(
                          catName: categories[index].categoryName.toLowerCase(),
                        );
                      }))));
                    },
                    child: GridTile(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: CategoryWidget(category: categories[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ))),
              bannerAd != null ? StartAppBanner(bannerAd!) : Container()
            ],
          ),
        ));
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    Key? key,
    required this.category,
  }) : super(key: key);

  final CatImage category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          category.imagePath,
          height: 40,
          width: 40,
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: Text(
            category.categoryName.replaceAll(RegExp(r'_'), ' '),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}

class ChannelList extends StatefulWidget {
  const ChannelList({Key? key, required this.catName}) : super(key: key);

  final String catName;

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  List<Channel>? channels;
  var startAppSdk = StartAppSdk();

  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    startAppSdk
        .loadBannerAd(StartAppBannerType.BANNER,
            prefs: const StartAppAdPreferences(minCPM: 0.01))
        .then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
    fetchChannels(
            'https://raw.githubusercontent.com/BeamlakAschalew/cinemax_live_channels/master/${widget.catName}.json')
        .then((value) {
      setState(() {
        channels = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: channels == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: channels!.length,
                      itemBuilder: (context, index) {
                        return ChannelWidget(
                          channel: channels![index],
                          catName: widget.catName,
                        );
                      },
                    ),
                  ),
                  bannerAd != null ? StartAppBanner(bannerAd!) : Container()
                ],
              ),
      ),
    );
  }
}

class ChannelWidget extends StatefulWidget {
  const ChannelWidget({Key? key, required this.channel, required this.catName})
      : super(key: key);

  final Channel channel;
  final String catName;

  @override
  State<ChannelWidget> createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  Map<String, String> videos = {};
  Map<String, String> reversedVids = {};

  void sett() {
    for (int k = 0; k < widget.channel.channelStream!.length; k++) {
      videos.addAll({
        widget.channel.channelStream![k].videoQuality!:
            widget.channel.channelStream![k].streamLink!,
      });

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      reversedVids = Map.fromEntries(reversedVideoList);
    }
  }

  @override
  void initState() {
    sett();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: GestureDetector(
            onTap: () {
              final mixpanel =
                  Provider.of<SettingsProvider>(context, listen: false)
                      .mixpanel;
              final autoFS =
                  Provider.of<SettingsProvider>(context, listen: false)
                      .defaultViewMode;
              mixpanel.track('Most viewed TV channels', properties: {
                'TV Channel name': widget.channel.channelName,
                'Category': widget.catName,
              });

              Navigator.push(context, MaterialPageRoute(builder: ((context) {
                return LivePlayer(
                  sources: reversedVids,
                  autoFullScreen: autoFS,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.background
                  ],
                );
              })));
            },
            child: Container(
              height: 60,
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(
                    height: 40,
                    width: 70,
                    child: CachedNetworkImage(
                      cacheManager: cacheProp(),
                      fadeOutDuration: const Duration(milliseconds: 300),
                      fadeOutCurve: Curves.easeOut,
                      fadeInDuration: const Duration(milliseconds: 700),
                      fadeInCurve: Curves.easeIn,
                      imageUrl: widget.channel.channelLogo!,
                      placeholder: (context, url) =>
                          Image.asset('assets/images/loading_5.gif'),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/na_rect.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(widget.channel.channelName!)
                ],
              ),
            ),
          ),
        ),
        const Divider(
          thickness: 2,
        )
      ],
    );
  }
}

/*





Center(
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                maxBuffer =
                    Provider.of<SettingsProvider>(context, listen: false)
                        .defaultMaxBufferDuration;
                seekDuration =
                    Provider.of<SettingsProvider>(context, listen: false)
                        .defaultSeekDuration;
                videoQuality =
                    Provider.of<SettingsProvider>(context, listen: false)
                        .defaultVideoResolution;
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return LivePlayer(sources: {
                  'auto': 'http://45.12.1.14:80/7JvIck488/meAqNw5218/28903'
                }, colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.background
                ], videoProperties: [
                  maxBuffer,
                  seekDuration,
                  videoQuality
                ]);
              }));
            },
            child: Text('PLAY')),
      ),






 */


/*

GridView.count(
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                childAspectRatio: 2,
                shrinkWrap: true,
                crossAxisCount: 2, // Maximum of 3 items horizontally
                children: List.generate(categories.length, (index) {
                  return GridTile(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(30)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CategoryWidget(category: categories[index]),
                      ),
                    ),
                  );
                }),
              )

 */
