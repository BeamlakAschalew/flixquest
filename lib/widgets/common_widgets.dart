// ignore_for_file: avoid_unnecessary_containers
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/provider/app_dependency_provider.dart';
import 'package:cinemax/screens/common/live_tv_screen.dart';
import 'package:cinemax/screens/common/server_status_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../functions/network.dart';
import '../models/movie.dart';
import '../models/watch_providers.dart';
import '/screens/common/bookmark_screen.dart';
import '/screens/common/settings.dart';
import '/screens/common/update_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../provider/settings_provider.dart';
import '../screens/common/about.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
//import '../screens/common/news_screen.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cinemaxLogo = Provider.of<AppDependencyProvider>(context).cinemaxLogo;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Drawer(
      child: Container(
        color: isDark ? Colors.black : Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black),
                      child: cinemaxLogo == 'default'
                          ? Image.asset('assets/images/logo_shadow.png')
                          : CachedNetworkImage(
                              imageUrl: cinemaxLogo,
                            ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.bookmark,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("bookmarks")),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return const BookmarkScreen();
                      })));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.tv,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("live_tv")),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return const LiveTV();
                      })));
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(
                  //     FontAwesomeIcons.newspaper,
                  //     color: Theme.of(context).colorScheme.primary,
                  //   ),
                  //   title: const Text('News'),
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: ((context) {
                  //       return const NewsPage();
                  //     })));
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(
                      Icons.settings_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("settings")),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return const Settings();
                      })));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("about")),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const AboutPage();
                      }));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.server,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("check_server")),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ServerStatusScreen();
                      }));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.update_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("check_for_update")),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return const UpdateScreen();
                      })));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.share_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("shared_the_app")),
                    onTap: () async {
                      mixpanel.track('Share button data', properties: {
                        'Share button click': 'Share',
                      });
                      await Share.share(tr("share_text"));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget scrollingMoviesAndTVShimmer(isDark) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ShimmerBase(
            isDark: isDark,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 20.0),
                          child: Container(
                            width: 100.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              itemCount: 10,
            ),
          ),
        ),
      ],
    );

Widget discoverMoviesAndTVShimmer(isDark) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ShimmerBase(
            isDark: isDark,
            child: CarouselSlider.builder(
              options: CarouselOptions(
                disableCenter: true,
                viewportFraction: 0.6,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              itemBuilder: (context, index, pageViewIndex) => Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white),
              ),
              itemCount: 10,
            ),
          ),
        ),
        ShimmerBase(
          isDark: isDark,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0), color: Colors.white),
          ),
        )
      ],
    );

Widget scrollingImageShimmer(isDark) => ShimmerBase(
    isDark: isDark,
    child: Container(
      width: 120.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), color: Colors.white),
    ));

Widget discoverImageShimmer(isDark) => ShimmerBase(
      isDark: isDark,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0), color: Colors.white),
      ),
    );

Widget genreListGridShimmer(isDark) => ShimmerBase(
      isDark: isDark,
      child: ListView.builder(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 125,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white),
              ),
            );
          }),
    );

Widget horizontalLoadMoreShimmer(isDark) => Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ShimmerBase(
        isDark: isDark,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Container(
                        width: 100.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                      child: Container(
                        width: 100.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          itemCount: 1,
        ),
      ),
    );

Widget detailGenreShimmer(isDark) => ShimmerBase(
      isDark: isDark,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Chip(
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                  width: 2, style: BorderStyle.solid, color: Colors.white),
              borderRadius: BorderRadius.circular(20.0),
            ),
            label: Text(
              tr("placeholder"),
            ),
            backgroundColor:
                isDark ? const Color(0xFF2b2c30) : const Color(0xFFDFDEDE),
          ),
        ),
      ),
    );

Widget detailCastShimmer(isDark) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ShimmerBase(
            isDark: isDark,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 100,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: 75.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 30),
                          child: Container(
                            width: 75.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              itemCount: 5,
            ),
          ),
        ),
      ],
    );

Widget detailImageShimmer(isDark) => ShimmerBase(
      isDark: isDark,
      child: CarouselSlider(
        options: CarouselOptions(
          enableInfiniteScroll: false,
          viewportFraction: 1,
        ),
        items: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                        alignment: AlignmentDirectional.bottomStart,
                        children: [
                          SizedBox(
                            height: 180,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.black38,
                              height: 40,
                            ),
                          )
                        ]),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                          alignment: AlignmentDirectional.bottomStart,
                          children: [
                            SizedBox(
                              height: 180,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: Colors.black38,
                                height: 40,
                              ),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

Widget detailCastImageShimmer(isDark) => ShimmerBase(
    isDark: isDark,
    child: Container(
      width: 75.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0), color: Colors.white),
    ));

Widget detailImageImageSimmer(isDark) => ShimmerBase(
    isDark: isDark,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), color: Colors.white),
    ));

Widget detailVideoShimmer(isDark) => SizedBox(
      width: double.infinity,
      child: ShimmerBase(
        isDark: isDark,
        child: CarouselSlider.builder(
          options: CarouselOptions(
            disableCenter: true,
            viewportFraction: 0.8,
            enlargeCenterPage: false,
            autoPlay: true,
          ),
          itemBuilder: (context, index, pageViewIndex) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 205,
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.white),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white),
                        )),
                  )
                ],
              ),
            ),
          ),
          itemCount: 5,
        ),
      ),
    );

Widget socialMediaShimmer(isDark) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? Colors.transparent : const Color(0xFFDFDEDE),
      ),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            return ShimmerBase(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 40,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
    );

Widget detailInfoTableItemShimmer(isDark) => ShimmerBase(
      isDark: isDark,
      child: Container(
        color: Colors.white,
        height: 15,
        width: 75,
      ),
    );

Widget detailInfoTableShimmer(isDark) =>
    DataTable(dataRowMinHeight: 40, columns: [
      // const DataColumn(
      //     label: Text(
      //   'Original Title',
      //   style: TextStyle(overflow: TextOverflow.ellipsis),
      // )),
      DataColumn(label: detailInfoTableItemShimmer(isDark)),
      DataColumn(label: detailInfoTableItemShimmer(isDark)),
    ], rows: [
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(detailInfoTableItemShimmer(isDark)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(detailInfoTableItemShimmer(isDark)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(SizedBox(
            height: 20, width: 200, child: detailInfoTableItemShimmer(isDark))),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(detailInfoTableItemShimmer(isDark)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(detailInfoTableItemShimmer(isDark)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(detailInfoTableItemShimmer(isDark)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(SizedBox(
                height: 20,
                width: 200,
                child: detailInfoTableItemShimmer(isDark))
            // movieDetails!.productionCompanies!.isEmpty
            //     ? const Text('-')
            //     : Text(
            //         movieDetails!.productionCompanies![0].name!),
            ),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(SizedBox(
                height: 20,
                width: 200,
                child: detailInfoTableItemShimmer(isDark))
            // movieDetails!.productionCompanies!.isEmpty
            //     ? const Text('-')
            //     : Text(
            //         movieDetails!.productionCountries![0].name!),
            ),
      ]),
    ]);

Widget personDetailInfoTableShimmer(isDark) =>
    DataTable(dataRowMinHeight: 40, columns: [
      DataColumn(label: detailInfoTableItemShimmer(isDark)),
      DataColumn(label: detailInfoTableItemShimmer(isDark)),
    ], rows: [
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(detailInfoTableItemShimmer(isDark)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(isDark)),
        DataCell(detailInfoTableItemShimmer(isDark)),
      ]),
    ]);

Widget movieCastAndCrewTabShimmer(isDark) => Container(
    child: ListView.builder(
        itemCount: 20,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: ShimmerBase(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 0.0,
                  bottom: 5.0,
                  left: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0, left: 10),
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  width: 150,
                                  height: 25,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: !isDark ? Colors.black54 : Colors.white54,
                      thickness: 1,
                      endIndent: 20,
                      indent: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        }));

Widget detailsRecommendationsAndSimilarShimmer(
        isDark, scrollController, isLoading) =>
    Column(
      children: [
        ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return ShimmerBase(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 0.0,
                    bottom: 3.0,
                    left: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        // crossAxisAlignment:
                        //     CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: SizedBox(
                              width: 85,
                              height: 130,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                      height: 20,
                                      width: 150,
                                      color: Colors.white),
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 1.0),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                        height: 20,
                                        width: 30,
                                        color: Colors.white),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Divider(
                        color: !isDark ? Colors.black54 : Colors.white54,
                        thickness: 1,
                        endIndent: 20,
                        indent: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
        Visibility(
            visible: isLoading,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: LinearProgressIndicator()),
            )),
      ],
    );

Widget watchProvidersTabData(
        {required bool isDark,
        required String imageQuality,
        required String noOptionMessage,
        required List? watchOptions}) =>
    Container(
      padding: const EdgeInsets.all(8.0),
      child: watchOptions == null
          ? Center(
              child: Text(
              noOptionMessage,
              textAlign: TextAlign.center,
            ))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100,
                childAspectRatio: 0.65,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: watchOptions.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: watchOptions[index].logoPath == null
                              ? Image.asset(
                                  'assets/images/na_logo.png',
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  cacheManager: cacheProp(),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration:
                                      const Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                      imageQuality +
                                      watchOptions[index].logoPath!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      watchProvidersImageShimmer(isDark),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                          flex: 3,
                          child: Text(
                            watchOptions[index].providerName!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                );
              }),
    );

Widget watchProvidersShimmer(isDark) => Container(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100,
            childAspectRatio: 0.65,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) {
            return ShimmerBase(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                              height: 10, width: 80, color: Colors.white),
                        )),
                  ],
                ),
              ),
            );
          }),
    );

Widget castAndCrewTabImageShimmer(isDark) => ShimmerBase(
    isDark: isDark,
    child: Container(
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0), color: Colors.white),
    ));

Widget recommendationAndSimilarTabImageShimmer(isDark) => ShimmerBase(
    isDark: isDark,
    child: Container(
      width: 85.0,
      height: 130.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
    ));

Widget watchProvidersImageShimmer(isDark) => ShimmerBase(
      isDark: isDark,
      child: Container(
        color: Colors.white,
      ),
    );

Widget mainPageVerticalScrollShimmer({isDark, isLoading, scrollController}) =>
    Container(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: ShimmerBase(
                              isDark: isDark,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
                                  bottom: 3.0,
                                  left: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: SizedBox(
                                            width: 85,
                                            height: 130,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Container(
                                                  width: 150,
                                                  height: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 1.0),
                                                    child: Container(
                                                      height: 20,
                                                      width: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    height: 20,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      color: !isDark
                                          ? Colors.black54
                                          : Colors.white54,
                                      thickness: 1,
                                      endIndent: 20,
                                      indent: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: LinearProgressIndicator()),
              )),
        ],
      ),
    );

Widget mainPageVerticalScrollImageShimmer(isDark) => ShimmerBase(
    isDark: isDark,
    child: Container(
      width: 85.0,
      height: 130.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
    ));

Widget horizontalScrollingSeasonsList(isDark) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ShimmerBase(
            isDark: isDark,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: 105.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 30.0),
                          child: Container(
                            width: 105.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              itemCount: 10,
            ),
          ),
        ),
      ],
    );

Widget detailVideoImageShimmer(isDark) => ShimmerBase(
    isDark: isDark,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), color: Colors.white),
    ));

Widget tvDetailsSeasonsTabShimmer(isDark) => Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: ShimmerBase(
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 0.0,
                        bottom: 5.0,
                        left: 15,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 30.0),
                                child: SizedBox(
                                  width: 85,
                                  height: 130,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Container(color: Colors.white)),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        color: Colors.white,
                                        height: 20,
                                        width: 115)
                                  ],
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: !isDark ? Colors.black54 : Colors.white54,
                            thickness: 1,
                            endIndent: 20,
                            indent: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );

Widget tvCastAndCrewTabShimmer(isDark) => Container(
    child: ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: ShimmerBase(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 5.0,
                  left: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0, left: 10),
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Container(
                                  width: 150,
                                  height: 25,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Container(
                                  width: 130,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: !isDark ? Colors.black54 : Colors.white54,
                      thickness: 1,
                      endIndent: 20,
                      indent: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        }));

Widget personMoviesAndTVShowShimmer(isDark) => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ShimmerBase(
              isDark: isDark,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 20,
                    width: 100,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 8.0, top: 0),
          child: Row(
            children: [
              Expanded(
                child: ShimmerBase(
                  isDark: isDark,
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        childAspectRatio: 0.48,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.white),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ],
    );

Widget moviesAndTVShowGridShimmer(isDark) => Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: ShimmerBase(
              isDark: isDark,
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 0.48,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.white),
                                ),
                              )),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );

Widget personImageShimmer(isDark) => Row(
      children: [
        Expanded(
          child: ShimmerBase(
            isDark: isDark,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 8.0),
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

Widget personAboutSimmer(isDark) => Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
          child: Text(
            tr("biography"),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        ShimmerBase(
          isDark: isDark,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );

Widget newsShimmer(isDark, scrollController, isLoading) {
  return Container(
    child: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: ShimmerBase(
                            isDark: isDark,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 0.0,
                                bottom: 3.0,
                                // left: 10,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: SizedBox(
                                            width: 100,
                                            height: 150,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Container(
                                                  width: 260,
                                                  height: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Container(
                                                width: 250,
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(
                                                height: 30,
                                              ),
                                              Container(
                                                width: 80,
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: !isDark
                                        ? Colors.black54
                                        : Colors.white54,
                                    thickness: 1,
                                    endIndent: 20,
                                    indent: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
        Visibility(
            visible: isLoading,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: LinearProgressIndicator()),
            )),
      ],
    ),
  );
}

class DidYouKnow extends StatefulWidget {
  const DidYouKnow({Key? key, required this.api}) : super(key: key);

  final String? api;

  @override
  State<DidYouKnow> createState() => _DidYouKnowState();
}

class _DidYouKnowState extends State<DidYouKnow> {
  ExternalLinks? externalLinks;

  @override
  void initState() {
    fetchSocialLinks(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          externalLinks = value;
        });
      }
    });
    super.initState();
  }

  void navToDYK(String dataType, String dataName, String imdbId) {
    // Navigator.push(context, MaterialPageRoute(builder: ((context) {
    //   return DidYouKnowScreen(
    //     dataType: dataType,
    //     dataName: dataName,
    //     imdbId: imdbId,
    //   );
    // })));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("did_you_know"),
            style: kTextHeaderStyle,
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
              child: externalLinks == null
                  ? const Center(child: CircularProgressIndicator())
                  : externalLinks!.imdbId == null ||
                          externalLinks!.imdbId!.isEmpty
                      ? Center(
                          child: Text(
                          tr("no_imdb_id"),
                          textAlign: TextAlign.center,
                        ))
                      : Wrap(
                          spacing: 5,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                navToDYK('trivia', tr("trivia"),
                                    externalLinks!.imdbId!);
                              },
                              child: Text(tr("trivia")),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK('quotes', tr("quotes"),
                                    externalLinks!.imdbId!);
                              },
                              child: Text(tr("quotes")),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK('goofs', tr("goofs"),
                                    externalLinks!.imdbId!);
                              },
                              child: Text(tr("goofs")),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK('crazycredits', tr("crazy_credits"),
                                    externalLinks!.imdbId!);
                              },
                              child: Text(tr("crazy_credits")),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK(
                                    'alternateversions',
                                    tr("alternate_versions"),
                                    externalLinks!.imdbId!);
                              },
                              child: Text(tr("alternate_versions")),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navToDYK('soundtrack', tr("soundtrack"),
                                    externalLinks!.imdbId!);
                              },
                              child: Text(tr("soundtrack")),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: ((context) {
                                //   return TitleReviews(
                                //       imdbId: externalLinks!.imdbId!);
                                // })));
                              },
                              child: Text(tr("reviews")),
                            ),
                          ],
                        )),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

class WatchProvidersDetails extends StatefulWidget {
  final String api;
  final String country;
  const WatchProvidersDetails(
      {Key? key, required this.api, required this.country})
      : super(key: key);

  @override
  State<WatchProvidersDetails> createState() => _WatchProvidersDetailsState();
}

class _WatchProvidersDetailsState extends State<WatchProvidersDetails>
    with SingleTickerProviderStateMixin {
  WatchProviders? watchProviders;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchWatchProviders(widget.api, widget.country).then((value) {
      if (mounted) {
        setState(() {
          watchProviders = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(),
            child: Center(
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorWeight: 3,
                unselectedLabelColor: Colors.white54,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Text(tr("buy"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("stream"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("rent"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              child: TabBarView(
                controller: tabController,
                children: watchProviders == null
                    ? [
                        watchProvidersShimmer(isDark),
                        watchProvidersShimmer(isDark),
                        watchProvidersShimmer(isDark),
                        watchProvidersShimmer(isDark),
                      ]
                    : [
                        watchProvidersTabData(
                            isDark: isDark,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_buy"),
                            watchOptions: watchProviders!.buy),
                        watchProvidersTabData(
                            isDark: isDark,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_stream"),
                            watchOptions: watchProviders!.flatRate),
                        watchProvidersTabData(
                            isDark: isDark,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_rent"),
                            watchOptions: watchProviders!.rent),
                      ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ShimmerBase extends StatelessWidget {
  const ShimmerBase({Key? key, required this.child, required this.isDark})
      : super(key: key);

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
      highlightColor:
          isDark ? Colors.grey.shade800.withOpacity(0.1) : Colors.grey.shade200,
      child: child,
    );
  }
}

class ReportErrorWidget extends StatelessWidget {
  const ReportErrorWidget({
    Key? key,
    required this.error,
  }) : super(key: key);

  final String error;
  //final List metadata;

  @override
  Widget build(BuildContext context) {
    // String meta = "";
    // for (int i = 0; i < metadata.length; i++) {
    //   meta += metadata[i].toString();
    // }
    // String url =
    //     "https://t.me/share/url?url=FlixQuest error&text=${error}\n${meta}";
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              error,
              maxLines: 6,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse("https://t.me/flixquestgroup"),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.telegram),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        tr("report_telegram"),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
