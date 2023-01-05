import '../provider/settings_provider.dart';
import '/screens/movie/discover_movies_tab.dart';
import '/screens/tv/discover_tv_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
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
            'Discover',
            // style: TextStyle(color: isDark ? Colors.white : Colors.black),
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
                unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Poppins', color: Colors.black87),
                labelColor: Colors.black,
                controller: tabController,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            Expanded(
              child: Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFF7F7F7),
                child: TabBarView(
                  controller: tabController,
                  children: const [DiscoverMoviesTab(), DiscoverTVTab()],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
