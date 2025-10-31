class TVStreamMetadata {
  int? episodeId;
  String? seriesName;
  String? episodeName;
  int? episodeNumber;
  int? seasonNumber;
  String? posterPath;
  int? elapsed;
  int? tvId;
  String? airDate;
  List<EpisodeMetadata>? seasonEpisodes; // List of all episodes in the season

  TVStreamMetadata({
    required this.elapsed,
    required this.episodeId,
    required this.episodeName,
    required this.episodeNumber,
    required this.posterPath,
    required this.seasonNumber,
    required this.seriesName,
    required this.tvId,
    required this.airDate,
    this.seasonEpisodes,
  });
}

// Metadata for each episode in the season
class EpisodeMetadata {
  final int episodeId;
  final String episodeName;
  final int episodeNumber;
  final int seasonNumber;
  final String? stillPath; // Thumbnail
  final String? airDate;
  final int? runtime; // Duration in minutes
  final String? overview;

  EpisodeMetadata({
    required this.episodeId,
    required this.episodeName,
    required this.episodeNumber,
    required this.seasonNumber,
    this.stillPath,
    this.airDate,
    this.runtime,
    this.overview,
  });

  // Factory constructor to create from EpisodeList model
  factory EpisodeMetadata.fromEpisodeList(dynamic episode) {
    return EpisodeMetadata(
      episodeId: episode.episodeId ?? 0,
      episodeName: episode.name ?? 'Episode ${episode.episodeNumber}',
      episodeNumber: episode.episodeNumber ?? 0,
      seasonNumber: episode.seasonNumber ?? 0,
      stillPath: episode.stillPath,
      airDate: episode.airDate,
      runtime: null, // Runtime might not be in EpisodeList
      overview: episode.overview,
    );
  }
}
