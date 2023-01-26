import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import 'movie/discover_movies_tab.dart';
import 'tv/discover_tv_tab.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: [
        Container(
          color: Colors.grey,
          width: double.infinity,
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
                    'Movies',
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
                    'TV Series',
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
            unselectedLabelStyle:
                const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
            labelColor: Colors.black,
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        Expanded(
          child: Container(
            child: TabBarView(
              controller: tabController,
              children: const [DiscoverMoviesTab(), DiscoverTVTab()],
            ),
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
