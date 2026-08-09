import '../../flixquest_main.dart';
import '/screens/common/landing_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/auth_session_controller.dart';
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
    final authSession = AuthSessionController.instance..initialize();
    return AuthStateRouter(
      userIdListenable: authSession.userId,
      builder: (context, isAuthenticated) {
        final previewTvHome =
            devicePresentation == DevicePresentation.television &&
                TvDebugOptions.previewHomeShell;
        return presentationShellFor(
          devicePresentation: devicePresentation,
          isAuthenticated: isAuthenticated || previewTvHome,
        );
      },
    );
  }
}

class AuthStateRouter extends StatelessWidget {
  const AuthStateRouter({
    required this.userIdListenable,
    required this.builder,
    super.key,
  });

  final ValueListenable<String?> userIdListenable;
  final Widget Function(BuildContext context, bool isAuthenticated) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: userIdListenable,
      builder: (context, userId, _) => KeyedSubtree(
        key: ValueKey(userId ?? 'signed-out'),
        child: builder(context, userId != null),
      ),
    );
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
