// ignore_for_file: avoid_unnecessary_containers

import 'package:cinemax/provider/adultmode_provider.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/models/credits.dart';
import 'person_widgets.dart';

class CastDetailPage extends StatefulWidget {
  final Cast? cast;
  final String heroId;

  const CastDetailPage({
    Key? key,
    this.cast,
    required this.heroId,
  }) : super(key: key);
  @override
  _CastDetailPageState createState() => _CastDetailPageState();
}

class _CastDetailPageState extends State<CastDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CastDetailPage> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                              ],
                              stops: [
                                0.0,
                                0.25,
                                0.5,
                                0.75
                              ])),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.bottomCenter,
                              end: FractionalOffset.topCenter,
                              colors: [
                                const Color(0xFFF57C00),
                                const Color(0xFFF57C00).withOpacity(0.3),
                                const Color(0xFFF57C00).withOpacity(0.2),
                                const Color(0xFFF57C00).withOpacity(0.1),
                              ],
                              stops: const [
                                0.0,
                                0.25,
                                0.5,
                                0.75
                              ])),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF57C00),
                ),
              )
            ],
          ),
          Column(
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFFF57C00),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 75, 16, 16),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            color:
                                isDark ? Color(0xFF2b2c30) : Color(0xFFDFDEDE),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 80,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${widget.cast!.name}',
                                        style: const TextStyle(fontSize: 25),
                                        // style: widget
                                        //     .themeData.textTheme.headline5,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${widget.cast!.department}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                TabBar(
                                  isScrollable: true,
                                  indicatorColor: const Color(0xFFF57C00),
                                  indicatorWeight: 3,
                                  unselectedLabelColor: Colors.white54,
                                  labelColor: Colors.white,
                                  tabs: [
                                    Tab(
                                      child: Text('About',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('Movies',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('TV Shows',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                  ],
                                  controller: tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(1.6, 0, 1.6, 3),
                                    child: TabBarView(
                                      physics: const PageScrollPhysics(),
                                      children: [
                                        // PersonAboutWidget(
                                        //   api: Endpoints.getPersonDetails(
                                        //     widget.cast.id!,
                                        //   ),
                                        // ),
                                        SingleChildScrollView(
                                          child: Container(
                                            color: isDark
                                                ? Color(0xFF202124)
                                                : Color(0xFFFFFFFF),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10,
                                                          top: 10.0),
                                                  child: Column(
                                                    children: [
                                                      PersonAboutWidget(
                                                          api: Endpoints
                                                              .getPersonDetails(
                                                                  widget.cast!
                                                                      .id!)),
                                                      PersonSocialLinks(
                                                        api: Endpoints
                                                            .getExternalLinksForPerson(
                                                                widget
                                                                    .cast!.id!),
                                                      ),
                                                      PersonImagesDisplay(
                                                        api: Endpoints
                                                            .getPersonImages(
                                                          widget.cast!.id!,
                                                        ),
                                                        title: 'Images',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: isDark
                                              ? Color(0xFF202124)
                                              : Color(0xFFFFFFFF),
                                          child: PersonMovieListWidget(
                                            isPersonAdult: widget.cast!.adult!,
                                            includeAdult:
                                                Provider.of<AdultmodeProvider>(
                                                        context)
                                                    .isAdult,
                                            api: Endpoints
                                                .getMovieCreditsForPerson(
                                                    widget.cast!.id!),
                                          ),
                                        ),
                                        Container(
                                          color: isDark
                                              ? Color(0xFF202124)
                                              : Color(0xFFFFFFFF),
                                          child: PersonTVListWidget(
                                              isPersonAdult:
                                                  widget.cast!.adult!,
                                              includeAdult: Provider.of<
                                                          AdultmodeProvider>(
                                                      context)
                                                  .isAdult,
                                              api: Endpoints
                                                  .getTVCreditsForPerson(
                                                      widget.cast!.id!)),
                                        ),
                                      ],
                                      controller: tabController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: widget.heroId,
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: widget.cast!.profilePath == null
                                      ? Image.asset(
                                          'assets/images/na_square.png',
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage(
                                          image: NetworkImage(
                                              TMDB_BASE_IMAGE_URL +
                                                  'w500/' +
                                                  '${widget.cast!.profilePath}'),
                                          fit: BoxFit.cover,
                                          placeholder: const AssetImage(
                                              'assets/images/loading.gif'),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
