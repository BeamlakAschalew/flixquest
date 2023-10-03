import 'package:permission_handler/permission_handler.dart';

String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason | $formattedEpisode";
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.request();
  if (!status.isGranted && !status.isPermanentlyDenied) {
    Permission.notification.request();
  }
}
