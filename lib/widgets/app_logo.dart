import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../provider/app_dependency_provider.dart';

/// Displays the Remote Config logo when available and a bundled asset when it
/// is not. Seasonal theme logos take precedence over the general app logo.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackAsset = 'assets/images/logo.png',
    this.fallbackColor,
  });

  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final logoUrl = context.select<AppDependencyProvider, String>(
      (provider) => provider.effectiveLogoUrl,
    );
    final uri = Uri.tryParse(logoUrl);
    final canLoadRemote = uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    if (!canLoadRemote) return _fallback();

    final path = uri.path.toLowerCase();
    if (path.endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _fallback(),
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: logoUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _fallback(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    if (fallbackAsset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        colorFilter: fallbackColor == null
            ? null
            : ColorFilter.mode(fallbackColor!, BlendMode.srcIn),
      );
    }
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
      color: fallbackColor,
    );
  }
}
