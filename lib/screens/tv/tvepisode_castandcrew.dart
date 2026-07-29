import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../api/endpoints.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/app_ui_components.dart';
import '../../widgets/tv_widgets.dart';

class TVEpisodeCastAndCrew extends StatefulWidget {
  const TVEpisodeCastAndCrew(
      {super.key,
      required this.id,
      required this.seasonNumber,
      required this.episodeNumber});

  final int id;
  final int seasonNumber;
  final int episodeNumber;

  @override
  State<TVEpisodeCastAndCrew> createState() => _TVEpisodeCastAndCrewState();
}

class _TVEpisodeCastAndCrewState extends State<TVEpisodeCastAndCrew>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final api = Endpoints.getEpisodeCredits(
        widget.id, widget.seasonNumber, widget.episodeNumber, lang);
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('cast_and_crew')),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          AppResponsiveContent(
            child: AppSegmentedTabs(
              controller: tabController,
              tabs: [
                AppSegmentedTab(label: tr('cast')),
                AppSegmentedTab(label: tr('guest_stars')),
                AppSegmentedTab(label: tr('crew')),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                TVEpisodeCastTab(api: api),
                TVEpisodeGuestStarsTab(api: api),
                TVCrewTab(api: api),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
