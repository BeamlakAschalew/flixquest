import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/credits.dart';
import '../../ui_components/app_ui_components.dart';
import '/widgets/movie_widgets.dart';

class MovieCastAndCrew extends StatefulWidget {
  const MovieCastAndCrew({super.key, required this.credits});
  final Credits credits;

  @override
  State<MovieCastAndCrew> createState() => _MovieCastAndCrewState();
}

class _MovieCastAndCrewState extends State<MovieCastAndCrew>
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
                CastTab(credits: widget.credits),
                CrewTab(credits: widget.credits),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
