class TVStreamMetadata {
  int? episodeId;
  String? seriesName;
  String? episodeName;
  int? episodeNumber;
  int? seasonNumber;
  String? posterPath;
  int? elapsed;
  int? tvId;

  TVStreamMetadata(
      {required this.elapsed,
      required this.episodeId,
      required this.episodeName,
      required this.episodeNumber,
      required this.posterPath,
      required this.seasonNumber,
      required this.seriesName,
      required this.tvId});
}
