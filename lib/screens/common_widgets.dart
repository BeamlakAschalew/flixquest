import 'dart:convert';

import 'package:cinemax/provider/ads_provider.dart';
import 'package:cinemax/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:startapp_sdk/startapp.dart';

import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/models/function.dart';
import '/models/movie.dart';
import '/models/person.dart';
import '/models/tv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'about.dart';
import 'movie_detail.dart';
import 'searchedperson.dart';
import 'tv_detail.dart';

// class SearchWidget extends StatefulWidget {
//   final String? query;
//   const SearchWidget({
//     Key? key,
//     this.query,
//   }) : super(key: key);
//   @override
//   _SearchWidgetState createState() => _SearchWidgetState();
// }

// class _SearchWidgetState extends State<SearchWidget>
//     with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   List<Movie>? moviesList;
//   List<TV>? tvList;
//   List<Person>? personList;
//   late Mixpanel mixpanel;
//   TabController? tabController;
//   final ScrollController moviescrollController = ScrollController();
//   final ScrollController tvscrollController = ScrollController();
//   final ScrollController personcrollController = ScrollController();

//   int pageNum = 2;
//   bool isLoading = false;

//   Future<String> getMoreData() async {
//     moviescrollController.addListener(() async {
//       if (moviescrollController.position.pixels ==
//           moviescrollController.position.maxScrollExtent) {
//         setState(() {
//           isLoading = true;
//         });
//         var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
//             '/search/movie?api_key='
//             '$TMDB_API_KEY'
//             '&language=en-US'
//             '&query=${widget.query}'
//             '&page=$pageNum'
//             '&include_adult=false'));
//         setState(() {
//           pageNum++;
//           isLoading = false;
//           var newlistMovies = (json.decode(response.body)['results'] as List)
//               .map((i) => Movie.fromJson(i))
//               .toList();
//           moviesList!.addAll(newlistMovies);
//         });
//       }
//     });
//     tvscrollController.addListener(() async {
//       if (tvscrollController.position.pixels ==
//           tvscrollController.position.maxScrollExtent) {
//         setState(() {
//           isLoading = true;
//         });
//         var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
//             '/search/tv?api_key='
//             '$TMDB_API_KEY'
//             '&language=en-US'
//             '&query=${widget.query}'
//             '&page=$pageNum'
//             '&include_adult=false'));
//         setState(() {
//           pageNum++;
//           isLoading = false;
//           var newlistTV = (json.decode(response.body)['results'] as List)
//               .map((i) => TV.fromJson(i))
//               .toList();
//           tvList!.addAll(newlistTV);
//         });
//       }
//     });
//     personcrollController.addListener(() async {
//       if (personcrollController.position.pixels ==
//           personcrollController.position.maxScrollExtent) {
//         setState(() {
//           isLoading = true;
//         });
//         var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
//             '/search/person?api_key='
//             '$TMDB_API_KEY'
//             '&language=en-US'
//             '&query=${widget.query}'
//             '&page=$pageNum'
//             '&include_adult=false'));
//         setState(() {
//           pageNum++;
//           isLoading = false;
//           var newlistPerson = (json.decode(response.body)['results'] as List)
//               .map((i) => Person.fromJson(i))
//               .toList();
//           personList!.addAll(newlistPerson);
//         });
//       }
//     });

//     return "success";
//   }

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 3, vsync: this);
//     fetchMovies(Endpoints.movieSearchUrl(widget.query!)).then((value) {
//       setState(() {
//         moviesList = value;
//       });
//     });
//     fetchTV(Endpoints.tvSearchUrl(widget.query!)).then((value) {
//       setState(() {
//         tvList = value;
//       });
//     });
//     fetchPerson(Endpoints.personSearchUrl(widget.query!, false)).then((value) {
//       setState(() {
//         personList = value;
//       });
//     });
//     getMoreData();
//     initMixpanel();
//   }

//   Future<void> initMixpanel() async {
//     mixpanel = await Mixpanel.init(mixpanelKey,
//         optOutTrackingDefault: false);
//     mixpanel.track('Searched terms', properties: {
//       'search term': '${widget.query}',
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Scaffold(
//       body: Container(
//         color: const Color(0xFF202124),
//         child: moviesList == null || tvList == null || personList == null
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : Column(
//                 children: [
//                   TabBar(
//                     isScrollable: true,
//                     indicatorColor: const Color(0xFFF57C00),
//                     indicatorWeight: 3,
//                     unselectedLabelColor: Colors.white54,
//                     labelColor: Colors.white,
//                     indicatorSize: TabBarIndicatorSize.tab,
//                     controller: tabController,
//                     tabs: const [
//                       Tab(
//                         child: Text('Movies',
//                             style: TextStyle(fontFamily: 'Poppins')),
//                       ),
//                       Tab(
//                         child: Text('TV shows',
//                             style: TextStyle(fontFamily: 'Poppins')),
//                       ),
//                       Tab(
//                         child: Text('People',
//                             style: TextStyle(fontFamily: 'Poppins')),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: TabBarView(controller: tabController, children: [
//                       moviesList == null
//                           ? Container(
//                               color: const Color(0xFF202124),
//                               child: const Center(
//                                 child: CircularProgressIndicator(),
//                               ),
//                             )
//                           : moviesList!.isEmpty
//                               ? Container(
//                                   color: const Color(0xFF202124),
//                                   child: const Center(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Text(
//                                         'Oops! the movie you searched doesn\'t exist, if you searched for a TV show or a person select either of the tabs above',
//                                         style: TextStyle(fontFamily: 'Poppins'),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   color: const Color(0xFF202124),
//                                   child: Column(
//                                     children: [
//                                       Expanded(
//                                         child: Padding(
//                                           padding:
//                                               const EdgeInsets.only(top: 8.0),
//                                           child: ListView.builder(
//                                               controller: moviescrollController,
//                                               physics:
//                                                   const BouncingScrollPhysics(),
//                                               itemCount: moviesList!.length,
//                                               itemBuilder:
//                                                   (BuildContext context,
//                                                       int index) {
//                                                 return GestureDetector(
//                                                   onTap: () {
//                                                     mixpanel.track(
//                                                         'Most viewed movie pages',
//                                                         properties: {
//                                                           'Movie name':
//                                                               '${moviesList![index].originalTitle}',
//                                                           'Movie id':
//                                                               '${moviesList![index].id}'
//                                                         });
//                                                     Navigator.pushReplacement(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder: (context) {
//                                                       return MovieDetailPage(
//                                                         movie:
//                                                             moviesList![index],
//                                                         heroId:
//                                                             '${moviesList![index].id}',
//                                                       );
//                                                     }));
//                                                   },
//                                                   child: Container(
//                                                     color:
//                                                         const Color(0xFF202124),
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                         top: 0.0,
//                                                         bottom: 8.0,
//                                                         left: 10,
//                                                       ),
//                                                       child: Column(
//                                                         children: [
//                                                           Row(
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .only(
//                                                                         right:
//                                                                             10.0),
//                                                                 child: SizedBox(
//                                                                   width: 85,
//                                                                   height: 130,
//                                                                   child: Hero(
//                                                                     tag:
//                                                                         '${moviesList![index].id}',
//                                                                     child:
//                                                                         ClipRRect(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10.0),
//                                                                       child: moviesList![index].posterPath ==
//                                                                               null
//                                                                           ? Image
//                                                                               .asset(
//                                                                               'assets/images/na_logo.png',
//                                                                               fit: BoxFit.cover,
//                                                                             )
//                                                                           : FadeInImage(
//                                                                               image: NetworkImage(TMDB_BASE_IMAGE_URL + 'w500/' + moviesList![index].posterPath!),
//                                                                               fit: BoxFit.cover,
//                                                                               placeholder: const AssetImage('assets/images/loading.gif'),
//                                                                             ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               Expanded(
//                                                                 child: Column(
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   children: [
//                                                                     Text(
//                                                                       moviesList![
//                                                                               index]
//                                                                           .title!,
//                                                                       style: const TextStyle(
//                                                                           fontFamily:
//                                                                               'PoppinsSB',
//                                                                           fontSize:
//                                                                               15,
//                                                                           overflow:
//                                                                               TextOverflow.ellipsis),
//                                                                     ),
//                                                                     Row(
//                                                                       children: <
//                                                                           Widget>[
//                                                                         const Icon(
//                                                                             Icons
//                                                                                 .star,
//                                                                             color:
//                                                                                 Color(0xFFF57C00)),
//                                                                         Text(
//                                                                           moviesList![index]
//                                                                               .voteAverage!
//                                                                               .toStringAsFixed(1),
//                                                                           style:
//                                                                               const TextStyle(fontFamily: 'Poppins'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                           const Divider(
//                                                             color: Colors.white,
//                                                             thickness: 1,
//                                                             endIndent: 20,
//                                                             indent: 10,
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 );
//                                               }),
//                                         ),
//                                       ),
//                                       Visibility(
//                                           visible: isLoading,
//                                           child: const Padding(
//                                             padding: EdgeInsets.all(8.0),
//                                             child: Center(
//                                                 child:
//                                                     CircularProgressIndicator()),
//                                           )),
//                                     ],
//                                   )),
//                       tvList == null
//                           ? Container(
//                               color: const Color(0xFF202124),
//                               child: const Center(
//                                 child: CircularProgressIndicator(),
//                               ),
//                             )
//                           : tvList!.isEmpty
//                               ? Container(
//                                   color: const Color(0xFF202124),
//                                   child: const Center(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Text(
//                                         'Oops! the TV show you searched doesn\'t exist, if you searched for a movie or a person select either of the tabs above',
//                                         style: TextStyle(fontFamily: 'Poppins'),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   color: const Color(0xFF202124),
//                                   child: Column(
//                                     children: [
//                                       Expanded(
//                                         child: Padding(
//                                           padding:
//                                               const EdgeInsets.only(top: 8.0),
//                                           child: ListView.builder(
//                                               controller: tvscrollController,
//                                               physics:
//                                                   const BouncingScrollPhysics(),
//                                               itemCount: tvList!.length,
//                                               itemBuilder:
//                                                   (BuildContext context,
//                                                       int index) {
//                                                 return GestureDetector(
//                                                   onTap: () {
//                                                     mixpanel.track(
//                                                         'Most viewed TV pages',
//                                                         properties: {
//                                                           'TV series name':
//                                                               '${tvList![index].originalName}',
//                                                           'TV series id':
//                                                               '${tvList![index].id}'
//                                                         });
//                                                     Navigator.pushReplacement(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder: (context) {
//                                                       return TVDetailPage(
//                                                           tvSeries:
//                                                               tvList![index],
//                                                           heroId:
//                                                               '${tvList![index].id}');
//                                                     }));
//                                                   },
//                                                   child: Container(
//                                                     color:
//                                                         const Color(0xFF202124),
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                         top: 0.0,
//                                                         bottom: 8.0,
//                                                         left: 10,
//                                                       ),
//                                                       child: Column(
//                                                         children: [
//                                                           Row(
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .only(
//                                                                         right:
//                                                                             10.0),
//                                                                 child: SizedBox(
//                                                                   width: 85,
//                                                                   height: 130,
//                                                                   child: Hero(
//                                                                     tag:
//                                                                         '${tvList![index].id}',
//                                                                     child:
//                                                                         ClipRRect(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10.0),
//                                                                       child: tvList![index].posterPath ==
//                                                                               null
//                                                                           ? Image
//                                                                               .asset(
//                                                                               'assets/images/na_logo.png',
//                                                                               fit: BoxFit.cover,
//                                                                             )
//                                                                           : FadeInImage(
//                                                                               image: NetworkImage(TMDB_BASE_IMAGE_URL + 'w500/' + tvList![index].posterPath!),
//                                                                               fit: BoxFit.cover,
//                                                                               placeholder: const AssetImage('assets/images/loading.gif'),
//                                                                             ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               Expanded(
//                                                                 child: Column(
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   children: [
//                                                                     Text(
//                                                                       tvList![index]
//                                                                           .originalName!,
//                                                                       style: const TextStyle(
//                                                                           fontFamily:
//                                                                               'PoppinsSB',
//                                                                           fontSize:
//                                                                               15,
//                                                                           overflow:
//                                                                               TextOverflow.ellipsis),
//                                                                     ),
//                                                                     Row(
//                                                                       children: <
//                                                                           Widget>[
//                                                                         const Icon(
//                                                                             Icons
//                                                                                 .star,
//                                                                             color:
//                                                                                 Color(0xFFF57C00)),
//                                                                         Text(
//                                                                           tvList![index]
//                                                                               .voteAverage!
//                                                                               .toStringAsFixed(1),
//                                                                           style:
//                                                                               const TextStyle(fontFamily: 'Poppins'),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                           const Divider(
//                                                             color: Colors.white,
//                                                             thickness: 1,
//                                                             endIndent: 20,
//                                                             indent: 10,
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 );
//                                               }),
//                                         ),
//                                       ),
//                                       Visibility(
//                                           visible: isLoading,
//                                           child: const Padding(
//                                             padding: EdgeInsets.all(8.0),
//                                             child: Center(
//                                                 child:
//                                                     CircularProgressIndicator()),
//                                           )),
//                                     ],
//                                   )),
//                       personList == null
//                           ? Container(
//                               color: const Color(0xFF202124),
//                               child: const Center(
//                                 child: CircularProgressIndicator(),
//                               ),
//                             )
//                           : personList!.isEmpty
//                               ? Container(
//                                   child: const Center(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Text(
//                                         'Oops! the person you searched doesn\'t exist, if you searched for a TV show or a movie select either of the tabs above',
//                                         style: TextStyle(fontFamily: 'Poppins'),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                   color: const Color(0xFF202124),
//                                 )
//                               : Container(
//                                   color: const Color(0xFF202124),
//                                   child: ListView.builder(
//                                       controller: personcrollController,
//                                       physics: const BouncingScrollPhysics(),
//                                       itemCount: personList!.length,
//                                       itemBuilder:
//                                           (BuildContext context, int index) {
//                                         return GestureDetector(
//                                           onTap: () {
//                                             mixpanel.track(
//                                                 'Most viewed person pages',
//                                                 properties: {
//                                                   'Person name':
//                                                       '${personList![index].name}',
//                                                   'Person id':
//                                                       '${personList![index].id}'
//                                                 });
//                                             Navigator.pushReplacement(context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) {
//                                               return SearchedPersonDetailPage(
//                                                   person: personList![index],
//                                                   heroId:
//                                                       '${personList![index].id}');
//                                             }));
//                                           },
//                                           child: Container(
//                                             color: const Color(0xFF202124),
//                                             child: Padding(
//                                               padding: const EdgeInsets.only(
//                                                 top: 0.0,
//                                                 bottom: 15.0,
//                                                 left: 15,
//                                               ),
//                                               child: Column(
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                     .only(
//                                                                 right: 20.0),
//                                                         child: SizedBox(
//                                                           width: 80,
//                                                           height: 80,
//                                                           child: Hero(
//                                                             tag:
//                                                                 '${personList![index].id}',
//                                                             child: ClipRRect(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           100.0),
//                                                               child: personList![
//                                                                               index]
//                                                                           .profilePath ==
//                                                                       null
//                                                                   ? Image.asset(
//                                                                       'assets/images/na_square.png',
//                                                                       fit: BoxFit
//                                                                           .cover,
//                                                                     )
//                                                                   : FadeInImage(
//                                                                       image: NetworkImage(TMDB_BASE_IMAGE_URL +
//                                                                           'w500/' +
//                                                                           personList![index]
//                                                                               .profilePath!),
//                                                                       fit: BoxFit
//                                                                           .cover,
//                                                                       placeholder:
//                                                                           const AssetImage(
//                                                                               'assets/images/loading.gif'),
//                                                                     ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Expanded(
//                                                         child: Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               personList![index]
//                                                                   .name!,
//                                                               style: const TextStyle(
//                                                                   fontFamily:
//                                                                       'PoppinsSB',
//                                                                   fontSize: 17),
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       })),
//                     ]),
//                   ),
//                   Visibility(
//                       visible: isLoading,
//                       child: const Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Center(child: CircularProgressIndicator()),
//                       )),
//                 ],
//               ),
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;
  @override
  void initState() {
    print('state called');
    super.initState();
    startAppSdk
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAd = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Image.asset('assets/images/logo_shadow.png'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return const Settings();
                  })));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AboutPage();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_sharp),
                title: const Text('Share the app'),
                onTap: () async {
                  await Share.share(
                      'Download the Cinemax app for free and watch your favorite movies and TV shows for free! Download the app from the link below.\nhttps://cinemax.rf.gd/');
                },
              ),
            ],
          ),
          bannerAd != null ? StartAppBanner(bannerAd!) : Container(),
        ],
      ),
    );
  }
}
