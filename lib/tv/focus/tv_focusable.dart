import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvFocusable extends StatefulWidget {
  const TvFocusable({
    required this.child,
    required this.onActivate,
    required this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.selected = false,
    this.onFocusChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusScale = 1.04,
    this.focusColor,
    this.padding = EdgeInsets.zero,
    this.onKeyEvent,
    super.key,
  });

  final Widget child;
  final VoidCallback onActivate;
  final String semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final bool selected;
  final ValueChanged<bool>? onFocusChanged;
  final BorderRadius borderRadius;
  final double focusScale;
  final Color? focusColor;
  final EdgeInsetsGeometry padding;
  final KeyEventResult Function(FocusNode node, KeyEvent event)? onKeyEvent;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  FocusNode? _ownedFocusNode;
  bool _hasFocus = false;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _ownedFocusNode = FocusNode(debugLabel: widget.semanticLabel);
    }
  }

  @override
  void didUpdateWidget(TvFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) {
      return;
    }

    if (oldWidget.focusNode == null) {
      _ownedFocusNode?.dispose();
      _ownedFocusNode = null;
    }
    if (widget.focusNode == null) {
      _ownedFocusNode = FocusNode(debugLabel: widget.semanticLabel);
    }
  }

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChanged(bool hasFocus) {
    if (_hasFocus != hasFocus) {
      setState(() => _hasFocus = hasFocus);
    }
    widget.onFocusChanged?.call(hasFocus);
    if (hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: 0.45,
            alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFocusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.primary;
    final focusable = Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      enabled: widget.enabled,
      selected: widget.selected,
      focusable: widget.enabled,
      focused: _hasFocus,
      label: widget.semanticLabel,
      onTap: widget.enabled ? widget.onActivate : null,
      child: FocusableActionDetector(
        enabled: widget.enabled,
        includeFocusSemantics: false,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onFocusChange: _handleFocusChanged,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onActivate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? widget.onActivate : null,
          child: AnimatedScale(
            scale: _hasFocus ? widget.focusScale : 1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: Border.all(
                  color: _hasFocus ? effectiveFocusColor : Colors.transparent,
                  width: 3,
                ),
                boxShadow: _hasFocus
                    ? <BoxShadow>[
                        BoxShadow(
                          color: effectiveFocusColor.withValues(alpha: 0.28),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
    final onKeyEvent = widget.onKeyEvent;
    if (onKeyEvent == null) return focusable;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: onKeyEvent,
      child: focusable,
    );
  }
}
