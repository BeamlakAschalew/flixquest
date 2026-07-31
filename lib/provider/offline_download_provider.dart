import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/offline_download.dart';
import '../services/offline_download_service.dart';

class OfflineDownloadProvider extends ChangeNotifier {
  OfflineDownloadProvider({OfflineDownloadGateway? service})
      : _service = service ?? OfflineDownloadService.instance;

  final OfflineDownloadGateway _service;
  StreamSubscription<List<OfflineDownload>>? _subscription;
  List<OfflineDownload> _downloads = const [];
  final Map<String, _DownloadRateSample> _rateSamples = {};
  bool _initialized = false;
  bool _loading = false;
  String? _error;

  List<OfflineDownload> get downloads => _downloads;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _subscription = _service.downloadEvents.listen(
      _replaceDownloads,
      onError: (Object error) {
        _error = error.toString();
        notifyListeners();
      },
    );
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _replaceDownloads(await _service.getDownloads());
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> enqueue(OfflineDownloadRequest request) async {
    _error = null;
    try {
      await _service.enqueue(request);
      await refresh();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pause(String id) => _perform(() => _service.pause(id));
  Future<void> resume(String id) => _perform(() => _service.resume(id));
  Future<void> retry(String id) => _perform(() => _service.retry(id));
  Future<void> remove(String id) => _perform(() => _service.remove(id));
  Future<void> openExternal(String id) => _service.openExternal(id);
  Future<bool> saveCopy(String id) => _service.saveCopy(id);

  Future<void> _perform(Future<void> Function() operation) async {
    _error = null;
    try {
      await operation();
      await refresh();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _replaceDownloads(List<OfflineDownload> downloads) {
    final now = DateTime.now();
    final activeIds = downloads.map((download) => download.id).toSet();
    _rateSamples.removeWhere((id, _) => !activeIds.contains(id));

    final withRates = downloads.map((download) {
      if (download.state != OfflineDownloadState.downloading) {
        _rateSamples.remove(download.id);
        return download.copyWith(networkRateBytesPerSecond: 0);
      }

      final previous = _rateSamples[download.id];
      var rate = download.networkRateBytesPerSecond;
      if (previous == null || download.bytesDownloaded < previous.bytes) {
        _rateSamples[download.id] = _DownloadRateSample(
          bytes: download.bytesDownloaded,
          sampledAt: now,
          rate: rate,
        );
      } else {
        final elapsed = now.difference(previous.sampledAt).inMilliseconds;
        if (elapsed >= 400) {
          final bytesAdded = download.bytesDownloaded - previous.bytes;
          final measuredRate = bytesAdded * 1000 / elapsed;
          rate = previous.rate <= 0
              ? measuredRate
              : (measuredRate * .65) + (previous.rate * .35);
          if (rate < 1024) rate = 0;
          _rateSamples[download.id] = _DownloadRateSample(
            bytes: download.bytesDownloaded,
            sampledAt: now,
            rate: rate,
          );
        } else {
          rate = previous.rate;
        }
      }
      return download.copyWith(networkRateBytesPerSecond: rate);
    });

    final sorted = List<OfflineDownload>.of(withRates)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _downloads = List.unmodifiable(sorted);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class _DownloadRateSample {
  const _DownloadRateSample({
    required this.bytes,
    required this.sampledAt,
    required this.rate,
  });

  final int bytes;
  final DateTime sampledAt;
  final double rate;
}
