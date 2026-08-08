import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../ui_components/app_ui_components.dart';

class PlayerSheetScaffold extends StatelessWidget {
  const PlayerSheetScaffold({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.footer,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppResponsiveContent(
      maxWidth: 760,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colors.primary),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          Expanded(child: child),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class PlayerChoiceCard extends StatelessWidget {
  const PlayerChoiceCard({
    required this.title,
    required this.onTap,
    this.thumbnail,
    this.subtitle,
    this.description,
    this.selected = false,
    this.progress,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? thumbnail;
  final String? subtitle;
  final String? description;
  final bool selected;
  final double? progress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color:
          selected ? colors.primary.withValues(alpha: .1) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (thumbnail != null) ...[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    thumbnail!,
                    if (progress != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(11),
                          ),
                          child: LinearProgressIndicator(
                            value: progress!.clamp(0, 1),
                            minHeight: 4,
                            backgroundColor:
                                colors.surface.withValues(alpha: .65),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 13),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontFamily: 'FigtreeSB',
                            color: selected ? colors.primary : null,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                    if (description?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  Icon(
                    selected
                        ? PhosphorIcons.checkCircle(
                            PhosphorIconsStyle.fill,
                          )
                        : PhosphorIcons.caretRight(),
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerSheetFooter extends StatelessWidget {
  const PlayerSheetFooter({
    required this.label,
    required this.actionLabel,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton(
                onPressed: onPressed,
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerThumbnail extends StatelessWidget {
  const PlayerThumbnail({
    required this.child,
    this.width = 112,
    this.height = 70,
    super.key,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}
