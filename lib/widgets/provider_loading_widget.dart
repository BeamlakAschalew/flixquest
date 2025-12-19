import 'package:flutter/material.dart';
import '../models/provider_load_state.dart';

class ProviderLoadingWidget extends StatefulWidget {
  final List<ProviderLoadState> providers;
  final int currentIndex;

  const ProviderLoadingWidget({
    required this.providers,
    required this.currentIndex,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.onSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(
        maxWidth: 320,
        minHeight: 280,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: 70,
            width: 70,
          ),
          const SizedBox(height: 24),

          // Progress indicator
          SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Provider carousel
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildProviderCarousel(),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCarousel() {
    final int prevIndex = widget.currentIndex > 0 ? widget.currentIndex - 1 : -1;
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
    final double opacity = isHighlighted ? 1.0 : 0.5;
    final double scale = isHighlighted ? 1.0 : 0.85;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        vertical: isHighlighted ? 8 : 4,
      ),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status icon
                _buildStatusIcon(provider.status, isHighlighted),
                const SizedBox(width: 12),

                // Provider name
                Flexible(
                  child: Text(
                    provider.fullName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: isHighlighted ? 16 : 14,
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                      fontFamily: isHighlighted ? 'FigtreeBold' : 'Figtree',
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Show "Failed" badge if failed
                if (provider.status == ProviderStatus.failed)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Failed',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildStatusIcon(ProviderStatus status, bool isHighlighted) {
    switch (status) {
      case ProviderStatus.pending:
        return Icon(
          Icons.more_horiz,
          size: isHighlighted ? 20 : 16,
          color: Colors.grey,
        );
      case ProviderStatus.loading:
        return SizedBox(
          width: isHighlighted ? 20 : 16,
          height: isHighlighted ? 20 : 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      case ProviderStatus.success:
        return Icon(
          Icons.check_circle,
          size: isHighlighted ? 20 : 16,
          color: Colors.green,
        );
      case ProviderStatus.failed:
        return Icon(
          Icons.error_outline,
          size: isHighlighted ? 20 : 16,
          color: Colors.red,
        );
    }
  }
}
