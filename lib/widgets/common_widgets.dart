// ignore_for_file: avoid_unnecessary_containers
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flixquest/services/globle_method.dart';
import '/provider/app_dependency_provider.dart';
import '/screens/common/live_tv_screen.dart';
import '/screens/common/server_status_screen.dart';
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
    final flixquestLogo =
        Provider.of<AppDependencyProvider>(context).flixQuestLogo;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    AppDependencyProvider appDependencyProvider = AppDependencyProvider();
    return Drawer(
      child: Container(
        color: themeMode == "dark" || themeMode == "amoled"
            ? Colors.black
            : Colors.white,
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
                          color: themeMode == "dark" || themeMode == "amoled"
                              ? Colors.white
                              : Colors.black),
                      child: flixquestLogo == 'default'
                          ? Image.asset('assets/images/logo.png')
                          : CachedNetworkImage(
                              imageUrl: flixquestLogo,
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
                  appDependencyProvider.displayOTTDrawer
                      ? ListTile(
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
                        )
                      : Container(),
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
                        return const UpdateScreen(
                          isForced: false,
                        );
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

Widget scrollingMoviesAndTVShimmer(String themeMode) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ShimmerBase(
            themeMode: themeMode,
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
                              color: Colors.grey.shade600),
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
                                color: Colors.grey.shade600),
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

Widget discoverMoviesAndTVShimmer(String themeMode) => ShimmerBase(
      themeMode: themeMode,
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
              color: Colors.grey.shade600),
        ),
        itemCount: 10,
      ),
    );

Widget scrollingImageShimmer(String themeMode) => ShimmerBase(
    themeMode: themeMode,
    child: Container(
      width: 120.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.shade600),
    ));

Widget discoverImageShimmer(String themeMode) => ShimmerBase(
      themeMode: themeMode,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey.shade600),
      ),
    );

Widget genreListGridShimmer(String themeMode) => ShimmerBase(
      themeMode: themeMode,
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
                    color: Colors.grey.shade600),
              ),
            );
          }),
    );

Widget horizontalLoadMoreShimmer(String themeMode) => Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ShimmerBase(
        themeMode: themeMode,
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
                            color: Colors.grey.shade600),
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

Widget detailGenreShimmer(String themeMode) => ShimmerBase(
      themeMode: themeMode,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Chip(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  width: 2,
                  style: BorderStyle.solid,
                  color: Colors.grey.shade600),
              borderRadius: BorderRadius.circular(20.0),
            ),
            label: Text(
              tr("placeholder"),
            ),
            backgroundColor: themeMode == "dark" || themeMode == "amoled"
                ? const Color(0xFF2b2c30)
                : const Color(0xFFDFDEDE),
          ),
        ),
      ),
    );

Widget detailCastShimmer(String themeMode) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ShimmerBase(
            themeMode: themeMode,
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
                              color: Colors.grey.shade600),
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
                                color: Colors.grey.shade600),
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

Widget detailImageShimmer(String themeMode) => ShimmerBase(
      themeMode: themeMode,
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
                                  color: Colors.grey.shade600),
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

Widget detailCastImageShimmer(String themeMode) => ShimmerBase(
    themeMode: themeMode,
    child: Container(
      width: 75.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.grey.shade600),
    ));

Widget detailImageImageSimmer(String themeMode) => ShimmerBase(
    themeMode: themeMode,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.shade600),
    ));

Widget detailVideoShimmer(String themeMode) => SizedBox(
      width: double.infinity,
      child: ShimmerBase(
        themeMode: themeMode,
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
                          color: Colors.grey.shade600),
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
                              color: Colors.grey.shade600),
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

Widget socialMediaShimmer(String themeMode) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: themeMode == "dark" || themeMode == "amoled"
            ? Colors.transparent
            : const Color(0xFFDFDEDE),
      ),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            return ShimmerBase(
              themeMode: themeMode,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 40,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }),
    );

Widget detailInfoTableItemShimmer(String themeMode) => ShimmerBase(
      themeMode: themeMode,
      child: Container(
        color: Colors.grey.shade600,
        height: 15,
        width: 75,
      ),
    );

Widget detailInfoTableShimmer(String themeMode) =>
    DataTable(dataRowMinHeight: 40, columns: [
      // const DataColumn(
      //     label: Text(
      //   'Original Title',
      //   style: TextStyle(overflow: TextOverflow.ellipsis),
      // )),
      DataColumn(label: detailInfoTableItemShimmer(themeMode)),
      DataColumn(label: detailInfoTableItemShimmer(themeMode)),
    ], rows: [
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(detailInfoTableItemShimmer(themeMode)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(detailInfoTableItemShimmer(themeMode)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(SizedBox(
            height: 20,
            width: 200,
            child: detailInfoTableItemShimmer(themeMode))),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(detailInfoTableItemShimmer(themeMode)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(detailInfoTableItemShimmer(themeMode)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(detailInfoTableItemShimmer(themeMode)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(SizedBox(
                height: 20,
                width: 200,
                child: detailInfoTableItemShimmer(themeMode))
            // movieDetails!.productionCompanies!.isEmpty
            //     ? const Text('-')
            //     : Text(
            //         movieDetails!.productionCompanies![0].name!),
            ),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(SizedBox(
                height: 20,
                width: 200,
                child: detailInfoTableItemShimmer(themeMode))
            // movieDetails!.productionCompanies!.isEmpty
            //     ? const Text('-')
            //     : Text(
            //         movieDetails!.productionCountries![0].name!),
            ),
      ]),
    ]);

Widget personDetailInfoTableShimmer(String themeMode) =>
    DataTable(dataRowMinHeight: 40, columns: [
      DataColumn(label: detailInfoTableItemShimmer(themeMode)),
      DataColumn(label: detailInfoTableItemShimmer(themeMode)),
    ], rows: [
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(detailInfoTableItemShimmer(themeMode)),
      ]),
      DataRow(cells: [
        DataCell(detailInfoTableItemShimmer(themeMode)),
        DataCell(detailInfoTableItemShimmer(themeMode)),
      ]),
    ]);

Widget movieCastAndCrewTabShimmer(String themeMode) => Container(
    child: ListView.builder(
        itemCount: 20,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: ShimmerBase(
              themeMode: themeMode,
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
                                color: Colors.grey.shade600,
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
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: themeMode == "light"
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
        }));

Widget detailsRecommendationsAndSimilarShimmer(
        String themeMode, scrollController, isLoading) =>
    Column(
      children: [
        ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return ShimmerBase(
                themeMode: themeMode,
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
                                    color: Colors.grey.shade600),
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
                                      color: Colors.grey.shade600),
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 1.0),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Container(
                                        height: 20,
                                        width: 30,
                                        color: Colors.grey.shade600),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Divider(
                        color: themeMode == "light"
                            ? Colors.black54
                            : Colors.white54,
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
        {required String themeMode,
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
                                      watchProvidersImageShimmer(themeMode),
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

Widget watchProvidersShimmer(String themeMode) => Container(
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
              themeMode: themeMode,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey.shade600),
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
                              height: 10,
                              width: 80,
                              color: Colors.grey.shade600),
                        )),
                  ],
                ),
              ),
            );
          }),
    );

Widget castAndCrewTabImageShimmer(String themeMode) => ShimmerBase(
    themeMode: themeMode,
    child: Container(
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.grey.shade600),
    ));

Widget recommendationAndSimilarTabImageShimmer(String themeMode) => ShimmerBase(
    themeMode: themeMode,
    child: Container(
      width: 85.0,
      height: 130.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey.shade600),
    ));

Widget watchProvidersImageShimmer(String themeMode) => ShimmerBase(
      themeMode: themeMode,
      child: Container(
        color: Colors.grey.shade600,
      ),
    );

Widget mainPageVerticalScrollShimmer(
        {required String themeMode, isLoading, scrollController}) =>
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
                              themeMode: themeMode,
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
                                                color: Colors.grey.shade600,
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
                                                  color: Colors.grey.shade600,
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
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    height: 20,
                                                    color: Colors.grey.shade600,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      color: themeMode == "light"
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

Widget mainPageVerticalScrollImageShimmer(String themeMode) => ShimmerBase(
    themeMode: themeMode,
    child: Container(
      width: 85.0,
      height: 130.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey.shade600),
    ));

Widget horizontalScrollingSeasonsList(themeMode) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ShimmerBase(
            themeMode: themeMode,
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
                              color: Colors.grey.shade600),
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
                                color: Colors.grey.shade600),
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

Widget detailVideoImageShimmer(String themeMode) => ShimmerBase(
    themeMode: themeMode,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.shade600),
    ));

Widget tvDetailsSeasonsTabShimmer(String themeMode) => Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: ShimmerBase(
                    themeMode: themeMode,
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
                                      child: Container(
                                          color: Colors.grey.shade600)),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        color: Colors.grey.shade600,
                                        height: 20,
                                        width: 115)
                                  ],
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: themeMode == "light"
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
    );

Widget tvCastAndCrewTabShimmer(String themeMode) => Container(
    child: ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: ShimmerBase(
              themeMode: themeMode,
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
                                color: Colors.grey.shade600,
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
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Container(
                                  width: 130,
                                  height: 20,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 20,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: themeMode == "light"
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
        }));

Widget personMoviesAndTVShowShimmer(String themeMode) => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ShimmerBase(
              themeMode: themeMode,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 20,
                    width: 100,
                    color: Colors.grey.shade600,
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
                  themeMode: themeMode,
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
                                      color: Colors.grey.shade600),
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
                                          color: Colors.grey.shade600),
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

Widget moviesAndTVShowGridShimmer(String themeMode) => Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: ShimmerBase(
              themeMode: themeMode,
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
                                  color: Colors.grey.shade600),
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
                                      color: Colors.grey.shade600),
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

Widget personImageShimmer(String themeMode) => Row(
      children: [
        Expanded(
          child: ShimmerBase(
            themeMode: themeMode,
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
                                color: Colors.grey.shade600),
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

Widget personAboutSimmer(themeMode) => Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
          child: Row(
            children: [
              const LeadingDot(),
              Expanded(
                child: Text(
                  tr("biography"),
                  style: kTextHeaderStyle,
                ),
              ),
            ],
          ),
        ),
        ShimmerBase(
          themeMode: themeMode,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.grey.shade600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.grey.shade600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.grey.shade600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

Widget newsShimmer(String themeMode, scrollController, isLoading) {
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
                            themeMode: themeMode,
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
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade600,
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
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              Container(
                                                width: 250,
                                                height: 20,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(
                                                height: 30,
                                              ),
                                              Container(
                                                width: 80,
                                                height: 20,
                                                color: Colors.grey.shade600,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: themeMode == "light"
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
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
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
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? Colors.white
                                : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("stream"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? Colors.white
                                : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("rent"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? Colors.white
                                : Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: themeMode == "dark" || themeMode == "amoled"
                  ? Colors.black
                  : Colors.white,
              child: TabBarView(
                controller: tabController,
                children: watchProviders == null
                    ? [
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                        watchProvidersShimmer(themeMode),
                      ]
                    : [
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_buy"),
                            watchOptions: watchProviders!.buy),
                        watchProvidersTabData(
                            themeMode: themeMode,
                            imageQuality: imageQuality,
                            noOptionMessage: tr("no_stream"),
                            watchOptions: watchProviders!.flatRate),
                        watchProvidersTabData(
                            themeMode: themeMode,
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
  const ShimmerBase({Key? key, required this.child, required this.themeMode})
      : super(key: key);

  final Widget child;
  final String themeMode;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: themeMode == "dark" || themeMode == "amoled"
          ? Colors.grey.shade900
          : Colors.grey.shade300,
      highlightColor: themeMode == "dark" || themeMode == "amoled"
          ? Colors.grey.shade800.withOpacity(0.1)
          : Colors.grey.shade200,
      child: child,
    );
  }
}

class ReportErrorWidget extends StatelessWidget {
  const ReportErrorWidget(
      {Key? key, required this.error, required this.hideButton})
      : super(key: key);

  final String error;
  final bool hideButton;

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
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  error,
                  maxLines: 6,
                  textAlign: TextAlign.center,
                ),
                Visibility(
                  visible: !hideButton,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                        onPressed: () async {
                          await launchUrl(
                              Uri.parse("https://t.me/flixquestgroup"),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        )),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    currentAppVersion,
                    style: TextStyle(fontSize: 10),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExternalPlay extends StatelessWidget {
  const ExternalPlay(
      {Key? key, required this.videoSources, required this.subtitleSources})
      : super(key: key);

  final Map<String, String> videoSources;
  final List<BetterPlayerSubtitlesSource> subtitleSources;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Open in external player',
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            //  Text('Copy video:'),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ListView.builder(
                  itemCount: videoSources.entries.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: ((context, index) {
                    final url = Uri.encodeFull(
                        videoSources.entries.elementAt(index).value);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          onPressed: () async {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(
                                  Uri.parse(videoSources.entries
                                      .elementAt(index)
                                      .value),
                                  mode:
                                      LaunchMode.externalNonBrowserApplication);
                            }
                          },
                          onLongPress: () async {
                            FlutterClipboard.copy(
                                    videoSources.entries.elementAt(index).value)
                                .then((value) {
                              GlobalMethods.showScaffoldMessage(
                                  tr("video_link_copied"), context);
                              Navigator.pop(context);
                            });
                          },
                          child:
                              Text(videoSources.entries.elementAt(index).key)),
                    );
                  })),
            ),
          ],
        ),
      ),
    );
  }
}

// class SubtitleCopy extends StatelessWidget {
//   const SubtitleCopy({Key? key, required this.subtitleSources}) : super(key: key);

//   final List<BetterPlayerSubtitlesSource> subtitleSources;

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [  const SizedBox(
//               height: 10,
//             ),
//             Text('Copy subtitle:'),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ListView.builder(
//                   itemCount: subtitleSources.length,
//                   scrollDirection: Axis.horizontal,
//                   itemBuilder: ((context, index) {
//                     final url =
//                         Uri.encodeFull(
//                     subtitleSources.elementAt(index).content);
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextButton(
//                           onPressed: () async {
//                             if (await canLaunchUrl(Uri.parse(url))) {
//                               await launchUrl(
//                                   Uri.parse(
//                                       subtitleSources.entries.elementAt(index).value),
//                                   mode:
//                                       LaunchMode.externalNonBrowserApplication);
//                             }
//                           },
//                           onLongPress: () async {
//                             FlutterClipboard.copy(
//                                     subtitleSources.entries.elementAt(index).value)
//                                 .then((value) {
//                               GlobalMethods.showScaffoldMessage(
//                                   tr("video_link_copied"), context);
//                               Navigator.pop(context);
//                             });
//                           },
//                           child: Text(subtitleSources.entries.elementAt(index).key)),
//                     );
//                   })),
//             )
//       ],
//     );
//   }
// }

class LeadingDot extends StatelessWidget {
  const LeadingDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appLang = Provider.of<SettingsProvider>(context).appLanguage;
    return Container(
      color: Theme.of(context).primaryColor,
      width: 10,
      height: 25,
      margin: appLang == 'ar'
          ? const EdgeInsets.only(left: 8)
          : const EdgeInsets.only(right: 8),
    );
  }
}
