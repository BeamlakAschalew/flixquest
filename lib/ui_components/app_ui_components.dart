import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shared responsive and visual primitives for the refreshed FlixQuest UI.
abstract final class AppUI {
  static const double phonePadding = 20;
  static const double tabletPadding = 28;
  static const double contentMaxWidth = 1180;
  static const double cardRadius = 14;
  static const double mediaGridCrossAxisSpacing = 12;
  static const double mediaGridTitleGap = 9;
  static const double mediaGridTitleHeight = 36;
  static const double posterAspectRatio = 2 / 3;

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

  /// Sizes a grid tile around a true 2:3 poster plus its title area.
  static double mediaGridChildAspectRatio(BuildContext context) {
    final columns = mediaGridColumns(context);
    final gridWidth = MediaQuery.sizeOf(context).width -
        (pagePadding(context) * 2) -
        (mediaGridCrossAxisSpacing * (columns - 1));
    final itemWidth = gridWidth / columns;
    final itemHeight = (itemWidth / posterAspectRatio) +
        mediaGridTitleGap +
        mediaGridTitleHeight;
    return itemWidth / itemHeight;
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

/// The shared tonal transition between detail-page artwork and its content.
///
/// Keep the stops here so movie, TV, season, and episode pages always blend in
/// exactly the same way. The small intermediate steps avoid a visible dark
/// band while retaining enough contrast for artwork and carousel indicators.
class AppDetailHeroGradient extends StatelessWidget {
  const AppDetailHeroGradient({super.key});

  static const List<double> stops = <double>[0, .38, .67, .84, 1];
  static const List<Color> colors = <Color>[
    Color(0x30000000),
    Color(0x08000000),
    Color(0x12000000),
    Color(0x68000000),
    Color(0xD9000000),
  ];

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: stops,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

/// A richer, compact entry point for the horizontally browsable genre rails.
class AppGenreTile extends StatelessWidget {
  const AppGenreTile({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh.withValues(alpha: .78),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: .55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontFamily: 'FigtreeSB',
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colors.onSurfaceVariant.withValues(alpha: .75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A user-draggable, auto-advancing media pager for detail-page artwork.
class AppSwipeCarousel extends StatefulWidget {
  const AppSwipeCarousel({
    required this.itemCount,
    required this.itemBuilder,
    this.interval = const Duration(seconds: 6),
    this.indicatorBottom = 16,
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration interval;
  final double indicatorBottom;

  @override
  State<AppSwipeCarousel> createState() => _AppSwipeCarouselState();
}

class _AppSwipeCarouselState extends State<AppSwipeCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant AppSwipeCarousel oldWidget) {
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
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % widget.itemCount,
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) return const SizedBox.shrink();
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.itemCount,
          pageSnapping: true,
          allowImplicitScrolling: true,
          physics: const PageScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          onPageChanged: (index) {
            setState(() => _index = index);
            _restartTimer();
          },
          itemBuilder: widget.itemBuilder,
        ),
        if (widget.itemCount > 1)
          PositionedDirectional(
            end: 16,
            bottom: widget.indicatorBottom,
            child: IgnorePointer(
              child: Row(
                children: List.generate(
                  widget.itemCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: index == _index ? 18 : 5,
                    height: 5,
                    margin: const EdgeInsetsDirectional.only(start: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: index == _index ? .95 : .45,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
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
    required this.onSearchPressed,
    super.key,
  });

  final String title;
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
          childAspectRatio: AppUI.mediaGridChildAspectRatio(context),
          crossAxisSpacing: AppUI.mediaGridCrossAxisSpacing,
          mainAxisSpacing: 16,
        ),
        itemCount: AppUI.mediaGridColumns(context) * 4,
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: AppUI.posterAspectRatio,
              child: _ShimmerBlock(
                width: double.infinity,
                height: double.infinity,
                color: base,
                radius: AppUI.cardRadius,
              ),
            ),
            const SizedBox(height: AppUI.mediaGridTitleGap),
            SizedBox(
              height: AppUI.mediaGridTitleHeight,
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: .84,
                    child: _ShimmerBlock(
                      width: double.infinity,
                      height: 13,
                      color: base,
                    ),
                  ),
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

class AppMediaListCard extends StatelessWidget {
  const AppMediaListCard({
    required this.poster,
    required this.title,
    required this.onTap,
    this.date,
    this.language,
    this.overview,
    this.rating,
    this.voteCount,
    super.key,
  });

  final Widget poster;
  final String title;
  final VoidCallback onTap;
  final String? date;
  final String? language;
  final String? overview;
  final num? rating;
  final int? voteCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final posterWidth = wide ? 112.0 : 96.0;
    final posterHeight = posterWidth * 1.5;
    final year =
        date != null && date!.length >= 4 ? date!.substring(0, 4) : null;
    final summary = overview?.trim() ?? '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: posterHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: posterWidth, height: posterHeight, child: poster),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                        ),
                        if (year != null ||
                            (language?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 7,
                            runSpacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (year != null)
                                Text(year,
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant)),
                              if (year != null &&
                                  (language?.isNotEmpty ?? false))
                                Text('•',
                                    style: TextStyle(color: colors.outline)),
                              if (language?.isNotEmpty ?? false)
                                Text(
                                  language!.toUpperCase(),
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .5,
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 9),
                          Expanded(
                            child: Text(
                              summary,
                              maxLines: wide ? 4 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ] else
                          const Spacer(),
                        Row(
                          children: [
                            AppRatingBadge(rating: rating, compact: true),
                            if (voteCount != null) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.people_outline_rounded,
                                  size: 15, color: colors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                _compactCount(voteCount!),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded,
                                color: colors.onSurfaceVariant),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _compactCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}K';
    }
    return value.toString();
  }
}

class AppMediaListShimmer extends StatelessWidget {
  const AppMediaListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF202124) : const Color(0xFFE7E7E9);
    final highlight = dark ? const Color(0xFF303236) : const Color(0xFFF5F5F6);
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final posterWidth = wide ? 112.0 : 96.0;
    final posterHeight = posterWidth * 1.5;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          AppUI.pagePadding(context),
          12,
          AppUI.pagePadding(context),
          24,
        ),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: posterHeight,
              child: Row(
                children: [
                  _ShimmerBlock(
                      width: posterWidth,
                      height: posterHeight,
                      color: base,
                      radius: 12),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        _ShimmerBlock(width: 190, height: 17, color: base),
                        const SizedBox(height: 9),
                        _ShimmerBlock(width: 88, height: 11, color: base),
                        const SizedBox(height: 13),
                        _ShimmerBlock(
                            width: double.infinity, height: 10, color: base),
                        const SizedBox(height: 7),
                        _ShimmerBlock(
                            width: double.infinity, height: 10, color: base),
                        const SizedBox(height: 7),
                        _ShimmerBlock(width: 140, height: 10, color: base),
                        const Spacer(),
                        _ShimmerBlock(
                            width: 54, height: 24, color: base, radius: 7),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      baseColor: dark ? const Color(0xFF30343A) : const Color(0xFFE9EBEF),
      highlightColor: dark ? const Color(0xFF444950) : const Color(0xFFFAFAFB),
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
