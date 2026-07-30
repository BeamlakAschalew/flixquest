import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../focus/tv_keymap.dart';

class TvBackDispatcher extends StatefulWidget {
  const TvBackDispatcher({
    required this.child,
    required this.onBack,
    this.exitAtRoot = true,
    super.key,
  });

  final Widget child;
  final FutureOr<bool> Function() onBack;
  final bool exitAtRoot;

  @override
  State<TvBackDispatcher> createState() => _TvBackDispatcherState();
}

class _TvBackDispatcherState extends State<TvBackDispatcher> {
  bool _handlingBack = false;

  Future<void> _handleBack() async {
    if (_handlingBack) {
      return;
    }
    _handlingBack = true;
    try {
      final wasHandled = await widget.onBack();
      if (!wasHandled && widget.exitAtRoot) {
        await SystemNavigator.pop(animated: true);
      }
    } finally {
      _handlingBack = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(_handleBack());
        }
      },
      child: TvKeymap(
        onBack: _handleBack,
        child: widget.child,
      ),
    );
  }
}
