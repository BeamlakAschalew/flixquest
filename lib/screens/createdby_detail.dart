// ignore_for_file: avoid_unnecessary_containers

import 'package:cinemax/modals/person.dart';
import 'package:cinemax/modals/tv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/constants/api_constants.dart';
import 'package:cinemax/modals/credits.dart';

import 'person_widgets.dart';

class CreatedByPersonDetailPage extends StatefulWidget {
  final CreatedBy? createdBy;
  final String heroId;

  const CreatedByPersonDetailPage({
    Key? key,
    this.createdBy,
    required this.heroId,
  }) : super(key: key);
  @override
  _CreatedByPersonDetailPageState createState() =>
      _CreatedByPersonDetailPageState();
}

class _CreatedByPersonDetailPageState extends State<CreatedByPersonDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CreatedByPersonDetailPage> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                            color: const Color(0xFF202124),
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
                                        '${widget.createdBy!.name}',
                                        style: const TextStyle(fontSize: 25),
                                        // style: widget
                                        //     .themeData.textTheme.headline5,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                                  tabs: const [
                                    Tab(
                                      child: Text('About',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                    Tab(
                                      child: Text('Movies',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                    Tab(
                                      child: Text('TV Shows',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                  ],
                                  controller: tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics: const PageScrollPhysics(),
                                    children: [
                                      // PersonAboutWidget(
                                      //   api: Endpoints.getPersonDetails(
                                      //     widget.cast.id!,
                                      //   ),
                                      // ),
                                      SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0,
                                                  right: 10,
                                                  top: 10.0),
                                              child: Column(
                                                children: [
                                                  PersonAboutWidget(
                                                      api: Endpoints
                                                          .getPersonDetails(
                                                              widget.createdBy!
                                                                  .id!)),
                                                  PersonSocialLinks(
                                                    api: Endpoints
                                                        .getExternalLinksForPerson(
                                                            widget.createdBy!
                                                                .id!),
                                                  ),
                                                  PersonImagesDisplay(
                                                    api: Endpoints
                                                        .getPersonImages(
                                                      widget.createdBy!.id!,
                                                    ),
                                                    title: 'Images',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: PersonMovieListWidget(
                                          api: Endpoints
                                              .getMovieCreditsForPerson(
                                                  widget.createdBy!.id!),
                                        ),
                                      ),
                                      Container(
                                        child: PersonTVListWidget(
                                            api:
                                                Endpoints.getTVCreditsForPerson(
                                                    widget.createdBy!.id!)),
                                      ),
                                    ],
                                    controller: tabController,
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
                                  child: widget.createdBy!.profilePath == null
                                      ? Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage(
                                          image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                              'w500/' +
                                              '${widget.createdBy!.profilePath}'),
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
