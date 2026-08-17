enum VideoProviderType {
  directVixSrc,
  scraperApi,
}

class VideoProvider {
  const VideoProvider({
    required this.fullName,
    required this.codeName,
    this.alias,
    this.content,
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

  /// Human-readable catalogue/language coverage supplied by the scraper.
  final String? content;
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
    String? content,
  }) {
    return VideoProvider(
      fullName: name,
      alias: alias,
      content: content,
      codeName: 'scraper:$id',
      type: VideoProviderType.scraperApi,
      apiId: id,
    );
  }
}

/// Applies a persisted provider preference to the providers currently
/// advertised by the backend.
///
/// Missing providers are ignored. Newly advertised providers are inserted at
/// their indexes in the current backend catalog, while providers already in
/// the preference retain their custom relative order. Provider codes, rather
/// than display names, keep the preference stable when names change.
abstract final class VideoProviderOrder {
  static List<VideoProvider> apply(
    Iterable<VideoProvider> availableProviders,
    Iterable<String> preferredCodes,
  ) {
    // Materialize a de-duplicated catalog first so a malformed duplicate API
    // entry cannot shift the insertion index of providers that follow it.
    final catalog = <VideoProvider>[];
    final remaining = <String, VideoProvider>{};
    for (final provider in availableProviders) {
      if (!remaining.containsKey(provider.codeName)) {
        catalog.add(provider);
        remaining[provider.codeName] = provider;
      }
    }

    final ordered = <VideoProvider>[];
    for (final code in preferredCodes) {
      final provider = remaining.remove(code);
      if (provider != null) ordered.add(provider);
    }

    // Anything left was not known when the preference was saved. Place each
    // such provider at its API index instead of demoting it behind the user's
    // entire custom order. Increasing catalog indexes also preserve API order
    // when several providers are introduced at once.
    for (var catalogIndex = 0; catalogIndex < catalog.length; catalogIndex++) {
      final provider = catalog[catalogIndex];
      if (remaining.remove(provider.codeName) == null) continue;

      final insertionIndex =
          catalogIndex < ordered.length ? catalogIndex : ordered.length;
      ordered.insert(insertionIndex, provider);
    }
    return ordered;
  }
}
