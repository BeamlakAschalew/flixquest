class MovieStreamMetadata {
  int? movieId;
  String? movieName;
  int? releaseYear;
  String? posterPath;
  String? backdropPath;
  int? elapsed;
  bool? isAdult;
  String? releaseDate;
  List<MovieRecommendation>? recommendations; // Top 10 recommended movies
  Function(int movieId)? onMovieChange; // Callback to load new movie

  MovieStreamMetadata({
    required this.backdropPath,
    required this.elapsed,
    required this.movieId,
    required this.movieName,
    required this.posterPath,
    required this.releaseYear,
    required this.isAdult,
    required this.releaseDate,
    this.recommendations,
    this.onMovieChange,
  });
}

// Metadata for recommended movies
class MovieRecommendation {
  final int movieId;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final num? voteAverage;
  final String? releaseDate;

  MovieRecommendation({
    required this.movieId,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.voteAverage,
    this.releaseDate,
  });

  factory MovieRecommendation.fromMovie(dynamic movie) {
    return MovieRecommendation(
      movieId: movie.id ?? 0,
      title: movie.title ?? 'Unknown Title',
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      overview: movie.overview,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
    );
  }
}
