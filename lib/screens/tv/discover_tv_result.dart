import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../provider/app_dependency_provider.dart';
import '../../ui_components/app_ui_components.dart';
import '../../ui_components/tv_ui_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functions/network.dart';
import '../../models/tv.dart';
import '../../provider/settings_provider.dart';

class DiscoverTVResult extends StatefulWidget {
  const DiscoverTVResult({required this.api, required this.page, super.key});
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
  Object? error;

  Future<void> _loadMore() async {
    if (isLoading || tvList == null) return;
    setState(() => isLoading = true);
    final settings = context.read<SettingsProvider>();
    final dependencies = context.read<AppDependencyProvider>();
    try {
      final value = await fetchTV(
        '${widget.api}&page=$pageNum',
        settings.enableProxy,
        dependencies.tmdbProxy,
      );
      if (!mounted) return;
      setState(() {
        tvList!.addAll(value);
        isLoading = false;
        pageNum++;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception;
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 320) _loadMore();
  }

  Future<void> _loadInitial() async {
    final settings = context.read<SettingsProvider>();
    final dependencies = context.read<AppDependencyProvider>();
    try {
      final value = await fetchTV(
        '${widget.api}&page=${widget.page}',
        settings.enableProxy,
        dependencies.tmdbProxy,
      );
      if (mounted) setState(() => tvList = value);
    } catch (exception) {
      if (mounted) setState(() => error = exception);
    }
  }

  @override
  void initState() {
    super.initState();
    pageNum = widget.page + 1;
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('discover_tv_series')),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: error != null && tvList == null
          ? AppEmptyState(
              icon: PhosphorIcons.cloudSlash(),
              title: tr('error_occured'),
              message: tr('check_connection'),
              action: FilledButton(
                onPressed: () {
                  setState(() => error = null);
                  _loadInitial();
                },
                child: Text(tr('retry')),
              ),
            )
          : tvList == null && viewType == 'grid'
              ? const AppMediaGridShimmer()
              : tvList == null
                  ? const AppMediaListShimmer()
                  : tvList!.isEmpty
                      ? AppEmptyState(
                          icon: PhosphorIcons.televisionSimple(),
                          title: tr('discover_tv_series'),
                          message: tr('parameter_tv_404'),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: viewType == 'grid'
                                  ? TVGridView(
                                      tvList: tvList,
                                      imageQuality: imageQuality,
                                      themeMode: themeMode,
                                      scrollController: _scrollController,
                                    )
                                  : TVListView(
                                      scrollController: _scrollController,
                                      tvList: tvList,
                                      themeMode: themeMode,
                                      imageQuality: imageQuality,
                                    ),
                            ),
                            AppLoadingFooter(visible: isLoading),
                          ],
                        ),
    );
  }
}
