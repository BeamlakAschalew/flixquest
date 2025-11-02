import 'package:better_player_plus/better_player_plus.dart';
import 'package:flixquest/models/movie_stream_metadata.dart';
import 'package:flixquest/models/tv_stream_metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../controllers/recently_watched_database_controller.dart';
import '../../../functions/function.dart';
import '../../../models/recently_watched.dart';
import '../../../provider/recently_watched_provider.dart';

class PlayerDataManagement {
  final RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();
  final RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();

  Future<void> insertRecentMovieData({
    required BuildContext context,
    required BetterPlayerController betterPlayerController,
    required int duration,
    required MovieStreamMetadata movieMetadata,
  }) async {
    int elapsed = await betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked =
        await recentlyWatchedMoviesController.contain(movieMetadata.movieId!);
    dynamic prv;
    if (context.mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentMovie rMov = RecentMovie(
        dateTime: dt,
        elapsed: elapsed,
        id: movieMetadata.movieId!,
        posterPath: movieMetadata.posterPath!,
        releaseYear: movieMetadata.releaseYear!,
        remaining: remaining,
        title: movieMetadata.movieName,
        backdropPath: movieMetadata.backdropPath!);

    double percentage = (elapsed / duration) * 100;

    if (!isBookmarked) {
      prv.addMovie(rMov);
    } else {
      if (percentage <= 85) {
        prv.updateMovie(rMov, movieMetadata.movieId!);
      } else {
        prv.deleteMovie(movieMetadata.movieId!);
      }
    }
  }

  Future<void> insertRecentEpisodeData({
    required BuildContext context,
    required BetterPlayerController betterPlayerController,
    required int duration,
    required TVStreamMetadata tvMetadata,
  }) async {
    int elapsed = await betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked =
        await recentlyWatchedEpisodeController.contain(tvMetadata.episodeId!);

    dynamic prv;
    if (context.mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentEpisode rEpisode = RecentEpisode(
        dateTime: dt,
        elapsed: elapsed,
        id: tvMetadata.episodeId!,
        posterPath: tvMetadata.posterPath!,
        remaining: remaining,
        seriesName: tvMetadata.seriesName!,
        episodeName: tvMetadata.episodeName!,
        episodeNum: tvMetadata.episodeNumber!,
        seasonNum: tvMetadata.seasonNumber!,
        seriesId: tvMetadata.tvId!);

    double percentage = (elapsed / duration) * 100;
    if (!isBookmarked) {
      prv.addEpisode(rEpisode);
    } else {
      if (percentage <= 85) {
        prv.updateEpisode(rEpisode, tvMetadata.episodeId!,
            tvMetadata.episodeNumber!, tvMetadata.seasonNumber!);
      } else {
        prv.deleteEpisode(tvMetadata.episodeId!, tvMetadata.episodeNumber!,
            tvMetadata.seasonNumber!);
      }
    }
  }

  /// Handles saving progress and analytics before switching to a new episode/movie
  Future<void> handleContentSwitch({
    required BuildContext context,
    required MediaType mediaType,
    required BetterPlayerController betterPlayerController,
    required int duration,
    required int playbackDurationInSeconds,
    MovieStreamMetadata? movieMetadata,
    TVStreamMetadata? tvMetadata,
  }) async {
    // Save current playback progress
    if (mediaType == MediaType.movie) {
      await insertRecentMovieData(
        context: context,
        betterPlayerController: betterPlayerController,
        duration: duration,
        movieMetadata: movieMetadata!,
      );
    } else {
      await insertRecentEpisodeData(
        context: context,
        betterPlayerController: betterPlayerController,
        duration: duration,
        tvMetadata: tvMetadata!,
      );
    }

    // Send analytics for current viewing session
    updateAndLogTotalStreamingDuration(playbackDurationInSeconds);
  }
}
