String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason | $formattedEpisode";
}
