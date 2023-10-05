import 'package:easy_localization/easy_localization.dart';

import '../../provider/settings_provider.dart';
import '../../ui_components/tv_ui_components.dart';
import '/models/tv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functions/network.dart';
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

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("genre_tv_title", namedArgs: {"g": widget.title})),
      ),
      body: tvList == null && viewType == 'grid'
          ? moviesAndTVShowGridShimmer(isDark)
          : tvList == null && viewType == 'list'
              ? mainPageVerticalScrollShimmer(
                  isDark: isDark,
                  isLoading: isLoading,
                  scrollController: _scrollController)
              : tvList!.isEmpty
                  ? Center(
                      child: Text(tr("tv_404")),
                    )
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
                                          scrollController: _scrollController,
                                        )
                                      : TVListView(
                                          scrollController: _scrollController,
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
                              child: Center(child: LinearProgressIndicator()),
                            )),
                      ],
                    ),
    );
  }
}
