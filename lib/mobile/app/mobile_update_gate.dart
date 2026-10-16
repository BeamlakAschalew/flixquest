import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../design/app_palette.dart';
import '../../provider/app_dependency_provider.dart';
import '../../screens/common/update_screen.dart';
import '../../services/app_update_service.dart';

/// Wraps the phone app's navigator so a mandatory update blocks every page,
/// not only Home: a session that started offline learns of the update once a
/// config fetch gets through, by which time a title or the player may be
/// open over Home.
class MobileUpdateGate extends StatefulWidget {
  const MobileUpdateGate({required this.child, super.key});
  final Widget child;

  @override
  State<MobileUpdateGate> createState() => _MobileUpdateGateState();
}

class _MobileUpdateGateState extends State<MobileUpdateGate>
    with WidgetsBindingObserver {
  final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();
  final _updateNavigatorKey = GlobalKey<NavigatorState>();
  bool _blocking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The app's own navigator is gone while blocked, so system Back goes to
  /// the update page, which asks before leaving.
  @override
  Future<bool> didPopRoute() async {
    final navigator = _updateNavigatorKey.currentState;
    if (!_blocking || navigator == null) return false;
    await navigator.maybePop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppDependencyProvider>();
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        _blocking = config.isForcedUpdate &&
            (packageInfo == null ||
                AppUpdateService.isAvailable(
                  packageInfo: packageInfo,
                  remoteVersion: config.latestAppVersion,
                  latestBuildNumber: config.latestBuildNumber,
                  minimumBuildNumber: config.minimumBuildNumber,
                ));
        if (!_blocking) return widget.child;
        // A blank page for the moment the installed version takes to read,
        // rather than a flash of the app. If it can't be read, the gate stays
        // shut and the update page offers a retry.
        if (packageInfo == null && !snapshot.hasError) {
          return ColoredBox(color: AppPalette.of(context).page);
        }
        return Navigator(
          key: _updateNavigatorKey,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => const UpdateScreen(isForced: true),
          ),
        );
      },
    );
  }
}
