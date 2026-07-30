import 'package:flutter/material.dart';

import '../focus/tv_focusable.dart';
import '../focus/tv_keymap.dart';

class TvDialogAction {
  const TvDialogAction({
    required this.label,
    required this.onPressed,
    this.autofocus = false,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool autofocus;
  final bool isPrimary;
}

Future<T?> showTvDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<TvDialogAction> actions,
  bool barrierDismissible = false,
  bool autofocusFirstAction = true,
}) {
  assert(actions.isNotEmpty);
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => TvDialog(
      title: title,
      content: content,
      actions: actions,
      autofocusFirstAction: autofocusFirstAction,
    ),
  );
}

class TvDialog extends StatefulWidget {
  const TvDialog({
    required this.title,
    required this.content,
    required this.actions,
    this.autofocusFirstAction = true,
    super.key,
  });

  final String title;
  final Widget content;
  final List<TvDialogAction> actions;
  final bool autofocusFirstAction;

  @override
  State<TvDialog> createState() => _TvDialogState();
}

class _TvDialogState extends State<TvDialog> {
  late final FocusScopeNode _focusScopeNode;

  @override
  void initState() {
    super.initState();
    _focusScopeNode = FocusScopeNode(debugLabel: 'TV dialog');
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasExplicitAutofocus =
        widget.actions.any((action) => action.autofocus);

    return Dialog(
      backgroundColor: colorScheme.surface,
      insetPadding: const EdgeInsets.all(72),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: FocusScope(
          node: _focusScopeNode,
          child: TvKeymap(
            onBack: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: SingleChildScrollView(
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontFamily: 'FigtreeSB',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Figtree',
                        fontSize: 22,
                        height: 1.35,
                      ),
                      child: widget.content,
                    ),
                    const SizedBox(height: 30),
                    FocusTraversalGroup(
                      policy: ReadingOrderTraversalPolicy(),
                      child: Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        children: <Widget>[
                          for (var index = 0;
                              index < widget.actions.length;
                              index++)
                            Builder(
                              builder: (context) {
                                final action = widget.actions[index];
                                return TvFocusable(
                                  semanticLabel: action.label,
                                  autofocus: action.autofocus ||
                                      (widget.autofocusFirstAction &&
                                          !hasExplicitAutofocus &&
                                          index == 0),
                                  onActivate: action.onPressed,
                                  focusScale: 1.03,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: action.isPrimary
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      action.label,
                                      style: TextStyle(
                                        color: action.isPrimary
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
