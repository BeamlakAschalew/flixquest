// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '/models/tv.dart';
import '/widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import '/widgets/movie_widgets.dart';

class EpisodeDetailPage extends StatefulWidget {
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  const EpisodeDetailPage({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  }) : super(key: key);

  @override
  EpisodeDetailPageState createState() => EpisodeDetailPageState();
}

class EpisodeDetailPageState extends State<EpisodeDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<EpisodeDetailPage> {
  bool? isVisible = false;
  double? buttonWidth = 150;
  ExternalLinks? externalLinks;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed episode details', properties: {
      'TV series name': '${widget.seriesName}',
      'TV series episode name': '${widget.episodeList.name}',
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            forceElevated: true,
            backgroundColor: themeMode == 'dark' || themeMode == 'amoled'
                ? Colors.black
                : Colors.white,
            shadowColor: themeMode == 'dark' || themeMode == 'amoled'
                ? Colors.white
                : Colors.black,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.episodeList.name!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )),
            expandedHeight: 375,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  TVEpisodeQuickInfo(
                    episodeList: widget.episodeList,
                    seriesName: widget.seriesName,
                    tvId: widget.tvId,
                  ),
                  TVEpisodeOptions(episodeList: widget.episodeList)
                ],
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate.fixed([
            EpisodeAbout(
              episodeList: widget.episodeList,
              seriesName: widget.seriesName,
              tvId: widget.tvId,
              posterPath: widget.posterPath,
            )
          ]))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Share.share(tr('share_episode', namedArgs: {
              'title': widget.seriesName!,
              'rating': widget.episodeList.voteAverage!.toStringAsFixed(1),
              'id': widget.tvId!.toString(),
              'et': widget.episodeList.name ?? 'N/A',
              'season': widget.episodeList.seasonNumber.toString(),
              'episode': widget.episodeList.episodeNumber.toString()
            }));
          },
          child: const Icon(FontAwesomeIcons.shareNodes)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
