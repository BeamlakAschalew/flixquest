enum OfflineDownloadState {
  queued,
  stopped,
  downloading,
  completed,
  failed,
  removing,
  restarting,
  unknown;

  static OfflineDownloadState fromName(String? value) {
    return OfflineDownloadState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => OfflineDownloadState.unknown,
    );
  }
}

class OfflineDownload {
  const OfflineDownload({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.quality,
    required this.state,
    required this.progress,
    required this.bytesDownloaded,
    required this.contentLength,
    required this.createdAt,
    this.networkRateBytesPerSecond = 0,
    this.subtitle,
    this.posterUrl,
    this.error,
    this.contentId,
    this.seasonNumber,
    this.episodeNumber,
    this.offlineSubtitlePath,
    this.offlineSubtitleName,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String mediaType;
  final String quality;
  final OfflineDownloadState state;
  final double progress;
  final int bytesDownloaded;
  final int contentLength;
  final DateTime createdAt;
  final double networkRateBytesPerSecond;
  final String? posterUrl;
  final String? error;
  final int? contentId;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? offlineSubtitlePath;
  final String? offlineSubtitleName;

  bool get isComplete => state == OfflineDownloadState.completed;
  bool get isActive =>
      state == OfflineDownloadState.downloading ||
      state == OfflineDownloadState.queued ||
      state == OfflineDownloadState.restarting;

  bool get totalBytesIsEstimated => contentLength <= 0 && !isComplete;

  int get totalBytes {
    if (contentLength > 0) return contentLength;
    if (isComplete) return bytesDownloaded;
    if (bytesDownloaded > 0 && progress > 0) {
      return (bytesDownloaded * 100 / progress).round();
    }
    return -1;
  }

  OfflineDownload copyWith({double? networkRateBytesPerSecond}) {
    return OfflineDownload(
      id: id,
      title: title,
      mediaType: mediaType,
      quality: quality,
      state: state,
      progress: progress,
      bytesDownloaded: bytesDownloaded,
      contentLength: contentLength,
      createdAt: createdAt,
      networkRateBytesPerSecond:
          networkRateBytesPerSecond ?? this.networkRateBytesPerSecond,
      subtitle: subtitle,
      posterUrl: posterUrl,
      error: error,
      contentId: contentId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      offlineSubtitlePath: offlineSubtitlePath,
      offlineSubtitleName: offlineSubtitleName,
    );
  }

  factory OfflineDownload.fromMap(Map<Object?, Object?> map) {
    T? value<T>(String key) {
      final raw = map[key];
      return raw is T ? raw : null;
    }

    final rawProgress = value<num>('progress')?.toDouble() ?? 0;
    return OfflineDownload(
      id: value<String>('id') ?? '',
      title: value<String>('title') ?? 'Untitled',
      subtitle: value<String>('subtitle'),
      mediaType: value<String>('mediaType') ?? 'video',
      quality: value<String>('quality') ?? 'Auto',
      state: OfflineDownloadState.fromName(value<String>('state')),
      progress: rawProgress.isFinite ? rawProgress.clamp(0, 100) : 0,
      bytesDownloaded: value<num>('bytesDownloaded')?.toInt() ?? 0,
      contentLength: value<num>('contentLength')?.toInt() ?? -1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        value<num>('createdAt')?.toInt() ?? 0,
      ),
      networkRateBytesPerSecond:
          value<num>('networkRateBytesPerSecond')?.toDouble() ?? 0,
      posterUrl: value<String>('posterUrl'),
      error: value<String>('error'),
      contentId: value<num>('contentId')?.toInt(),
      seasonNumber: value<num>('seasonNumber')?.toInt(),
      episodeNumber: value<num>('episodeNumber')?.toInt(),
      offlineSubtitlePath: value<String>('offlineSubtitlePath'),
      offlineSubtitleName: value<String>('offlineSubtitleName'),
    );
  }
}

class OfflineDownloadRequest {
  const OfflineDownloadRequest({
    required this.id,
    required this.url,
    required this.format,
    required this.title,
    required this.mediaType,
    required this.quality,
    this.subtitle,
    this.posterUrl,
    this.maxVideoHeight,
    this.headers = const {},
    this.contentId,
    this.seasonNumber,
    this.episodeNumber,
    this.subtitleTrackUrl,
    this.subtitleTrackName,
    this.subtitleTrackHeaders = const {},
  });

  final String id;
  final String url;
  final String format;
  final String title;
  final String? subtitle;
  final String mediaType;
  final String quality;
  final String? posterUrl;
  final int? maxVideoHeight;
  final Map<String, String> headers;
  final int? contentId;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? subtitleTrackUrl;
  final String? subtitleTrackName;
  final Map<String, String> subtitleTrackHeaders;

  Map<String, Object?> toMap() => {
        'id': id,
        'url': url,
        'format': format,
        'title': title,
        'subtitle': subtitle,
        'mediaType': mediaType,
        'quality': quality,
        'posterUrl': posterUrl,
        'maxVideoHeight': maxVideoHeight,
        'headers': headers,
        'contentId': contentId,
        'seasonNumber': seasonNumber,
        'episodeNumber': episodeNumber,
        'subtitleTrackUrl': subtitleTrackUrl,
        'subtitleTrackName': subtitleTrackName,
        'subtitleTrackHeaders': subtitleTrackHeaders,
      };
}
