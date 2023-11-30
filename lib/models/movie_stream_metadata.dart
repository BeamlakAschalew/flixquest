class MovieStreamMetadata {
  int? movieId;
  String? movieName;
  int? releaseYear;
  String? posterPath;
  String? backdropPath;
  int? elapsed;

  MovieStreamMetadata(
      {required this.backdropPath,
      required this.elapsed,
      required this.movieId,
      required this.movieName,
      required this.posterPath,
      required this.releaseYear});
}
