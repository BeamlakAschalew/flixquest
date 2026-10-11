import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../video_providers/names.dart';
import '../../video_providers/scraper_api.dart';
import 'tv_dialog.dart';
import 'tv_list_row.dart';
import 'tv_pill_button.dart';

Future<void> showTvProviderOrderDialog(
  BuildContext context, {
  Future<List<VideoProvider>> Function()? loadProviders,
}) {
  return showTvDialog<void>(
    context: context,
    title: tr('tv_video_provider_order'),
    content: TvProviderOrderContent(loadProviders: loadProviders),
    actions: <TvDialogAction>[
      TvDialogAction(
        label: tr('tv_done'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}

/// Remote-operated ordering of the current source catalog. Discovery never
/// writes preferences; only an explicit move saves the new order.
class TvProviderOrderContent extends StatefulWidget {
  const TvProviderOrderContent({this.loadProviders, super.key});

  final Future<List<VideoProvider>> Function()? loadProviders;

  @override
  State<TvProviderOrderContent> createState() => _TvProviderOrderContentState();
}

class _TvProviderOrderContentState extends State<TvProviderOrderContent> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  List<VideoProvider> _providers = <VideoProvider>[];
  bool _loading = false;
  bool _discoveryFailed = false;

  FocusNode _nodeFor(VideoProvider provider) => _focusNodes.putIfAbsent(
        provider.codeName,
        () => FocusNode(debugLabel: 'Provider order: ${provider.displayName}'),
      );

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProviders() async {
    if (_loading) return;
    final settings = context.read<SettingsProvider>();
    final entering = _providers.isEmpty;
    setState(() {
      _loading = true;
      _discoveryFailed = false;
    });

    List<VideoProvider>? discovered;
    try {
      discovered = await (widget.loadProviders?.call() ??
          ScraperApi(context.read<AppDependencyProvider>().flixquestAPIURL)
              .getProviders());
    } catch (error) {
      debugPrint('TV provider discovery failed: $error');
    }
    if (!mounted) return;
    setState(() {
      // Retain the last catalog on retry failure. The direct source is still
      // usable if the first discovery fails; saved priorities stay untouched.
      if (discovered != null || _providers.isEmpty) {
        _providers = settings.orderStreamProviders(<VideoProvider>[
          ...?discovered,
          VideoProvider.directVixSrc,
        ]);
      }
      _discoveryFailed = discovered == null;
      _loading = false;
    });
    if (entering) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _nodeFor(_providers.first).requestFocus();
      });
    }
  }

  Future<void> _chooseMove(VideoProvider provider) async {
    if (_loading) return;
    final index = _providers.indexWhere(
      (candidate) => candidate.codeName == provider.codeName,
    );
    if (_providers.length < 2 || index < 0) return;
    final move = await showTvDialog<int>(
      context: context,
      title: provider.displayName,
      content: Text(tr('tv_provider_priority', namedArgs: {
        'position': '${index + 1}',
        'total': '${_providers.length}'
      })),
      actions: <TvDialogAction>[
        if (index > 0)
          TvDialogAction(
            label: tr('tv_move_earlier'),
            onPressed: () => Navigator.of(context).pop(-1),
          ),
        if (index < _providers.length - 1)
          TvDialogAction(
            label: tr('tv_move_later'),
            onPressed: () => Navigator.of(context).pop(1),
          ),
        TvDialogAction(
          label: tr('cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
    if (!mounted || move == null) return;
    setState(() {
      final moved = _providers.removeAt(index);
      _providers.insert(index + move, moved);
    });
    context.read<SettingsProvider>().setStreamProviderOrder(_providers);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nodeFor(provider).requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(tr(
            'tv_sources_are_tried_from_top_to_bottom_select_a_source_to_move_it_earlier_or_later')),
        const SizedBox(height: 18),
        if (_loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(tr('tv_loading_sources')),
          ),
        if (_discoveryFailed) ...<Widget>[
          Text(
              tr('tv_could_not_refresh_sources_your_saved_order_is_unchanged')),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TvPillButton(label: tr('retry'), onActivate: _loadProviders),
          ),
          const SizedBox(height: 12),
        ],
        for (var index = 0; index < _providers.length; index++)
          TvListRow(
            key: ValueKey<String>(_providers[index].codeName),
            focusNode: _nodeFor(_providers[index]),
            label: _providers[index].displayName,
            value: '${index + 1}',
            showsNext: _providers.length > 1,
            onActivate: () => _chooseMove(_providers[index]),
          ),
      ],
    );
  }
}
