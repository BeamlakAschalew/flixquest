import 'package:flixquest/api/endpoints.dart';
import 'package:flixquest/services/globle_method.dart';

import '../../provider/app_dependency_provider.dart';
import '/models/live_tv.dart';
import '/screens/common/live_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../functions/network.dart';
import '../../provider/settings_provider.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  Channels? channels; 
  Channels? original;
  bool enableRetry = false;

  @override
  void initState() {
   loadChannels();
    super.initState();
  }

  void loadChannels() async {
 try {
  setState(() {
    enableRetry = false;
  });
  Channels value = await fetchChannels(Endpoints.getIPTVEndpoint(Provider.of<AppDependencyProvider>(context, listen: false).flixquestAPIURL));
  List<Channel> channelsCopy = List.from(value.channels!);
  Channels originalCopy = Channels(channels: channelsCopy);
    setState(() {
      channels = value;
      original = originalCopy;
    });
  
} on Exception catch (e) {
  setState(() {
    enableRetry = true;
  });
  if (mounted) {
  GlobalMethods.showErrorScaffoldMessengerMediaLoad(e, context, '');
  }
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("channels"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: enableRetry ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off_rounded, size: 35,), const SizedBox(width: 25,), Text(tr("channels_fetch_failed"), style: const TextStyle(fontSize: 20),),
          ],
        ),
        const SizedBox(height: 15,), ElevatedButton(onPressed: () {loadChannels();}, child: Text(tr("retry")))], ) : channels == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                  children: [
                    Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
       
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                onChanged: (v) {
                  setState(() {
                    channels!.channels = original!.channels;
                  });
                  if (v.isNotEmpty) {
                    setState(() {
                      channels!.channels = channels!.channels!.where((element) => (element.channelName!.toLowerCase().contains(v.toLowerCase()))).toList();
                    });
                  }
                },
                decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,),
              ),
            ),
            const Icon(Icons.search),
          ],
        ),
      ),
    ),
    channels!.channels!.isEmpty
                ? Expanded(
                  child: Center(
                    child: Text(
                      tr("no_channels"),
                      style: kTextHeaderStyle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                :     Expanded(
                      child: ListView.builder(
                        itemCount: channels!.channels!.length,
                    shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ChannelWidget(
                            channel: channels!,
                            index: index,
                          );
                        },
                      ),
                    ),
                  ],
                )
      ),
    );
  }
}

class ChannelWidget extends StatefulWidget {
  const ChannelWidget({Key? key, required this.channel, required this.index})
      : super(key: key);

  final Channels channel;
  final int index;

  @override
  State<ChannelWidget> createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {

  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final mixpanel =
                Provider.of<SettingsProvider>(context, listen: false)
                    .mixpanel;
            final autoFS =
                Provider.of<SettingsProvider>(context, listen: false)
                    .defaultViewMode;
            mixpanel.track('Most viewed TV channels', properties: {
              'TV Channel name': widget.channel.channels![widget.index].channelName ?? "N/A",
            });
            Navigator.push(context, MaterialPageRoute(builder: ((context) {
              return LivePlayer(
                channelName: widget.channel.channels![widget.index].channelName!,
                videoUrl: Channels.baseUrl! + widget.channel.channels![widget.index].channelId!.toString() + Channels.trailingUrl!,
                referrer: Channels.referrer!,
                autoFullScreen: autoFS,
                userAgent: Channels.userAgent!,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.background
                ],
              );
            })));
          },
          child: Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.all(8.0),
            color: Colors.transparent,
            alignment: Alignment.centerLeft,
            child: Text(widget.channel.channels![widget.index].channelName!),
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
