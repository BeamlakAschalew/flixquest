import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TvBackIntent extends Intent {
  const TvBackIntent();
}

class TvMenuIntent extends Intent {
  const TvMenuIntent();
}

class TvPlayPauseIntent extends Intent {
  const TvPlayPauseIntent();
}

class TvRewindIntent extends Intent {
  const TvRewindIntent();
}

class TvFastForwardIntent extends Intent {
  const TvFastForwardIntent();
}

class TvKeymap extends StatelessWidget {
  const TvKeymap({
    required this.child,
    this.onBack,
    this.onMenu,
    this.onPlayPause,
    this.onRewind,
    this.onFastForward,
    super.key,
  });

  final Widget child;
  final FutureOr<void> Function()? onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onPlayPause;
  final VoidCallback? onRewind;
  final VoidCallback? onFastForward;

  @override
  Widget build(BuildContext context) {
    final backCallback = onBack;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.escape): TvBackIntent(),
        SingleActivator(LogicalKeyboardKey.goBack): TvBackIntent(),
        SingleActivator(LogicalKeyboardKey.browserBack): TvBackIntent(),
        SingleActivator(LogicalKeyboardKey.contextMenu): TvMenuIntent(),
        SingleActivator(LogicalKeyboardKey.mediaPlayPause): TvPlayPauseIntent(),
        SingleActivator(LogicalKeyboardKey.mediaRewind): TvRewindIntent(),
        SingleActivator(LogicalKeyboardKey.mediaFastForward):
            TvFastForwardIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          if (backCallback != null)
            TvBackIntent: CallbackAction<TvBackIntent>(
              onInvoke: (_) {
                unawaited(Future<void>.sync(backCallback));
                return null;
              },
            ),
          if (onMenu != null)
            TvMenuIntent: CallbackAction<TvMenuIntent>(
              onInvoke: (_) {
                onMenu?.call();
                return null;
              },
            ),
          if (onPlayPause != null)
            TvPlayPauseIntent: CallbackAction<TvPlayPauseIntent>(
              onInvoke: (_) {
                onPlayPause?.call();
                return null;
              },
            ),
          if (onRewind != null)
            TvRewindIntent: CallbackAction<TvRewindIntent>(
              onInvoke: (_) {
                onRewind?.call();
                return null;
              },
            ),
          if (onFastForward != null)
            TvFastForwardIntent: CallbackAction<TvFastForwardIntent>(
              onInvoke: (_) {
                onFastForward?.call();
                return null;
              },
            ),
        },
        child: child,
      ),
    );
  }
}
