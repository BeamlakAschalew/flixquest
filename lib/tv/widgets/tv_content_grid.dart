import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/tv_design.dart';
import '../focus/tv_focus_memory.dart';
import '../focus/tv_focusable.dart';

typedef TvGridItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  double itemWidth,
);

class TvContentGrid<T> extends StatefulWidget {
  const TvContentGrid({
    required this.scopeId,
    required this.items,
    required this.itemId,
    required this.semanticLabel,
    required this.itemBuilder,
    required this.onItemActivated,
    required this.targetItemWidth,
    this.autofocus = false,
    this.controller,
    this.padding = const EdgeInsets.all(TvDesign.focusOutset),
    this.horizontalSpacing = 22,
    this.verticalSpacing = 24,
    super.key,
  });

  final String scopeId;
  final List<T> items;
  final String Function(T item) itemId;
  final String Function(T item) semanticLabel;
  final TvGridItemBuilder<T> itemBuilder;
  final ValueChanged<T> onItemActivated;
  final double targetItemWidth;
  final bool autofocus;
  final TvContentGridController? controller;
  final EdgeInsets padding;
  final double horizontalSpacing;
  final double verticalSpacing;

  @override
  State<TvContentGrid<T>> createState() => _TvContentGridState<T>();
}

class TvContentGridController {
  _TvContentGridState<dynamic>? _state;
  bool _pendingRequest = false;

  void requestFocus() {
    final state = _state;
    if (state == null) {
      _pendingRequest = true;
      return;
    }
    state._requestPreferredFocus();
  }

  void _attach(_TvContentGridState<dynamic> state) {
    _state = state;
    if (_pendingRequest) {
      _pendingRequest = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (identical(_state, state) && state.mounted) {
          state._requestPreferredFocus();
        }
      });
    }
  }

  void _detach(_TvContentGridState<dynamic> state) {
    if (identical(_state, state)) _state = null;
  }
}

class _TvContentGridState<T> extends State<TvContentGrid<T>> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  final ScrollController _scrollController = ScrollController();
  bool _scheduledInitialFocus = false;

  @override
  void initState() {
    super.initState();
    _syncFocusNodes();
    widget.controller?._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleInitialFocus();
  }

  @override
  void didUpdateWidget(TvContentGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (oldWidget.scopeId != widget.scopeId) {
      for (final node in _focusNodes.values) {
        node.dispose();
      }
      _focusNodes.clear();
      _scheduledInitialFocus = false;
    }
    _syncFocusNodes();
    _scheduleInitialFocus();
  }

  void _syncFocusNodes() {
    final ids = widget.items.map(widget.itemId).toList(growable: false);
    assert(
      ids.toSet().length == ids.length,
      'TV content grid item IDs must be unique.',
    );
    for (final id in ids) {
      _focusNodes.putIfAbsent(
        id,
        () => FocusNode(debugLabel: '${widget.scopeId}:$id'),
      );
    }
    final activeIds = ids.toSet();
    final removed =
        _focusNodes.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in removed) {
      _focusNodes.remove(id)?.dispose();
    }
  }

  void _scheduleInitialFocus() {
    if (_scheduledInitialFocus || widget.items.isEmpty) return;
    final memory = TvFocusMemoryScope.maybeOf(context);
    final rememberedId = memory?.recall(widget.scopeId);
    if (!widget.autofocus && rememberedId == null) return;
    _scheduledInitialFocus = true;
    _requestPreferredFocus();
  }

  void _requestPreferredFocus() {
    if (widget.items.isEmpty) return;
    final memory = TvFocusMemoryScope.maybeOf(context);
    final rememberedId = memory?.recall(widget.scopeId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final firstId = widget.itemId(widget.items.first);
      (_focusNodes[rememberedId] ?? _focusNodes[firstId])?.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _handleGridKey({
    required KeyEvent event,
    required int index,
    required int columnCount,
    required double itemHeight,
  }) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    int? targetIndex;
    if (key == LogicalKeyboardKey.arrowUp && index >= columnCount) {
      targetIndex = index - columnCount;
    } else if (key == LogicalKeyboardKey.arrowDown &&
        index + columnCount < widget.items.length) {
      targetIndex = index + columnCount;
    } else if (key == LogicalKeyboardKey.arrowLeft && index % columnCount > 0) {
      targetIndex = index - 1;
    } else if (key == LogicalKeyboardKey.arrowRight &&
        index % columnCount < columnCount - 1 &&
        index + 1 < widget.items.length) {
      targetIndex = index + 1;
    }
    if (targetIndex == null) {
      if (key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowDown) {
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    unawaited(
      _revealAndFocus(
        targetIndex: targetIndex,
        itemHeight: itemHeight,
        columnCount: columnCount,
      ),
    );
    return KeyEventResult.handled;
  }

  Future<void> _revealAndFocus({
    required int targetIndex,
    required int columnCount,
    required double itemHeight,
  }) async {
    final targetId = widget.itemId(widget.items[targetIndex]);
    final targetNode = _focusNodes[targetId];
    if (targetNode?.context != null) {
      targetNode?.requestFocus();
      return;
    }
    if (!_scrollController.hasClients) return;
    final targetRow = targetIndex ~/ columnCount;
    final desiredOffset = widget.padding.top +
        (targetRow * (itemHeight + widget.verticalSpacing)) -
        (itemHeight * 0.35);
    final position = _scrollController.position;
    await _scrollController.animateTo(
      desiredOffset.clamp(0, position.maxScrollExtent),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[targetId]?.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final memory = TvFocusMemoryScope.maybeOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final usableWidth = constraints.maxWidth -
            widget.padding.horizontal +
            widget.horizontalSpacing;
        final columnCount =
            (usableWidth / (widget.targetItemWidth + widget.horizontalSpacing))
                .floor()
                .clamp(1, 8);
        final itemWidth =
            (usableWidth / columnCount) - widget.horizontalSpacing;
        const focusPadding = 6.0;
        final contentWidth = itemWidth - (focusPadding * 2);
        final itemHeight = (contentWidth / (16 / 9)) + 60 + (focusPadding * 2);

        return FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: GridView.builder(
            controller: _scrollController,
            clipBehavior: Clip.hardEdge,
            padding: widget.padding,
            itemCount: widget.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              crossAxisSpacing: widget.horizontalSpacing,
              mainAxisSpacing: widget.verticalSpacing,
              childAspectRatio: itemWidth / itemHeight,
            ),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final id = widget.itemId(item);
              return TvFocusable(
                key: ValueKey<String>('${widget.scopeId}:$id'),
                focusNode: _focusNodes[id],
                semanticLabel: widget.semanticLabel(item),
                onFocusChanged: (hasFocus) {
                  if (hasFocus) {
                    memory?.remember(scopeId: widget.scopeId, itemId: id);
                  }
                },
                onActivate: () => widget.onItemActivated(item),
                onKeyEvent: (_, event) => _handleGridKey(
                  event: event,
                  index: index,
                  columnCount: columnCount,
                  itemHeight: itemHeight,
                ),
                padding: const EdgeInsets.all(focusPadding),
                child: widget.itemBuilder(context, item, contentWidth),
              );
            },
          ),
        );
      },
    );
  }
}
