import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/movie_stream_metadata.dart';
import '../../movie/movie_video_loader.dart';

class PlayerMovieRecommendations {
  Future<void> loadRecommendedMovie({
    required BuildContext context,
    required int movieId,
    required MovieStreamMetadata movieMetadata,
    required Function() onSaveProgress,
    required Function() closePlayer,
  }) async {
    try {
      // Save progress and analytics for current movie before switching
      onSaveProgress();

      // Find the movie in recommendations to get all its details
      final recommendedMovie = movieMetadata.recommendations
          ?.firstWhere((movie) => movie.movieId == movieId);

      if (recommendedMovie == null) {
        throw Exception('Movie not found in recommendations');
      }

      // Create new movie metadata from the recommendation
      final newMetadata = MovieStreamMetadata(
        movieId: recommendedMovie.movieId,
        movieName: recommendedMovie.title,
        posterPath: recommendedMovie.posterPath,
        backdropPath: recommendedMovie.backdropPath,
        releaseDate: recommendedMovie.releaseDate,
        releaseYear: recommendedMovie.releaseDate != null
            ? DateTime.tryParse(recommendedMovie.releaseDate!)?.year
            : null,
        isAdult: false, // This info is not in recommendations
        elapsed: 0, // New movie, no elapsed time
      );

      // Pop current player, then push new video loader
      // This prevents player stacking while maintaining navigation history
      if (context.mounted) {
        closePlayer();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MovieVideoLoader(
              download: false,
              metadata: newMetadata,
              route: StreamRoute.flixHQ,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to load movie: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                tr('failed_load_movie', namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showMovieRecommendationsBottomSheet({
    required BuildContext context,
    required List<Color> colors,
    required MovieStreamMetadata movieMetadata,
    required Function() onSaveProgress,
    required Function() closePlayer,
  }) {
    if (movieMetadata.recommendations == null ||
        movieMetadata.recommendations!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        snap: true,
        snapSizes: [0.5, 0.7, 0.95],
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Draggable Header
              SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('recommended_movies'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                  ],
                ),
              ),
              // Movie List
              Expanded(
                child: ListView.builder(
                  itemCount: movieMetadata.recommendations!.length,
                  itemBuilder: (context, index) {
                    final movie = movieMetadata.recommendations![index];

                    return InkWell(
                      onTap: () {
                        // Close the bottom sheet
                        Navigator.pop(context);
                        // Load the selected movie
                        loadRecommendedMovie(
                          context: context,
                          movieId: movie.movieId,
                          movieMetadata: movieMetadata,
                          onSaveProgress: onSaveProgress,
                          closePlayer: closePlayer,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Movie poster
                              Container(
                                width: 100,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[800],
                                ),
                                child: movie.posterPath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          cacheManager: cacheProp(),
                                          imageUrl:
                                              'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colors.first,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Center(
                                            child: Icon(
                                              Icons.movie,
                                              color: Colors.grey[600],
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.movie,
                                          color: Colors.grey[600],
                                          size: 40,
                                        ),
                                      ),
                              ),
                              SizedBox(width: 12),
                              // Movie info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'FigtreeSB',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    // Rating and release year row
                                    Row(
                                      children: [
                                        if (movie.voteAverage != null &&
                                            movie.voteAverage! > 0)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  colors.first.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: colors.first,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  '${movie.voteAverage!.toStringAsFixed(1)}/10',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.first,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (movie.voteAverage != null &&
                                            movie.voteAverage! > 0 &&
                                            movie.releaseDate != null)
                                          SizedBox(width: 8),
                                        if (movie.releaseDate != null)
                                          Text(
                                            movie.releaseDate!.split('-')[0],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (movie.overview != null &&
                                        movie.overview!.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          movie.overview!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'Figtree',
                                            color: Colors.grey[500],
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showRecommendedMovieCountdown({
    required BuildContext context,
    required List<Color> colors,
    required MovieStreamMetadata movieMetadata,
    required Function() onSaveProgress,
    required Function() closePlayer,
  }) {
    if (movieMetadata.recommendations == null ||
        movieMetadata.recommendations!.isEmpty) {
      return;
    }

    int selectedIndex = 0; // Track which movie is selected

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentMovie = movieMetadata.recommendations![selectedIndex];

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                tr('recommended_movies'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FigtreeBold',
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie poster and info in a row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Movie poster on the left
                          if (currentMovie.posterPath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                cacheManager: cacheProp(),
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w500${currentMovie.posterPath}',
                                width: 120,
                                height: 180,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 120,
                                  height: 180,
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colors.first,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 120,
                                  height: 180,
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: Colors.grey[600],
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(width: 12),
                          // Movie info on the right
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentMovie.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'FigtreeSB',
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                if (currentMovie.voteAverage != null &&
                                    currentMovie.voteAverage! > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.first.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: colors.first,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            '${currentMovie.voteAverage!.toStringAsFixed(1)}/10',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colors.first,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (currentMovie.overview != null &&
                                    currentMovie.overview!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      currentMovie.overview!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Figtree',
                                        color: Colors.grey[400],
                                      ),
                                      maxLines: 6,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Show other recommendations
                      if (movieMetadata.recommendations!.length > 1) ...[
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),
                        Text(
                          tr('more_recommendations'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'FigtreeSB',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movieMetadata.recommendations!.length,
                            itemBuilder: (context, index) {
                              final movie =
                                  movieMetadata.recommendations![index];
                              final isSelected = index == selectedIndex;

                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 100,
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                            color: colors.first,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: movie.posterPath != null
                                            ? CachedNetworkImage(
                                                cacheManager: cacheProp(),
                                                imageUrl:
                                                    'https://image.tmdb.org/t/p/w185${movie.posterPath}',
                                                height: 130,
                                                width: 100,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  height: 130,
                                                  width: 100,
                                                  color: Colors.grey[800],
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: colors.first,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  height: 130,
                                                  width: 100,
                                                  color: Colors.grey[800],
                                                  child: Icon(
                                                    Icons.movie,
                                                    color: Colors.grey[600],
                                                    size: 30,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 130,
                                                width: 100,
                                                color: Colors.grey[800],
                                                child: Icon(
                                                  Icons.movie,
                                                  color: Colors.grey[600],
                                                  size: 30,
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: 4),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 5.0),
                                          child: Text(
                                            movie.title,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'Figtree',
                                              color: isSelected
                                                  ? colors.first
                                                  : Colors.grey[300],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    tr('cancel'),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Figtree',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Load selected movie immediately
                    if (context.mounted) {
                      final selectedMovie =
                          movieMetadata.recommendations![selectedIndex];
                      loadRecommendedMovie(
                        context: context,
                        movieId: selectedMovie.movieId,
                        movieMetadata: movieMetadata,
                        onSaveProgress: onSaveProgress,
                        closePlayer: closePlayer,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.first,
                  ),
                  child: Text(
                    tr('play_now'),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FigtreeSB',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
