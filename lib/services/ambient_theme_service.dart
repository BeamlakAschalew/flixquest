import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/api_constants.dart';
import '../functions/function.dart';
import '../provider/app_dependency_provider.dart';
import '../provider/settings_provider.dart';

/// Owns one route's ambient color and restores the previous route's color when
/// disposed. Extraction starts only while Ambient mode is enabled.
class AmbientThemeScopeController {
  AppDependencyProvider? _provider;
  int? _scopeId;
  String? _imageUrl;
  bool _extractionStarted = false;
  bool _disposed = false;

  void attach(BuildContext context, String? imagePath) {
    if (_provider != null) return;
    _provider = Provider.of<AppDependencyProvider>(context, listen: false);
    _scopeId = _provider!.pushAmbientScope();
    _provider!.addListener(_handleProviderChange);

    final normalizedPath = imagePath?.trim().replaceFirst(RegExp(r'^/+'), '');
    if (normalizedPath == null || normalizedPath.isEmpty) return;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final baseUrl = buildImageUrl(
      TMDB_BASE_IMAGE_URL,
      _provider!.tmdbProxy,
      settings.enableProxy,
      context,
    );
    _imageUrl = '${baseUrl}w185/$normalizedPath';
    _handleProviderChange();
  }

  void _handleProviderChange() {
    if (_disposed ||
        _extractionStarted ||
        _provider?.ambientModeEnabled != true ||
        _imageUrl == null) {
      return;
    }
    _extractionStarted = true;
    DominantImageColor.extract(_imageUrl!).then((color) {
      if (_disposed || color == null || _scopeId == null) return;
      _provider?.updateAmbientScope(_scopeId!, color);
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _provider?.removeListener(_handleProviderChange);
    final id = _scopeId;
    if (id != null) _provider?.popAmbientScope(id);
    _provider = null;
  }
}

class DominantImageColor {
  const DominantImageColor._();

  static Future<Color?> extract(String imageUrl) async {
    final completer = Completer<ui.Image?>();
    final stream = CachedNetworkImageProvider(imageUrl).resolve(
      const ImageConfiguration(),
    );
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (_, __) {
        if (!completer.isCompleted) completer.complete(null);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);

    final image = await completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        stream.removeListener(listener);
        return null;
      },
    );
    if (image == null) return null;
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) return null;
    return fromRgba(
      bytes.buffer.asUint8List(),
      width: image.width,
      height: image.height,
    );
  }

  @visibleForTesting
  static Color? fromRgba(
    List<int> rgba, {
    required int width,
    required int height,
  }) {
    if (width <= 0 || height <= 0 || rgba.length < width * height * 4) {
      return null;
    }
    final buckets = <int, _ColorBucket>{};
    final xStep = (width / 48).ceil().clamp(1, width);
    final yStep = (height / 48).ceil().clamp(1, height);

    for (var y = 0; y < height; y += yStep) {
      for (var x = 0; x < width; x += xStep) {
        final offset = (y * width + x) * 4;
        final alpha = rgba[offset + 3];
        if (alpha < 180) continue;
        final red = rgba[offset];
        final green = rgba[offset + 1];
        final blue = rgba[offset + 2];
        final hsl = HSLColor.fromColor(Color.fromARGB(255, red, green, blue));
        // Ignore near-black, near-white, and grey pixels. They usually belong
        // to letterboxing, text, or backgrounds rather than the artwork mood.
        if (hsl.lightness < .08 ||
            hsl.lightness > .92 ||
            hsl.saturation < .12) {
          continue;
        }
        final key = (red >> 5) << 10 | (green >> 5) << 5 | (blue >> 5);
        final bucket = buckets.putIfAbsent(key, _ColorBucket.new);
        final weight = .35 + hsl.saturation * .65;
        bucket
          ..score += weight
          ..red += red
          ..green += green
          ..blue += blue;
        bucket.samples++;
      }
    }
    if (buckets.isEmpty) return null;
    final winner = buckets.values.reduce(
      (a, b) => a.score >= b.score ? a : b,
    );
    final raw = Color.fromARGB(
      255,
      winner.red ~/ winner.samples,
      winner.green ~/ winner.samples,
      winner.blue ~/ winner.samples,
    );
    final hsl = HSLColor.fromColor(raw);
    return hsl
        .withSaturation(hsl.saturation.clamp(.35, .85).toDouble())
        .withLightness(hsl.lightness.clamp(.35, .60).toDouble())
        .toColor();
  }
}

class _ColorBucket {
  double score = 0;
  int red = 0;
  int green = 0;
  int blue = 0;
  int samples = 0;
}
