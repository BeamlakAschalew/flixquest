import 'dart:async';
import 'dart:io';
import '../../ui_components/tv_ui_components.dart';
import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../models/function.dart';
import '../../models/tv.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart';

class DiscoverTVResult extends StatefulWidget {
  const DiscoverTVResult({required this.api, required this.page, Key? key})
      : super(key: key);
  final String api;
  final int page;

  @override
  State<DiscoverTVResult> createState() => _DiscoverTVResultState();
}

class _DiscoverTVResultState extends State<DiscoverTVResult> {
  List<TV>? tvList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        try {
          var response = await retryOptions.retry(
            () => http.get(Uri.parse('${widget.api}&page=$pageNum')),
            retryIf: (e) => e is SocketException || e is TimeoutException,
          );

          setState(() {
            pageNum++;
            isLoading = false;
            var newlistTV = (json.decode(response.body)['results'] as List)
                .map((i) => TV.fromJson(i))
                .toList();
            tvList!.addAll(newlistTV);
          });
        } finally {
          client.close();
        }
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    fetchTV('${widget.api}&page=${widget.page}}').then((value) {
      setState(() {
        tvList = value;
      });
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
          title: const Text(
            'Discover TV series',
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
        body: Container(
            child: tvList == null && viewType == 'grid'
                ? moviesAndTVShowGridShimmer(isDark)
                : tvList == null && viewType == 'list'
                    ? Container(
                        child: mainPageVerticalScrollShimmer(
                            isDark: isDark,
                            isLoading: isLoading,
                            scrollController: _scrollController))
                    : tvList!.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            child: const Center(
                              child: Text(
                                'Oops! TV series for the parameters you specified doesn\'t exist :(',
                                style: kTextHeaderStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                          )));
  }
}
