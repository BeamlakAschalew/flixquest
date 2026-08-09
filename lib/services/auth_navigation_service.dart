import 'package:flutter/material.dart';

import 'auth_session_controller.dart';
import 'in_app_messaging_service.dart';

/// Keeps authentication screens from remaining above the app shell after a
/// successful sign in or account creation.
class AuthNavigationService {
  const AuthNavigationService._();

  static Future<void> returnToAppRoot(
    BuildContext context, {
    required String authenticatedUserId,
  }) {
    return _replaceAppRoot(context, userId: authenticatedUserId);
  }

  static Future<void> returnToSignedOutRoot(BuildContext context) {
    return _replaceAppRoot(context, userId: null);
  }

  static Future<void> _replaceAppRoot(
    BuildContext context, {
    required String? userId,
  }) async {
    // Capture the root navigator before yielding because the session rebuild
    // can replace the widget that supplied [context].
    final nearestNavigator = Navigator.maybeOf(context);
    final rootNavigator = InAppMessagingService.navigatorKey.currentState ??
        Navigator.maybeOf(context, rootNavigator: true);

    // Update the root gate synchronously instead of waiting for Firebase's
    // platform stream, which can arrive after the auth route has been popped.
    AuthSessionController.instance.setAuthenticatedUserId(userId);

    // Give UserState a frame to build the authenticated shell before revealing
    // the first route.
    await WidgetsBinding.instance.endOfFrame;

    if (nearestNavigator != null &&
        nearestNavigator != rootNavigator &&
        nearestNavigator.mounted) {
      nearestNavigator.popUntil((route) => route.isFirst);
    }

    if (rootNavigator != null && rootNavigator.mounted) {
      var foundAppRoot = false;
      rootNavigator.popUntil((route) {
        if (route.settings.name == Navigator.defaultRouteName) {
          foundAppRoot = true;
          return true;
        }
        return route.isFirst;
      });

      if (!foundAppRoot) {
        // Older logout flows could replace `/` with a standalone LandingScreen,
        // leaving no UserState gate to react to the next login. Only recreate
        // the root when that corruption is detected; healthy TV roots can
        // contain nested navigator keys that must not be duplicated.
        rootNavigator.pushNamedAndRemoveUntil(
          Navigator.defaultRouteName,
          (_) => false,
        );
      }
    }
  }
}
