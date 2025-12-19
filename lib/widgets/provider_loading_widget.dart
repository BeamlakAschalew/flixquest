import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/provider_load_state.dart';

class ProviderLoadingWidget extends StatefulWidget {
  final List<ProviderLoadState> providers;
  final int currentIndex;
  final String? additionalMessage;

  const ProviderLoadingWidget({
    required this.providers,
    required this.currentIndex,
    this.additionalMessage,
    super.key,
  });

  @override
  State<ProviderLoadingWidget> createState() => _ProviderLoadingWidgetState();
}

class _ProviderLoadingWidgetState extends State<ProviderLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProviderLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      constraints: const BoxConstraints(
        maxWidth: 440,
        minHeight: 340,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo with elegant glow
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.18),
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  Theme.of(context).colorScheme.primary.withOpacity(0.02),
                ],
              ),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 72,
              width: 72,
            ),
          ),
          const SizedBox(height: 26),

          // Loading text
          Text(
            tr('loading_video_sources'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Figtree',
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),

          // Subtle hint text
          Text(
            tr('finding_best_source'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'Figtree',
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 20),

          // Progress indicator
          SizedBox(
            width: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Provider carousel
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildProviderCarousel(),
          ),

          // Additional message (e.g., subtitle fetching)
          if (widget.additionalMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.additionalMessage!,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                        fontSize: 13,
                        fontFamily: 'Figtree',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderCarousel() {
    final int prevIndex =
        widget.currentIndex > 0 ? widget.currentIndex - 1 : -1;
    final int nextIndex = widget.currentIndex < widget.providers.length - 1
        ? widget.currentIndex + 1
        : -1;

    return Column(
      children: [
        // Previous provider (if exists)
        if (prevIndex >= 0)
          _buildProviderItem(
            widget.providers[prevIndex],
            isPrevious: true,
          ),

        // Current provider
        if (widget.currentIndex < widget.providers.length)
          _buildProviderItem(
            widget.providers[widget.currentIndex],
            isCurrent: true,
          ),

        // Next provider (if exists)
        if (nextIndex >= 0)
          _buildProviderItem(
            widget.providers[nextIndex],
            isNext: true,
          ),
      ],
    );
  }

  Widget _buildProviderItem(
    ProviderLoadState provider, {
    bool isCurrent = false,
    bool isPrevious = false,
    bool isNext = false,
  }) {
    final bool isHighlighted = isCurrent;
    final double opacity = isHighlighted ? 1.0 : 0.55;
    final double fontSize = isHighlighted ? 16.5 : 13.5;
    final double iconSize = isHighlighted ? 23 : 18;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 320,
          padding: EdgeInsets.symmetric(
            horizontal: isHighlighted ? 20 : 16,
            vertical: isHighlighted ? 13 : 10,
          ),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isHighlighted
                ? Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.25),
                    width: 1.2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Status icon
              _buildStatusIcon(provider.status, iconSize),
              const SizedBox(width: 14),

              // Provider name
              Expanded(
                child: Text(
                  provider.fullName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: fontSize,
                    fontWeight:
                        isHighlighted ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'Figtree',
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ProviderStatus status, double iconSize) {
    switch (status) {
      case ProviderStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          size: iconSize,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
        );
      case ProviderStatus.loading:
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      case ProviderStatus.success:
        return Icon(
          Icons.check_circle_rounded,
          size: iconSize,
          color: const Color(0xFF4CAF50),
        );
      case ProviderStatus.failed:
        return Icon(
          Icons.error_rounded,
          size: iconSize,
          color: const Color(0xFFEF5350),
        );
    }
  }
}
