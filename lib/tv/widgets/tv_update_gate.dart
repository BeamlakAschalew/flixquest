import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../provider/app_dependency_provider.dart';
import '../../screens/common/update_screen.dart';
import '../../services/app_update_service.dart';
import '../focus/tv_keymap.dart';
import 'tv_loading_skeletons.dart';
import 'tv_update_widgets.dart';

/// Wraps the entire TV navigator so a new mandatory release also blocks routes
/// already open (including playback), rather than only replacing the home page.
class TvUpdateGate extends StatefulWidget {
  const TvUpdateGate({required this.child, super.key});
  final Widget child;

  @override
  State<TvUpdateGate> createState() => _TvUpdateGateState();
}

class _TvUpdateGateState extends State<TvUpdateGate>
    with WidgetsBindingObserver {
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

  @override
  Future<bool> didPopRoute() async {
    if (!_blocking) return false;
    final navigator = _updateNavigatorKey.currentState;
    if (navigator != null) {
      await navigator.maybePop();
    } else {
      await SystemNavigator.pop();
    }
    return true;
  }

  late Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();
  final _updateNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final config = context.watch<AppDependencyProvider>();
    return FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          _blocking = config.isForcedUpdate;
          if (!_blocking) return widget.child;
          if (!snapshot.hasData) {
            return TvKeymap(
                onBack: SystemNavigator.pop,
                child: TvUpdateLayout(
                    title: tr('tv_checking_for_a_required_update'),
                    message: snapshot.hasError
                        ? tr(
                            'tv_unable_to_read_the_installed_version_please_retry')
                        : tr('tv_checking_your_installed_version'),
                    children: [
                      if (snapshot.hasError)
                        TvUpdateAction(
                            label: tr('retry'),
                            autofocus: true,
                            primary: true,
                            onPressed: () => setState(() =>
                                _packageInfo = PackageInfo.fromPlatform()))
                      else
                        const TvUpdateSkeleton(),
                      const SizedBox(height: 16),
                      TvUpdateAction(
                          label: tr('tv_exit_app'),
                          autofocus: !snapshot.hasError,
                          onPressed: SystemNavigator.pop),
                    ]));
          }
          final available = AppUpdateService.isAvailable(
              packageInfo: snapshot.data!,
              remoteVersion: config.latestAppVersion,
              latestBuildNumber: config.latestBuildNumber,
              minimumBuildNumber: config.minimumBuildNumber);
          _blocking = available;
          if (!available) return widget.child;
          return Navigator(
              key: _updateNavigatorKey,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (_) =>
                      const UpdateScreen(isForced: true, television: true)));
        });
  }
}
