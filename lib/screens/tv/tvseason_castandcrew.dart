import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../api/endpoints.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/app_ui_components.dart';
import '../../widgets/tv_widgets.dart';

class TVSeasonCastAndCrew extends StatefulWidget {
  const TVSeasonCastAndCrew(
      {super.key,
      required this.id,
      required this.seasonNumber,
      required this.passedFrom});

  final int id;
  final int seasonNumber;
  final String passedFrom;

  @override
  State<TVSeasonCastAndCrew> createState() => _TVSeasonCastAndCrewState();
}

class _TVSeasonCastAndCrewState extends State<TVSeasonCastAndCrew>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
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
    final api = Endpoints.getFullTVSeasonCreditsUrl(
        widget.id, widget.seasonNumber, lang);
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
                AppSegmentedTab(
                    label: tr('cast'), icon: PhosphorIcons.usersThree()),
                AppSegmentedTab(
                    label: tr('crew'), icon: PhosphorIcons.wrench()),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                TVCastTab(api: api),
                TVCrewTab(api: api),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
