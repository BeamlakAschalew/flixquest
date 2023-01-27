import '/widgets/movie_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/credits.dart';
import '../../provider/settings_provider.dart';

class MovieCastAndCrew extends StatefulWidget {
  const MovieCastAndCrew({Key? key, required this.credits}) : super(key: key);
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
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 3,
            title: const Text(
              'Cast And Crew',
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
                  tabs: const [
                    Tab(
                        child: Text(
                      'Cast',
                    )),
                    Tab(
                        child: Text(
                      'Crew',
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
