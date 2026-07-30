import 'package:flutter/widgets.dart';

class TvFocusMemory {
  final Map<String, String> _focusedItemByScope = <String, String>{};

  String? recall(String scopeId) => _focusedItemByScope[scopeId];

  void remember({
    required String scopeId,
    required String itemId,
  }) {
    _focusedItemByScope[scopeId] = itemId;
  }

  void forget(String scopeId) {
    _focusedItemByScope.remove(scopeId);
  }

  void clear() {
    _focusedItemByScope.clear();
  }
}

class TvFocusMemoryScope extends InheritedWidget {
  const TvFocusMemoryScope({
    required this.memory,
    required super.child,
    super.key,
  });

  final TvFocusMemory memory;

  static TvFocusMemory? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TvFocusMemoryScope>()
        ?.memory;
  }

  static TvFocusMemory of(BuildContext context) {
    final memory = maybeOf(context);
    assert(memory != null, 'No TvFocusMemoryScope found in this context.');
    return memory!;
  }

  @override
  bool updateShouldNotify(TvFocusMemoryScope oldWidget) {
    return memory != oldWidget.memory;
  }
}
