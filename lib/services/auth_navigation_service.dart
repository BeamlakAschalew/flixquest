import 'package:flutter/material.dart';

import 'in_app_messaging_service.dart';

/// Keeps authentication screens from remaining above the app shell after a
/// successful sign in or account creation.
class AuthNavigationService {
  const AuthNavigationService._();

  static Future<void> returnToAppRoot(BuildContext context) async {
    // Capture the navigators before yielding because an auth-state rebuild can
    // replace the widget that supplied [context]. Most screens use the root
    // navigator, while capturing the nearest navigator also makes the cleanup
    // safe if an auth screen is ever presented inside a nested flow.
    final nearestNavigator = Navigator.maybeOf(context);
    final rootNavigator = Navigator.maybeOf(context, rootNavigator: true);

    // Let UserState consume Firebase's auth event and build the authenticated
    // shell before revealing the first route.
    await WidgetsBinding.instance.endOfFrame;

    final navigators = <NavigatorState>{
      if (nearestNavigator != null) nearestNavigator,
      if (rootNavigator != null) rootNavigator,
      if (InAppMessagingService.navigatorKey.currentState case final navigator?)
        navigator,
    };

    for (final navigator in navigators) {
      if (navigator.mounted) {
        navigator.popUntil((route) => route.isFirst);
      }
    }
  }
}
