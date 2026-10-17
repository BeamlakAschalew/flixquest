import 'dart:async';

import 'package:flixquest/services/remote_config_refresh_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness {
  _Harness(WidgetTester tester) {
    final now = tester.binding.clock.now;
    lastFetch = now().subtract(const Duration(days: 1));
    controller = RemoteConfigRefreshController(
      fetch: () async {
        calls++;
        final fetched = await (pending?.future ?? Future.value(succeed));
        if (fetched) lastFetch = now();
        return fetched;
      },
      lastFetchTime: () => lastFetch,
      connectivityChanges: network.stream,
      checkConnectivity: () async => online,
      now: now,
    );
  }

  final network = StreamController<bool>(sync: true);
  late final RemoteConfigRefreshController controller;
  late DateTime lastFetch;
  int calls = 0;
  bool succeed = false;
  bool online = true;
  Completer<bool>? pending;

  void connection(bool connected) {
    online = connected;
    network.add(connected);
  }

  void dispose() {
    controller.dispose();
    unawaited(network.close());
  }
}

void main() {
  void refreshTest(String name,
      Future<void> Function(WidgetTester tester, _Harness h) body) {
    testWidgets(name, (tester) async {
      final harness = _Harness(tester);
      try {
        await body(tester, harness);
      } finally {
        harness.dispose();
      }
    });
  }

  refreshTest('stops after three automatic retries', (tester, h) async {
    await h.controller.refresh();
    expect(h.calls, 1);
    for (final delay in [15, 30, 60]) {
      await tester.pump(Duration(seconds: delay));
    }
    expect(h.calls, 4);
    await tester.pump(const Duration(days: 1));
    expect(h.calls, 4);
  });

  refreshTest('a successful retry stops all scheduled fetches',
      (tester, h) async {
    await h.controller.refresh();
    h.succeed = true;
    await tester.pump(const Duration(seconds: 15));
    expect(h.calls, 2);
    await tester.pump(const Duration(days: 1));
    expect(h.calls, 2);
  });

  refreshTest('known offline startup waits for connectivity',
      (tester, h) async {
    h.connection(false);
    await h.controller.refresh();
    await tester.pump(const Duration(hours: 1));
    expect(h.calls, 1);

    h.succeed = true;
    h.connection(true);
    await tester.pump();
    expect(h.calls, 2);
    await tester.pump(const Duration(hours: 1));
    expect(h.calls, 2);
  });

  refreshTest('reconnection recovers after the retry budget is exhausted',
      (tester, h) async {
    await h.controller.refresh();
    for (final delay in [15, 30, 60]) {
      await tester.pump(Duration(seconds: delay));
    }
    await tester.pump(const Duration(minutes: 1));
    h.connection(false);
    h.succeed = true;
    h.connection(true);
    await tester.pump();
    expect(h.calls, 5);
  });

  refreshTest(
      'flapping connectivity is rate limited and duplicate events ignored',
      (tester, h) async {
    await h.controller.refresh();
    h.connection(false);
    h.connection(true);
    h.connection(true);
    h.connection(false);
    h.connection(true);
    await tester.pump(const Duration(seconds: 59));
    expect(h.calls, 1);
    h.succeed = true;
    await tester.pump(const Duration(seconds: 1));
    expect(h.calls, 2);
    h.connection(false);
    h.connection(true);
    await tester.pump(const Duration(hours: 1));
    expect(h.calls, 2);
  });

  refreshTest('backgrounding cancels retries and reconnect waits for resume',
      (tester, h) async {
    await h.controller.refresh();
    h.controller.pause();
    h.connection(false);
    h.connection(true);
    await tester.pump(const Duration(hours: 1));
    expect(h.calls, 1);
    h.succeed = true;
    await h.controller.resume();
    await tester.pump();
    expect(h.calls, 2);
  });

  refreshTest('resume checks current connectivity after an offline background',
      (tester, h) async {
    h.connection(false);
    await h.controller.refresh();
    h.controller.pause();
    await tester.pump(const Duration(minutes: 2));
    // Android may not have delivered any connectivity events in the background.
    h.online = true;
    h.succeed = true;
    await h.controller.resume();
    await tester.pump();
    expect(h.calls, 2);
  });

  refreshTest('resume while still offline does not start a retry loop',
      (tester, h) async {
    await h.controller.refresh();
    h.controller.pause();
    h.online = false;
    await h.controller.resume();
    await tester.pump(const Duration(days: 1));
    expect(h.calls, 1);
  });

  refreshTest('healthy resumes only refresh after thirty minutes',
      (tester, h) async {
    h.succeed = true;
    await h.controller.refresh();
    await tester.pump(const Duration(minutes: 10));
    await h.controller.resume();
    expect(h.calls, 1);
    await tester.pump(const Duration(minutes: 19, seconds: 59));
    await h.controller.resume();
    expect(h.calls, 1);
    await tester.pump(const Duration(seconds: 1));
    await h.controller.resume();
    await tester.pump();
    expect(h.calls, 2);
  });

  refreshTest('overlapping fetch and resume requests share one attempt',
      (tester, h) async {
    h.pending = Completer<bool>();
    final first = h.controller.refresh();
    await h.controller.refresh();
    await h.controller.resume();
    h.connection(false);
    h.connection(true);
    expect(h.calls, 1);
    h.pending!.complete(true);
    await first;
    await tester.pump(const Duration(hours: 1));
    expect(h.calls, 1);
  });

  refreshTest('backgrounding during a fetch prevents background retries',
      (tester, h) async {
    h.pending = Completer<bool>();
    final first = h.controller.refresh();
    h.controller.pause();
    h.pending!.complete(false);
    await first;
    await tester.pump(const Duration(hours: 1));
    expect(h.calls, 1);
  });

  refreshTest('disposing during a fetch prevents timers and later fetches',
      (tester, h) async {
    h.pending = Completer<bool>();
    final first = h.controller.refresh();
    h.controller.dispose();
    h.pending!.complete(false);
    await first;
    h.connection(false);
    h.connection(true);
    await h.controller.resume();
    await h.controller.refresh();
    await tester.pump(const Duration(hours: 1));
    expect(h.calls, 1);
  });
}
