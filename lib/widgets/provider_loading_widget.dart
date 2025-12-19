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
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(
        maxWidth: 400,
        minHeight: 340,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 80,
              width: 80,
            ),
          ),
          const SizedBox(height: 28),

          // Loading text
          Text(
            'Loading Video Sources',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'FigtreeBold',
            ),
          ),
          const SizedBox(height: 20),

          // Progress indicator
          SizedBox(
            width: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
    final double opacity = isHighlighted ? 1.0 : 0.65;
    final double fontSize = isHighlighted ? 17 : 14;
    final double iconSize = isHighlighted ? 24 : 18;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 280,
          padding: EdgeInsets.symmetric(
            horizontal: isHighlighted ? 20 : 16,
            vertical: isHighlighted ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status icon
              _buildStatusIcon(provider.status, iconSize),
              const SizedBox(width: 12),

              // Provider name
              Expanded(
                child: Text(
                  provider.fullName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: fontSize,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.w500,
                    fontFamily: isHighlighted ? 'FigtreeBold' : 'FigtreeMedium',
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
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.schedule,
            size: iconSize,
            color: Colors.grey[400],
          ),
        );
      case ProviderStatus.loading:
        return SizedBox(
          width: iconSize + 4,
          height: iconSize + 4,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      case ProviderStatus.success:
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: iconSize,
            color: Colors.green[400],
          ),
        );
      case ProviderStatus.failed:
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error,
            size: iconSize,
            color: Colors.red[400],
          ),
        );
    }
  }
}
