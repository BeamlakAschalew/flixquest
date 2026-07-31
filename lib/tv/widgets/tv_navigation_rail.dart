import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/tv_design.dart';
import '../focus/tv_focus_memory.dart';
import '../focus/tv_focusable.dart';

class TvNavigationDestination {
  const TvNavigationDestination({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

class TvNavigationRail extends StatefulWidget {
  const TvNavigationRail({
    required this.destinations,
    required this.selectedId,
    required this.onDestinationSelected,
    required this.metrics,
    this.autofocusId,
    super.key,
  });

  final List<TvNavigationDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final TvShellMetrics metrics;
  final String? autofocusId;

  @override
  State<TvNavigationRail> createState() => TvNavigationRailState();
}

class TvNavigationRailState extends State<TvNavigationRail> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};

  @override
  void initState() {
    super.initState();
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(TvNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFocusNodes();
  }

  void _syncFocusNodes() {
    final ids = widget.destinations.map((item) => item.id).toSet();
    assert(
      ids.length == widget.destinations.length,
      'TV navigation destination IDs must be unique.',
    );
    for (final destination in widget.destinations) {
      _focusNodes.putIfAbsent(
        destination.id,
        () => FocusNode(debugLabel: 'TV nav ${destination.label}'),
      );
    }
    final removedIds =
        _focusNodes.keys.where((id) => !ids.contains(id)).toList();
    for (final id in removedIds) {
      _focusNodes.remove(id)?.dispose();
    }
  }

  void requestFocus(String destinationId) {
    _focusNodes[destinationId]?.requestFocus();
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
    final initialFocusId =
        memory?.recall('tv-navigation') ?? widget.autofocusId;
    final colors = Theme.of(context).colorScheme;

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Container(
        width: widget.metrics.railWidth,
        decoration: BoxDecoration(
          color: TvDesign.surfaceFor(context, emphasis: 0.015),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            color: colors.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.metrics.compact ? 9 : 13,
          vertical: widget.metrics.compact ? 12 : 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.metrics.compact ? 13 : 10,
                0,
                widget.metrics.compact ? 13 : 10,
                widget.metrics.compact ? 10 : 18,
              ),
              child: widget.metrics.compact
                  ? SvgPicture.asset(
                      'assets/images/fq_svg.svg',
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        colors.primary,
                        BlendMode.srcIn,
                      ),
                    )
                  : Text(
                      'FLIXQUEST',
                      style: TextStyle(
                        color: colors.primary,
                        fontFamily: 'FigtreeSB',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final destination in widget.destinations) ...<Widget>[
                    TvFocusable(
                      focusNode: _focusNodes[destination.id],
                      autofocus: destination.id == initialFocusId,
                      selected: destination.id == widget.selectedId,
                      semanticLabel: destination.label,
                      onFocusChanged: (hasFocus) {
                        if (hasFocus) {
                          memory?.remember(
                            scopeId: 'tv-navigation',
                            itemId: destination.id,
                          );
                        }
                      },
                      onActivate: () =>
                          widget.onDestinationSelected(destination.id),
                      focusScale: 1.015,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: Container(
                        height: widget.metrics.navItemHeight,
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.metrics.compact ? 0 : 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: destination.id == widget.selectedId
                              ? LinearGradient(
                                  colors: <Color>[
                                    colors.primary.withValues(alpha: 0.2),
                                    colors.primary.withValues(alpha: 0.08),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Stack(
                          children: <Widget>[
                            if (destination.id == widget.selectedId)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: widget.metrics.compact
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  destination.id == widget.selectedId
                                      ? destination.selectedIcon ??
                                          destination.icon
                                      : destination.icon,
                                  color: destination.id == widget.selectedId
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                  size: widget.metrics.compact ? 25 : 26,
                                ),
                                if (!widget.metrics.compact) ...<Widget>[
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      destination.label,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            destination.id == widget.selectedId
                                                ? colors.onSurface
                                                : colors.onSurfaceVariant,
                                        fontFamily:
                                            destination.id == widget.selectedId
                                                ? 'FigtreeSB'
                                                : 'Figtree',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: widget.metrics.navItemGap),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
