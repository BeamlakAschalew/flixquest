import 'package:cinemax/widgets/movie_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/credits.dart';
import '../provider/settings_provider.dart';

class CastAndCrew extends StatefulWidget {
  const CastAndCrew({Key? key, required this.credits}) : super(key: key);
  final Credits credits;

  @override
  State<CastAndCrew> createState() => _CastAndCrewState();
}

class _CastAndCrewState extends State<CastAndCrew>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Cast And Crew',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                color: const Color(0xFFF57C00),
                child: TabBar(
                  tabs: [
                    Tab(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.movie_creation_rounded),
                        ),
                        Text(
                          'Cast',
                        ),
                      ],
                    )),
                    Tab(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.live_tv_rounded)),
                        Text(
                          'Crew',
                        ),
                      ],
                    ))
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
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    CastTab(credits: widget.credits),
                    CrewTab(
                      credits: widget.credits,
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
