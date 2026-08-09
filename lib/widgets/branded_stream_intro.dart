import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/stream_intro_service.dart';

/// Holds the requested stream behind a control-free branded intro and reveals
/// it only after the stream is initialized and playing.
class BrandedStreamIntro extends StatefulWidget {
  const BrandedStreamIntro({
    required this.apiBaseUrl,
    required this.mainController,
    required this.initialMainReady,
    required this.accentColor,
    this.onInitialStreamStarted,
    super.key,
  });

  final String apiBaseUrl;
  final BetterPlayerController mainController;
  final Future<void> initialMainReady;
  final Color accentColor;
  final VoidCallback? onInitialStreamStarted;

  @override
  State<BrandedStreamIntro> createState() => BrandedStreamIntroState();
}

class BrandedStreamIntroState extends State<BrandedStreamIntro> {
  late final StreamIntroService _service;
  BetterPlayerController? _introController;
  bool _visible = true;
  bool _showVideo = false;
  bool _initialRun = true;
  int _runId = 0;
  Completer<void>? _introFinished;

  @override
  void initState() {
    super.initState();
    _service = StreamIntroService();
    unawaited(_run(widget.initialMainReady));
  }

  /// Replays the intro while [prepareMain] swaps or initializes the next
  /// official stream behind it. Used for in-player live channel changes.
  Future<void> playBefore(Future<void> Function() prepareMain) async {
    final runId = ++_runId;
    await widget.mainController.pause();
    if (!mounted || runId != _runId) return;
    setState(() {
      _visible = true;
      _showVideo = false;
    });
    await _disposeIntroController();
    final mainReady = prepareMain();
    await _run(mainReady, runId: runId);
    await mainReady;
  }

  Future<void> _run(Future<void> mainReady, {int? runId}) async {
    final activeRunId = runId ?? _runId;
    try {
      final config = await _service.fetch(widget.apiBaseUrl);
      if (!_isCurrent(activeRunId)) return;
      if (!config.enabled || config.url == null) {
        await _revealMain(mainReady, activeRunId);
        return;
      }

      final finished = Completer<void>();
      _introFinished = finished;
      final controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          looping: false,
          fit: BoxFit.contain,
          allowedScreenSleep: false,
          autoDispose: false,
          handleLifecycle: true,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
            enableFullscreen: false,
            enablePip: false,
            enableCast: false,
            backgroundColor: Colors.black,
          ),
        ),
      );
      _introController = controller;
      controller.addEventsListener(_onIntroEvent);
      await controller
          .setupDataSource(
            BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              config.url.toString(),
              cacheConfiguration: const BetterPlayerCacheConfiguration(
                useCache: true,
                maxCacheSize: 50 * 1024 * 1024,
                maxCacheFileSize: 20 * 1024 * 1024,
              ),
            ),
          )
          .timeout(const Duration(seconds: 10));
      if (!_isCurrent(activeRunId)) return;
      setState(() => _showVideo = true);
      await finished.future;
      await _revealMain(mainReady, activeRunId);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[BrandedIntro] Skipping intro: $error');
      }
      await _revealMain(mainReady, activeRunId);
    }
  }

  void _onIntroEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.finished:
        if (_introFinished?.isCompleted == false) _introFinished!.complete();
        break;
      case BetterPlayerEventType.exception:
        if (_introFinished?.isCompleted == false) {
          _introFinished!.completeError(
            StateError(event.parameters?.toString() ?? 'Intro playback failed'),
          );
        }
        break;
      default:
        break;
    }
  }

  Future<void> _revealMain(Future<void> mainReady, int runId) async {
    if (!_isCurrent(runId)) return;
    try {
      await mainReady;
      if (!_isCurrent(runId)) return;
      await widget.mainController.play();
      await _waitForMainPlayback(runId);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[BrandedIntro] Main stream preparation failed: $error');
      }
    }
    if (!_isCurrent(runId)) return;

    setState(() => _visible = false);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!_isCurrent(runId)) return;
    await _disposeIntroController();
    if (_initialRun) {
      _initialRun = false;
      widget.onInitialStreamStarted?.call();
    }
  }

  Future<void> _waitForMainPlayback(int runId) async {
    final videoController = widget.mainController.videoPlayerController;
    if (videoController == null) return;
    if (videoController.value.isPlaying && !videoController.value.isBuffering) {
      return;
    }

    final ready = Completer<void>();
    void listener() {
      if (!_isCurrent(runId) ||
          (videoController.value.isPlaying &&
              !videoController.value.isBuffering)) {
        if (!ready.isCompleted) ready.complete();
      }
    }

    videoController.addListener(listener);
    try {
      await ready.future.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      // Reveal the main player even if a slow source has not emitted its first
      // non-buffering frame yet; its own loading UI remains available.
    } finally {
      videoController.removeListener(listener);
    }
  }

  bool _isCurrent(int runId) => mounted && runId == _runId;

  Future<void> _disposeIntroController() async {
    final controller = _introController;
    final finished = _introFinished;
    _introController = null;
    _introFinished = null;
    if (finished?.isCompleted == false) {
      finished!.completeError(StateError('Intro playback was superseded'));
    }
    if (mounted && _showVideo) setState(() => _showVideo = false);
    if (controller == null) return;
    controller.removeEventsListener(_onIntroEvent);
    controller.dispose(forceDispose: true);
  }

  @override
  void dispose() {
    _runId++;
    _service.close();
    final controller = _introController;
    if (controller != null) {
      controller.removeEventsListener(_onIntroEvent);
      controller.dispose(forceDispose: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: ColoredBox(
          color: Colors.black,
          child: _showVideo && _introController != null
              ? BetterPlayer(controller: _introController!)
              : Center(
                  child: SizedBox(
                    width: 72,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: widget.accentColor,
                      backgroundColor:
                          widget.accentColor.withValues(alpha: .22),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
