import 'package:easy_localization/easy_localization.dart';
import '../../flixquest_main.dart';
import '/screens/common/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../tv/app/tv_home_shell.dart';
import '../../tv/platform/device_presentation.dart';
import '../../tv/platform/tv_debug_options.dart';
import '../../tv/screens/tv_landing_screen.dart';

class UserState extends StatelessWidget {
  const UserState({
    required this.devicePresentation,
    super.key,
  });

  final DevicePresentation devicePresentation;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (userSnapshot.connectionState == ConnectionState.active) {
            final previewTvHome =
                devicePresentation == DevicePresentation.television &&
                    TvDebugOptions.previewHomeShell;
            return presentationShellFor(
              devicePresentation: devicePresentation,
              isAuthenticated: userSnapshot.hasData || previewTvHome,
            );
          } else {
            return Center(
              child: Text(tr('error_occured')),
            );
          }
        });
  }
}

Widget presentationShellFor({
  required DevicePresentation devicePresentation,
  required bool isAuthenticated,
}) {
  return switch ((devicePresentation, isAuthenticated)) {
    (DevicePresentation.television, true) => const TvHomeShell(),
    (DevicePresentation.television, false) => const TvLandingScreen(),
    (DevicePresentation.handheld, true) => const FlixQuestHomePage(),
    (DevicePresentation.handheld, false) => const LandingScreen(),
  };
}
