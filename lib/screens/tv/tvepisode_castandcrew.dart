import '../../api/endpoints.dart';
import '../../widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/credits.dart';
import '../../provider/settings_provider.dart';

class TVEpisodeCastAndCrew extends StatefulWidget {
  const TVEpisodeCastAndCrew(
      {Key? key,
      required this.id,
      required this.seasonNumber,
      required this.episodeNumber})
      : super(key: key);

  final int id;
  final int seasonNumber;
  final int episodeNumber;

  @override
  State<TVEpisodeCastAndCrew> createState() => _TVEpisodeCastAndCrewState();
}

class _TVEpisodeCastAndCrewState extends State<TVEpisodeCastAndCrew>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  Credits? credits;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.id);
    // print(widget.seasonNumber);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF57C00),
            elevation: 3,
            title: const Text(
              'Cast And Crew',
              style: TextStyle(color: Colors.black),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                color: const Color(0xFFF57C00),
                child: SizedBox(
                  width: double.infinity,
                  child: TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(
                          child: Text(
                        'Cast',
                      )),
                      Tab(
                          child: Text(
                        'Guest Stars',
                      )),
                      Tab(
                          child: Text(
                        'Crew',
                      )),
                    ],
                    indicatorColor: isDark ? Colors.white : Colors.black,
                    indicatorWeight: 3,
                    //isScrollable: true,
                    labelStyle: const TextStyle(
                      fontFamily: 'PoppinsSB',
                      color: Colors.black,
                      fontSize: 17,
                    ),
                    unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins', color: Colors.black87),
                    labelColor: Colors.black,
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    TVEpisodeCastTab(
                      api: Endpoints.getEpisodeCredits(
                          widget.id, widget.seasonNumber, widget.episodeNumber),
                    ),
                    TVEpisodeGuestStarsTab(
                        api: Endpoints.getEpisodeCredits(widget.id,
                            widget.seasonNumber, widget.episodeNumber)),
                    TVCrewTab(
                      api: Endpoints.getEpisodeCredits(
                          widget.id, widget.seasonNumber, widget.episodeNumber),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
