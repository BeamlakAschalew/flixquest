class MovieStreamMetadata {
  int? movieId;
  String? movieName;
  int? releaseYear;
  String? posterPath;
  String? backdropPath;
  int? elapsed;
  bool? isAdult;
  String? releaseDate;

  MovieStreamMetadata(
      {required this.backdropPath,
      required this.elapsed,
      required this.movieId,
      required this.movieName,
      required this.posterPath,
      required this.releaseYear,
      required this.isAdult,
      required this.releaseDate});
}
