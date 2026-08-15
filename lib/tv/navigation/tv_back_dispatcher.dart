import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../focus/tv_keymap.dart';
import '../widgets/tv_dialog.dart';

class TvBackDispatcher extends StatefulWidget {
  const TvBackDispatcher({
    required this.child,
    required this.onBack,
    this.exitAtRoot = true,
    this.onExit,
    super.key,
  });

  final Widget child;
  final FutureOr<bool> Function() onBack;
  final bool exitAtRoot;
  final FutureOr<void> Function()? onExit;

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
      if (!wasHandled && widget.exitAtRoot && mounted) {
        final shouldExit = await showTvDialog<bool>(
          context: context,
          title: 'Exit FlixQuest?',
          content: const Text('Are you sure you want to close the app?'),
          actions: <TvDialogAction>[
            TvDialogAction(
              label: 'Cancel',
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TvDialogAction(
              label: 'Exit',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
        if (shouldExit == true) {
          final onExit = widget.onExit;
          if (onExit != null) {
            await onExit();
          } else {
            await SystemNavigator.pop(animated: true);
          }
        }
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
