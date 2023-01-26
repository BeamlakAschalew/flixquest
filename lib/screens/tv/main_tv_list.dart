import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/tv_ui_components.dart';
import '/models/tv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';
import '../../models/function.dart';
import '../../widgets/common_widgets.dart';

class MainTVList extends StatefulWidget {
  final String api;
  final bool? includeAdult;
  final String discoverType;
  final bool isTrending;
  final String title;
  const MainTVList({
    Key? key,
    required this.api,
    required this.discoverType,
    required this.isTrending,
    required this.includeAdult,
    required this.title,
  }) : super(key: key);
  @override
  MainTVListState createState() => MainTVListState();
}

class MainTVListState extends State<MainTVList> {
  List<TV>? tvList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;
  bool requestFailed = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (widget.isTrending == false) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/tv/${widget.discoverType}?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}&page=$pageNum"),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistTv = (json.decode(response.body)['results'] as List)
                .map((i) => TV.fromJson(i))
                .toList();
            tvList!.addAll(newlistTv);
          });
        } else if (widget.isTrending == true) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/trending/tv/week?api_key=$TMDB_API_KEY&language=en-US&include_adult=${widget.includeAdult}&page=$pageNum"),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistTv = (json.decode(response.body)['results'] as List)
                .map((i) => TV.fromJson(i))
                .toList();
            tvList!.addAll(newlistTv);
          });
        }
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getData();
    getMoreData();
  }

  void getData() {
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (tvList == null) {
        setState(() {
          requestFailed = true;
          tvList = [TV()];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} TV shows'),
      ),
      body: tvList == null && viewType == 'grid'
          ? moviesAndTVShowGridShimmer(isDark)
          : tvList == null && viewType == 'list'
              ? Container(
                  color: isDark
                      ? const Color(0xFF000000)
                      : const Color(0xFFFFFFFF),
                  child: mainPageVerticalScrollShimmer(
                      isDark: isDark,
                      isLoading: isLoading,
                      scrollController: _scrollController))
              : tvList!.isEmpty
                  ? const Center(
                      child: Text('Oops! the TV shows don\'t exist :('),
                    )
                  : requestFailed == true
                      ? retryWidget(isDark)
                      : Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: viewType == 'grid'
                                          ? TVGridView(
                                              tvList: tvList,
                                              imageQuality: imageQuality,
                                              isDark: isDark,
                                              scrollController:
                                                  _scrollController,
                                            )
                                          : TVListView(
                                              scrollController:
                                                  _scrollController,
                                              tvList: tvList,
                                              isDark: isDark,
                                              imageQuality: imageQuality),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                                visible: isLoading,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )),
                          ],
                        ),
    );
  }

  Widget retryWidget(isDark) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/network-signal.svg',
          width: 60,
          height: 60,
          color: Theme.of(context).colorScheme.primary,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Please connect to the Internet and try again',
              textAlign: TextAlign.center),
        ),
        TextButton(
            onPressed: () {
              setState(() {
                requestFailed = false;
                tvList = null;
              });
              getData();
            },
            child: const Text('Retry')),
      ],
    ));
  }
}