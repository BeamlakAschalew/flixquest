import 'package:flutter/material.dart';

import '../focus/tv_focus_memory.dart';
import '../focus/tv_focusable.dart';
import '../app/tv_design.dart';

typedef TvContentItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);

class TvContentRow<T> extends StatefulWidget {
  const TvContentRow({
    required this.title,
    required this.scopeId,
    required this.items,
    required this.itemId,
    required this.semanticLabel,
    required this.itemBuilder,
    required this.onItemActivated,
    this.autofocus = false,
    this.itemSpacing = 24,
    super.key,
  });

  final String title;
  final String scopeId;
  final List<T> items;
  final String Function(T item) itemId;
  final String Function(T item) semanticLabel;
  final TvContentItemBuilder<T> itemBuilder;
  final ValueChanged<T> onItemActivated;
  final bool autofocus;
  final double itemSpacing;

  @override
  State<TvContentRow<T>> createState() => _TvContentRowState<T>();
}

class _TvContentRowState<T> extends State<TvContentRow<T>> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  bool _scheduledInitialFocus = false;

  @override
  void initState() {
    super.initState();
    _syncFocusNodes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleInitialFocus();
  }

  @override
  void didUpdateWidget(TvContentRow<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scopeId != widget.scopeId) {
      for (final node in _focusNodes.values) {
        node.dispose();
      }
      _focusNodes.clear();
    }
    _syncFocusNodes();
    if (oldWidget.scopeId != widget.scopeId ||
        oldWidget.autofocus != widget.autofocus) {
      _scheduledInitialFocus = false;
      _scheduleInitialFocus();
    }
  }

  void _syncFocusNodes() {
    final ids = widget.items.map(widget.itemId).toList(growable: false);
    assert(ids.toSet().length == ids.length,
        'TV content row item IDs must be unique within a row.');
    for (var index = 0; index < ids.length; index++) {
      final id = ids[index];
      _focusNodes.putIfAbsent(
        id,
        () => FocusNode(debugLabel: '${widget.scopeId}:$id'),
      );
    }
    final currentIds = ids.toSet();
    final removedIds =
        _focusNodes.keys.where((id) => !currentIds.contains(id)).toList();
    for (final id in removedIds) {
      _focusNodes.remove(id)?.dispose();
    }
  }

  void _scheduleInitialFocus() {
    if (_scheduledInitialFocus || widget.items.isEmpty) {
      return;
    }
    final memory = TvFocusMemoryScope.maybeOf(context);
    final rememberedId = memory?.recall(widget.scopeId);
    if (!widget.autofocus && rememberedId == null) {
      return;
    }
    _scheduledInitialFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final firstId = widget.itemId(widget.items.first);
      final targetNode = _focusNodes[rememberedId] ?? _focusNodes[firstId];
      targetNode?.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memory = TvFocusMemoryScope.maybeOf(context);
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: TextStyle(
            color: colors.onSurface,
            fontFamily: 'FigtreeSB',
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 18),
        FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(
              vertical: TvDesign.focusOutset,
              horizontal: TvDesign.focusOutset,
            ),
            child: Row(
              children: <Widget>[
                for (var index = 0; index < widget.items.length; index++) ...[
                  Builder(
                    builder: (context) {
                      final item = widget.items[index];
                      final id = widget.itemId(item);
                      return TvFocusable(
                        key: ValueKey<String>('${widget.scopeId}:$id'),
                        focusNode: _focusNodes[id],
                        semanticLabel: widget.semanticLabel(item),
                        onFocusChanged: (hasFocus) {
                          if (hasFocus) {
                            memory?.remember(
                              scopeId: widget.scopeId,
                              itemId: id,
                            );
                          }
                        },
                        onActivate: () => widget.onItemActivated(item),
                        padding: const EdgeInsets.all(6),
                        child: widget.itemBuilder(context, item),
                      );
                    },
                  ),
                  if (index != widget.items.length - 1)
                    SizedBox(width: widget.itemSpacing),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
