enum VideoProviderType {
  directVixSrc,
  scraperApi,
}

class VideoProvider {
  const VideoProvider({
    required this.fullName,
    required this.codeName,
    this.alias,
    this.type = VideoProviderType.directVixSrc,
    this.apiId,
  });

  /// Provider name supplied by the service. This is kept for diagnostics.
  final String fullName;

  /// A unique in-app identifier. Scraper IDs are namespaced so they cannot
  /// collide with a direct provider that has the same upstream ID.
  final String codeName;

  /// User-facing name supplied by the scraper API.
  final String? alias;
  final VideoProviderType type;
  final String? apiId;

  String get displayName {
    final value = alias?.trim();
    return value == null || value.isEmpty ? fullName : value;
  }

  static const directVixSrc = VideoProvider(
    fullName: 'VixSrc',
    alias: 'VixSrc Direct',
    codeName: 'direct:vixsrc',
    type: VideoProviderType.directVixSrc,
    apiId: 'vixsrc',
  );

  factory VideoProvider.scraper({
    required String id,
    required String name,
    String? alias,
  }) {
    return VideoProvider(
      fullName: name,
      alias: alias,
      codeName: 'scraper:$id',
      type: VideoProviderType.scraperApi,
      apiId: id,
    );
  }
}

/// Applies a persisted provider preference to the providers currently
/// advertised by the backend.
///
/// Missing providers are ignored and newly advertised providers are appended
/// in backend order. Provider codes, rather than display names or list indexes,
/// keep the preference stable when names change or the catalog is updated.
abstract final class VideoProviderOrder {
  static List<VideoProvider> apply(
    Iterable<VideoProvider> availableProviders,
    Iterable<String> preferredCodes,
  ) {
    final remaining = <String, VideoProvider>{};
    for (final provider in availableProviders) {
      remaining.putIfAbsent(provider.codeName, () => provider);
    }

    final ordered = <VideoProvider>[];
    for (final code in preferredCodes) {
      final provider = remaining.remove(code);
      if (provider != null) ordered.add(provider);
    }
    ordered.addAll(remaining.values);
    return ordered;
  }
}
