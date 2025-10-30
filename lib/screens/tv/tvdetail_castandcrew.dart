import 'package:easy_localization/easy_localization.dart';

import '../../api/endpoints.dart';
import '../../widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/credits.dart';
import '../../provider/settings_provider.dart';

class TVDetailCastAndCrew extends StatefulWidget {
  const TVDetailCastAndCrew(
      {super.key, required this.id, required this.passedFrom});

  final int id;
  final String passedFrom;

  @override
  State<TVDetailCastAndCrew> createState() => _TVDetailCastAndCrewState();
}

class _TVDetailCastAndCrewState extends State<TVDetailCastAndCrew>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  Credits? credits;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 3,
            title: Text(
              tr('cast_and_crew'),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.grey,
                child: TabBar(
                  tabs: [
                    Tab(
                        child: Text(
                      tr('cast'),
                    )),
                    Tab(
                        child: Text(
                      tr('crew'),
                    ))
                  ],
                  indicatorColor: themeMode == 'dark' || themeMode == 'amoled'
                      ? Colors.white
                      : Colors.black,
                  indicatorWeight: 3,
                  //isScrollable: true,
                  labelStyle: const TextStyle(
                    fontFamily: 'FigtreeSB',
                    color: Colors.black,
                    fontSize: 17,
                  ),
                  unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Figtree', color: Colors.black87),
                  labelColor: Colors.black,
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    TVCastTab(
                      api: Endpoints.getFullTVCreditsUrl(widget.id, lang),
                    ),
                    TVCrewTab(
                      api: Endpoints.getFullTVCreditsUrl(widget.id, lang),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
