import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/adsterra_playback_ads_config.dart';
import '../provider/app_dependency_provider.dart';
import '../widgets/adsterra_playback_ad_screen.dart';
import 'device_presentation_service.dart';
import 'playback_ad_input_service.dart';

export '../widgets/adsterra_playback_ad_screen.dart' show PlaybackAdPreload;

/// One coordinator for every playback entry point, phone and TV. Skipped or
/// failed ads continue immediately; an overlapping request never starts
/// another loader. TV shows only a stream-found `tv_popunder`, from its own
/// network and interval. Phones may also show popups for the triggers in
/// [PlaybackAdStage.triggers], each with its own switch and interval.
class AdsterraPlaybackAdsService {
  AdsterraPlaybackAdsService({
    Future<SharedPreferences> Function()? preferences,
    this.storeLauncher,
    this.continueTap,
    DateTime Function()? now,
  })  : _preferences = preferences ?? SharedPreferences.getInstance,
        _now = now ?? DateTime.now;
  static final instance = AdsterraPlaybackAdsService();
  static String _lastPopupShownKey(PlaybackAdStage stage) =>
      stage == PlaybackAdStage.streamFound
          ? 'playback_ads.last_popup_shown_at'
          : 'playback_ads.last_${stage.triggerKey}_popup_shown_at';

  final Future<SharedPreferences> Function() _preferences;
  final DateTime Function() _now;
  final StoreLauncher? storeLauncher;
  final PlaybackContinueTap? continueTap;
  final Map<String, int> _rotation = {};
  final Map<PlaybackAdStage, DateTime> _lastPopupShownAt = {};
  bool _busy = false;

  /// Lets route builders omit the waiting frame when no interstitial can run.
  bool needsBeforeLoader(BuildContext context, {bool television = false}) =>
      _eligible(context, television: television) &&
      context
              .read<AppDependencyProvider?>()
              ?.adsterraPlaybackAds
              .forStage(PlaybackAdStage.beforeLoader) !=
          null;

  bool _eligible(BuildContext context,
      {bool download = false, bool television = false}) {
    final state = WidgetsBinding.instance.lifecycleState;
    return context.mounted &&
        (state == null || state == AppLifecycleState.resumed) &&
        !download &&
        !television &&
        !DevicePresentationService.instance.isTelevision &&
        !kIsWeb &&
        const {TargetPlatform.android, TargetPlatform.iOS}
            .contains(defaultTargetPlatform);
  }

  Future<bool> beforeLoader(BuildContext context,
          {bool download = false, bool television = false}) =>
      show(context, PlaybackAdStage.beforeLoader,
          download: download, television: television);

  /// A loader the player itself started passes [PlaybackAdStage.episodeSwitch]
  /// or [PlaybackAdStage.movieSwitch] as [stage].
  Future<bool> streamFound(BuildContext context,
          {bool download = false,
          bool television = false,
          PlaybackAdPreload? preload,
          PlaybackAdStage stage = PlaybackAdStage.streamFound}) =>
      show(context, stage,
          download: download, television: television, preload: preload);

  /// Call from a phone player just before it pops itself.
  void afterPlayerExit(BuildContext playerContext,
          {required Duration watched}) =>
      _afterRouteGone(
          playerContext, (context) => playerExit(context, watched: watched));

  /// Call from a loader that queued a download, just before it pops itself.
  void afterDownloadQueued(BuildContext loaderContext) => _afterRouteGone(
      loaderContext, (context) => show(context, PlaybackAdStage.download));

  /// The popup opens over the screen the viewer returns to once the route
  /// around [routeContext] has gone, so Back itself is never held.
  void _afterRouteGone(BuildContext routeContext,
      Future<void> Function(BuildContext context) present) {
    final navigator = Navigator.of(routeContext);
    final route = ModalRoute.of(routeContext);
    void showPopup() {
      if (navigator.mounted) unawaited(present(navigator.context));
    }

    if (route == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showPopup());
      return;
    }
    // `completed` resolves as the pop starts; wait out the exit transition.
    unawaited(route.completed.then((_) {
      final animation = route.animation;
      if (animation == null || animation.isDismissed) return showPopup();
      void onStatus(AnimationStatus status) {
        if (status != AnimationStatus.dismissed) return;
        animation.removeStatusListener(onStatus);
        showPopup();
      }

      animation.addStatusListener(onStatus);
    }));
  }

  /// After the viewer leaves the player, once its route has popped. Only a
  /// real watch counts: an exit after a failed or bounced stream shows nothing.
  Future<void> playerExit(BuildContext context,
      {required Duration watched}) async {
    if (!context.mounted) return;
    final exit = context
        .read<AppDependencyProvider?>()
        ?.popupTrigger(PlaybackAdStage.playerExit);
    if (exit == null || !exit.enabled) {
      _logSkip(PlaybackAdStage.playerExit, 'disabled');
      return;
    }
    if (watched < exit.minWatch) {
      _logSkip(PlaybackAdStage.playerExit,
          'watched=${watched.inSeconds}s min=${exit.minWatch.inSeconds}s');
      return;
    }
    await show(context, PlaybackAdStage.playerExit);
  }

  /// Prepare an empty WebView while sources load, for any network or format.
  /// Ad requests and activation wait for the visible ad screen. Experiments
  /// keep selecting their arm at presentation, so cancelled lookups do not
  /// advance rotation.
  PlaybackAdPreload? preloadStreamFound(BuildContext context,
      {bool download = false,
      bool television = false,
      PlaybackAdStage stage = PlaybackAdStage.streamFound}) {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (!context.mounted ||
        download ||
        _busy ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed) ||
        kIsWeb ||
        !const {TargetPlatform.android, TargetPlatform.iOS}
            .contains(defaultTargetPlatform)) {
      return null;
    }
    final provider = context.read<AppDependencyProvider?>();
    final selection = provider?.playbackAdsSelection;
    final tv = television || DevicePresentationService.instance.isTelevision;
    if (provider == null || selection == null) return null;
    final resolved = _resolveStage(provider, stage, tv);
    if (_popupCoolingDown(resolved, _frequencyFor(provider, resolved, tv))) {
      return null;
    }
    final placement = _placementFor(
        provider, resolved, tv ? selection.tvNetwork : selection.network, tv);
    if (placement == null) return null;
    late final PlaybackAdPreload preload;
    void onConfigChanged() {
      if (provider.playbackAdsSelection != selection) preload.dispose();
    }

    provider.addListener(onConfigChanged);
    preload = PlaybackAdPreload(
      placement: placement,
      onReleased: () => provider.removeListener(onConfigChanged),
    );
    return preload;
  }

  Future<bool> show(BuildContext context, PlaybackAdStage requested,
      {bool download = false,
      bool television = false,
      PlaybackAdPreload? preload}) async {
    if (!context.mounted) {
      _logSkip(requested, 'playback screen disposed');
      return false;
    }
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      _logSkip(requested, 'app lifecycle=${lifecycle.name}');
      return true;
    }
    final tv = television || DevicePresentationService.instance.isTelevision;
    final provider = context.read<AppDependencyProvider?>();
    final stage = _resolveStage(provider, requested, tv);
    if (download ||
        (tv && stage != PlaybackAdStage.streamFound) ||
        kIsWeb ||
        !const {TargetPlatform.android, TargetPlatform.iOS}
            .contains(defaultTargetPlatform)) {
      _logSkip(stage,
          'download=$download television=$tv platform=${defaultTargetPlatform.name} web=$kIsWeb');
      return true;
    }
    if (_busy) {
      _logSkip(stage, 'another playback ad is active');
      return false;
    }
    final selection = provider?.playbackAdsSelection;
    final network = stage == PlaybackAdStage.beforeLoader
        ? AdNetwork.adsterra
        : tv
            ? selection?.tvNetwork
            : selection?.network;
    final config = selection?.adsterra;
    var placement =
        provider == null ? null : _placementFor(provider, stage, network, tv);
    if (provider == null || placement == null) {
      _logSkip(stage,
          'network=${network?.name ?? 'none'} television=$tv trigger=${provider?.popupTrigger(stage)} adsterraEnabled=${config?.enabled ?? false} popupEnabled=${selection?.popunders[network]?.enabled ?? false}; stage disabled or invalid/missing ${tv ? 'tv_popunder' : 'config'}');
      return true;
    }
    _busy = true;
    final host = ModalRoute.of(context);
    final trigger = provider.popupTrigger(stage);
    bool configChanged() =>
        provider.playbackAdsSelection != selection ||
        provider.popupTrigger(stage) != trigger;
    final frequencyMinutes = _frequencyFor(provider, stage, tv);
    try {
      if (stage != PlaybackAdStage.beforeLoader && frequencyMinutes > 0) {
        await _loadPopupHistory(stage);
        // A config update or navigation while reading storage must not hand
        // playback to an obsolete loader, even when the popup would be skipped.
        if (!context.mounted) return false;
        if (configChanged() || (host != null && !host.isCurrent)) {
          return false;
        }
        final state = WidgetsBinding.instance.lifecycleState;
        if (state != null && state != AppLifecycleState.resumed) return true;
        if (_popupCoolingDown(stage, frequencyMinutes)) {
          preload?.dispose();
          _logSkip(stage, 'popup frequency=$frequencyMinutes minutes');
          return true;
        }
      }
      String? variantId;
      final experiment = stage == PlaybackAdStage.streamFound &&
              network == AdNetwork.adsterra &&
              !tv
          ? config?.streamFoundExperiment
          : null;
      if (experiment != null) {
        final selected = await _nextVariant(experiment);
        placement = selected.placement;
        variantId = '${experiment.id}/${selected.id}';
      }
      // Preference writes may yield to a disable, a navigation, or backgrounding.
      if (!context.mounted) return false;
      if (configChanged() || (host != null && !host.isCurrent)) {
        return false;
      }
      final state = WidgetsBinding.instance.lifecycleState;
      if (state != null && state != AppLifecycleState.resumed) return true;
      final selectedPlacement = placement;
      // An empty view also works for another arm of this same experiment;
      // preparation never selects or requests that arm's ad.
      final matches = preload?.placement == selectedPlacement ||
          experiment?.variants
                  .any((variant) => variant.placement == preload?.placement) ==
              true;
      final prepared =
          matches && preload?.unavailable == false ? preload : null;
      // Expired or changed preparation must not suppress an eligible ad.
      if (prepared == null) preload?.dispose();
      prepared?.claim();
      final navigator = Navigator.of(context);
      final route = MaterialPageRoute<void>(
        settings: RouteSettings(
            name: '/${selectedPlacement.network.name}/${stage.name}'),
        builder: (_) => AdsterraPlaybackAdScreen(
          placement: selectedPlacement,
          stage: stage,
          storeLauncher: storeLauncher,
          television: tv,
          preload: prepared,
          continueTap: continueTap,
          onAdShown: stage == PlaybackAdStage.beforeLoader
              ? null
              : () => unawaited(_recordPopupShown(stage)),
        ),
      );
      // Compare the catalogs and network, not the chosen arm: unrelated
      // provider updates must not close a selected B/C variant.
      void onConfigChanged() {
        if (configChanged() && route.isActive) {
          navigator.removeRoute(route);
        }
      }

      debugPrint(
          '[AdsterraPlayback] ${stage.name}: presenting ${selectedPlacement.network.name} ${selectedPlacement.mode} variant=${variantId ?? 'legacy'} television=$tv preloaded=${prepared != null}');
      provider.addListener(onConfigChanged);
      try {
        await navigator.push(route);
      } finally {
        provider.removeListener(onConfigChanged);
      }
      // The ad closes when FlixQuest is backgrounded (for example by a Play
      // Store hand-off). Do not hand off to the player until it resumes.
      if (!await _waitForForeground()) return false;
      return context.mounted && (host == null || host.isCurrent);
    } catch (error) {
      debugPrint('[AdsterraPlayback] ${stage.name}: unavailable ($error)');
      return context.mounted && (host == null || host.isCurrent);
    } finally {
      _busy = false;
    }
  }

  /// Episode and movie switches keep the stream-found popup on TV, and on
  /// phones until their own switch is published.
  PlaybackAdStage _resolveStage(
          AppDependencyProvider? provider, PlaybackAdStage stage, bool tv) =>
      stage.isSwitch && (tv || provider?.popupTrigger(stage) == null)
          ? PlaybackAdStage.streamFound
          : stage;

  PlaybackAdPlacement? _placementFor(AppDependencyProvider provider,
      PlaybackAdStage stage, AdNetwork? network, bool tv) {
    if (stage.triggerKey != null &&
        provider.popupTrigger(stage)?.enabled != true) {
      return null;
    }
    final selection = provider.playbackAdsSelection;
    return switch (network) {
      AdNetwork.adsterra => selection.adsterra.forStage(stage, television: tv),
      AdNetwork.clickadu ||
      AdNetwork.monetag ||
      AdNetwork.exoclick =>
        stage == PlaybackAdStage.streamFound
            ? selection.popunders[network]?.activeFor(television: tv)
            : selection.popunders[network]?.activeForTrigger(stage),
      null => null,
    };
  }

  int _frequencyFor(
      AppDependencyProvider provider, PlaybackAdStage stage, bool tv) {
    if (stage.triggerKey != null) {
      return provider.popupTrigger(stage)?.frequencyMinutes ?? 0;
    }
    final selection = provider.playbackAdsSelection;
    return tv
        ? selection.tvPopupFrequencyMinutes
        : selection.popupFrequencyMinutes;
  }

  bool _popupCoolingDown(PlaybackAdStage stage, int minutes) {
    final lastShown = _lastPopupShownAt[stage];
    if (minutes <= 0 || lastShown == null) return false;
    final elapsed = _now().difference(lastShown);
    // A clock correction must not leave the viewer capped by a future date.
    return !elapsed.isNegative && elapsed.inMinutes < minutes;
  }

  Future<void> _loadPopupHistory(PlaybackAdStage stage) async {
    try {
      final preferences = await _preferences();
      final timestamp = preferences.getInt(_lastPopupShownKey(stage));
      if (timestamp == null || timestamp <= 0) return;
      final persisted = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (persisted.isAfter(_now())) return;
      final known = _lastPopupShownAt[stage];
      if (known == null || persisted.isAfter(known)) {
        _lastPopupShownAt[stage] = persisted;
      }
    } catch (error) {
      debugPrint(
          '[AdsterraPlayback] popup frequency uses session storage ($error)');
    }
  }

  Future<void> _recordPopupShown(PlaybackAdStage stage) async {
    final shownAt = _now();
    _lastPopupShownAt[stage] = shownAt;
    try {
      final preferences = await _preferences();
      if (!await preferences.setInt(
          _lastPopupShownKey(stage), shownAt.millisecondsSinceEpoch)) {
        debugPrint(
            '[AdsterraPlayback] popup frequency persistence unavailable');
      }
    } catch (error) {
      debugPrint(
          '[AdsterraPlayback] popup frequency uses session storage ($error)');
    }
  }

  Future<PlaybackAdVariant> _nextVariant(
      PlaybackAdExperiment experiment) async {
    final key = 'adsterra_playback.rotation.${experiment.id}';
    var index = _rotation[key] ?? 0;
    try {
      final preferences = await _preferences();
      index = preferences.getInt(key) ?? index;
      index = index % experiment.variants.length;
      final next = (index + 1) % experiment.variants.length;
      _rotation[key] = next;
      if (!await preferences.setInt(key, next)) {
        debugPrint('[AdsterraPlayback] rotation persistence unavailable');
      }
    } catch (error) {
      index = index % experiment.variants.length;
      _rotation[key] = (index + 1) % experiment.variants.length;
      debugPrint('[AdsterraPlayback] rotation uses session storage ($error)');
    }
    return experiment.variants[index];
  }

  void _logSkip(PlaybackAdStage stage, String reason) {
    debugPrint('[AdsterraPlayback] ${stage.name}: skipped ($reason)');
  }
}

Future<bool> _waitForForeground() async {
  final state = WidgetsBinding.instance.lifecycleState;
  if (state == null || state == AppLifecycleState.resumed) return true;
  if (state == AppLifecycleState.detached) return false;
  final waiter = _PlaybackForegroundWaiter();
  WidgetsBinding.instance.addObserver(waiter);
  try {
    return await waiter.result.future;
  } finally {
    WidgetsBinding.instance.removeObserver(waiter);
  }
}

class _PlaybackForegroundWaiter extends WidgetsBindingObserver {
  final result = Completer<bool>();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!result.isCompleted &&
        (state == AppLifecycleState.resumed ||
            state == AppLifecycleState.detached)) {
      result.complete(state == AppLifecycleState.resumed);
    }
  }
}
