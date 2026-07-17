import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shared responsive and visual primitives for the refreshed FlixQuest UI.
abstract final class AppUI {
  static const double phonePadding = 20;
  static const double tabletPadding = 28;
  static const double contentMaxWidth = 1180;
  static const double cardRadius = 14;

  static double pagePadding(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 700
        ? tabletPadding
        : phonePadding;
  }

  static int mediaGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 650) return 4;
    return 3;
  }

  static double horizontalCardWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 118;
    if (width >= 650) return 108;
    return ((width - (pagePadding(context) * 2) - 30) / 4).clamp(72.0, 100.0);
  }
}

class AppCrossfadeCarousel extends StatefulWidget {
  const AppCrossfadeCarousel({
    required this.itemCount,
    required this.itemBuilder,
    this.interval = const Duration(seconds: 7),
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration interval;

  @override
  State<AppCrossfadeCarousel> createState() => _AppCrossfadeCarouselState();
}

class _AppCrossfadeCarouselState extends State<AppCrossfadeCarousel> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant AppCrossfadeCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.itemCount) _index = 0;
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.interval != widget.interval) {
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.itemCount <= 1) return;
    _timer = Timer.periodic(widget.interval, (_) => _advance(1));
  }

  void _advance(int direction) {
    if (!mounted || widget.itemCount <= 1) return;
    setState(() {
      _index = (_index + direction) % widget.itemCount;
      if (_index < 0) _index = widget.itemCount - 1;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 120) return;
        _advance(velocity < 0 ? 1 : -1);
        _restartTimer();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 850),
        reverseDuration: const Duration(milliseconds: 650),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild
          ],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.025, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: widget.itemBuilder(context, _index),
        ),
      ),
    );
  }
}

class AppFeedOverlayHeader extends StatelessWidget {
  const AppFeedOverlayHeader({
    required this.title,
    required this.onMenuPressed,
    required this.onSearchPressed,
    super.key,
  });

  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: .12),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppUI.pagePadding(context) - 8,
              right: 8,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                  onPressed: onMenuPressed,
                  icon: const Icon(Icons.menu_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onSearchPressed,
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppResponsiveContent extends StatelessWidget {
  const AppResponsiveContent({
    required this.child,
    this.padding,
    this.maxWidth = AppUI.contentMaxWidth,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(horizontal: AppUI.pagePadding(context)),
          child: child,
        ),
      ),
    );
  }
}

class AppFormSurface extends StatelessWidget {
  const AppFormSurface({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.danger = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = danger ? colors.error : colors.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: AppResponsiveContent(
        maxWidth: 560,
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 32, color: accent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppFilterSection extends StatelessWidget {
  const AppFilterSection({
    required this.title,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class AppFilterPill extends StatelessWidget {
  const AppFilterPill({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary, width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? colors.onPrimary : colors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class AppFilterRail extends StatelessWidget {
  const AppFilterRail({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class AppFilterActions extends StatelessWidget {
  const AppFilterActions({
    required this.onReset,
    required this.onApply,
    required this.resetLabel,
    required this.applyLabel,
    super.key,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;
  final String resetLabel;
  final String applyLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              FilledButton.tonal(onPressed: onReset, child: Text(resetLabel)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(onPressed: onApply, child: Text(applyLabel)),
        ),
      ],
    );
  }
}

class AppRatingBadge extends StatelessWidget {
  const AppRatingBadge({required this.rating, this.compact = false, super.key});

  final num? rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = rating == null
        ? '—'
        : rating! % 1 == 0
            ? rating!.toInt().toString()
            : rating!.toStringAsFixed(1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(compact ? 7 : 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 4 : 5,
        ),
        child: Text(
          value,
          style: TextStyle(
            color: colors.onPrimary,
            fontFamily: 'FigtreeSB',
            fontSize: compact ? 11 : 12,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppUI.pagePadding(context), 24, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'FigtreeSB',
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class AppHeroShimmer extends StatelessWidget {
  const AppHeroShimmer({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF202124) : const Color(0xFFE7E7E9);
    final highlight = dark ? const Color(0xFF303236) : const Color(0xFFF5F5F6);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: base),
          Positioned(
            left: AppUI.phonePadding,
            right: AppUI.phonePadding,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBlock(width: 210, height: 30, color: base),
                const SizedBox(height: 10),
                _ShimmerBlock(width: 150, height: 14, color: base),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _ShimmerBlock(width: 112, height: 44, color: base),
                    const SizedBox(width: 12),
                    _ShimmerBlock(width: 112, height: 44, color: base),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppMediaRowShimmer extends StatelessWidget {
  const AppMediaRowShimmer({this.itemWidth, super.key});

  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF202124) : const Color(0xFFE7E7E9);
    final highlight = dark ? const Color(0xFF303236) : const Color(0xFFF5F5F6);
    final cardWidth = itemWidth ?? AppUI.horizontalCardWidth(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppUI.pagePadding(context)),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: _ShimmerBlock(
                  width: cardWidth,
                  height: double.infinity,
                  color: base,
                  radius: AppUI.cardRadius,
                ),
              ),
              const SizedBox(height: 10),
              _ShimmerBlock(width: cardWidth * .82, height: 13, color: base),
              const SizedBox(height: 6),
              _ShimmerBlock(width: cardWidth * .55, height: 11, color: base),
            ],
          ),
        ),
      ),
    );
  }
}

class AppMediaGridShimmer extends StatelessWidget {
  const AppMediaGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF202124) : const Color(0xFFE7E7E9);
    final highlight = dark ? const Color(0xFF303236) : const Color(0xFFF5F5F6);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(
            AppUI.pagePadding(context), 12, AppUI.pagePadding(context), 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppUI.mediaGridColumns(context),
          childAspectRatio: .58,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: AppUI.mediaGridColumns(context) * 4,
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: _ShimmerBlock(
                width: double.infinity,
                height: double.infinity,
                color: base,
                radius: AppUI.cardRadius,
              ),
            ),
            const SizedBox(height: 9),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _ShimmerBlock(
                      width: double.infinity, height: 13, color: base),
                  const SizedBox(height: 6),
                  _ShimmerBlock(width: 54, height: 11, color: base),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.movie_filter_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppResponsiveContent(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .09),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 52, color: colors.primary),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontFamily: 'FigtreeSB',
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
              if (action != null) ...[const SizedBox(height: 22), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class AppInfoPill extends StatelessWidget {
  const AppInfoPill({
    required this.icon,
    required this.value,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 7),
          Text(value, style: const TextStyle(fontFamily: 'FigtreeSB')),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// A self-contained shimmer placeholder that can fill any constrained space.
class AppShimmerBlock extends StatelessWidget {
  const AppShimmerBlock({this.radius = 14, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: dark ? const Color(0xFF202124) : const Color(0xFFE7E7E9),
      highlightColor: dark ? const Color(0xFF303236) : const Color(0xFFF7F7F8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
