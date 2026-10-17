import 'dart:async';
import 'dart:io';

import 'package:flixquest/constants/app_constants.dart';
import 'package:flixquest/models/adsterra_playback_ads_config.dart';
import 'package:flixquest/provider/app_dependency_provider.dart';
import 'package:flixquest/services/ad_block_detector.dart';
import 'package:flixquest/widgets/ad_block_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_adsterra_webview.dart';
import 'support/tv_localization.dart';

final real = InternetAddress('104.21.27.36');

/// Local DNS answers per host; a missing host fails like NXDOMAIN.
HostLookup lookupFrom(Map<String, List<List<InternetAddress>>> answers,
        [List<String>? calls]) =>
    (host) async {
      calls?.add(host);
      final queue = answers[host];
      if (queue == null || queue.isEmpty) {
        throw SocketException('Failed host lookup: $host');
      }
      return queue.length == 1 ? queue.single : queue.removeAt(0);
    };

void main() {
  initializeTvTranslations();

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'FLIXQUEST_API_URL=https://api.test');
    SharedPreferences.setMockInitialValues({});
    sharedPrefsSingleton = await SharedPreferences.getInstance();
  });

  group('AdBlockDetector', () {
    AdBlockDetector detector(Map<String, List<List<InternetAddress>>> local,
            {Map<String, bool?> public = const {},
            List<String>? publicCalls}) =>
        AdBlockDetector(
          lookup: lookupFrom(local),
          publicLookup: (host) async {
            publicCalls?.add(host);
            return public[host];
          },
        );

    test('a sinkholed ad host is a blocker', () async {
      for (final sinkhole in ['0.0.0.0', '::', '127.0.0.1', '::1']) {
        final result = await detector({
          'ads.example': [
            [InternetAddress(sinkhole)]
          ],
        }).isBlocking({'ads.example'});
        expect(result, isTrue, reason: sinkhole);
      }
    });

    test('real answers never consult public DNS', () async {
      final publicCalls = <String>[];
      final result = await detector({
        'ads.example': [
          [real]
        ],
        'cdn.example': [
          [real, InternetAddress('0.0.0.0')]
        ],
      }, publicCalls: publicCalls)
          .isBlocking({'ads.example', 'cdn.example'});
      expect(result, isFalse);
      expect(publicCalls, isEmpty);
    });

    test('a host only public DNS can resolve is a blocker', () async {
      final result = await detector({}, public: {'ads.example': true})
          .isBlocking({'ads.example'});
      expect(result, isTrue);
    });

    test('a retired ad domain is not a blocker', () async {
      final result = await detector({}, public: {'ads.example': false})
          .isBlocking({'ads.example'});
      expect(result, isFalse);
    });

    test('no public answer, as when offline, is not a blocker', () async {
      final result = await detector({}).isBlocking({'ads.example'});
      expect(result, isFalse);
    });

    test('a one-off local failure is retried before blaming a blocker',
        () async {
      final calls = <String>[];
      final flaky = AdBlockDetector(
        lookup: (host) async {
          calls.add(host);
          if (calls.length == 1) throw const SocketException('timeout');
          return [real];
        },
        publicLookup: (_) async => true,
      );
      expect(await flaky.isBlocking({'ads.example'}), isFalse);
      expect(calls, hasLength(2));
    });

    test('a check that runs too long allows playback', () async {
      final slow = AdBlockDetector(
        lookup: (_) => Completer<List<InternetAddress>>().future,
        timeout: const Duration(milliseconds: 10),
      );
      expect(await slow.isBlocking({'ads.example'}), isFalse);
    });

    test('no ad hosts means nothing to check', () async {
      expect(await detector({}).isBlocking({}), isFalse);
    });

    test('ad hosts come from live banners and Adsterra playback ads', () {
      final provider = AppDependencyProvider()
        ..setBannerAdsConfig(testAdsterraConfig())
        ..setAdsterraPlaybackAdsConfig(AdsterraPlaybackAdsConfig.parse('''{
          "interstitial":{"enabled":true,"script_url":"https://social.example/s"},
          "popunder":{"enabled":true,"mode":"smartlink","url":"https://smart.example/l"}
        }''', enabled: true));
      expect(AdBlockDetector.adHosts(provider),
          {'ads.example', 'social.example', 'smart.example'});

      provider
        ..setBannerAdNetwork('none')
        ..setAdsterraPlaybackAdsConfig(
            const AdsterraPlaybackAdsConfig(enabled: false));
      expect(AdBlockDetector.adHosts(provider), isEmpty);
    });
  });

  group('AdBlockGate', () {
    late AppDependencyProvider provider;
    late bool blocked;
    late int checks;
    late DateTime now;
    late BuildContext host;

    setUp(() {
      provider = AppDependencyProvider()
        ..setBannerAdsConfig(testAdsterraConfig())
        ..adBlockGateEnabled = true;
      blocked = true;
      checks = 0;
      now = DateTime(2026, 10, 17);
    });

    AdBlockGate gate() => AdBlockGate(
          detector: AdBlockDetector(
            lookup: (_) async {
              checks++;
              return [blocked ? InternetAddress('0.0.0.0') : real];
            },
          ),
          now: () => now,
        );

    Future<void> pumpHost(WidgetTester tester) => tester.pumpWidget(
          ChangeNotifierProvider<AppDependencyProvider>.value(
            value: provider,
            child: MaterialApp(
              home: Builder(builder: (context) {
                host = context;
                return const SizedBox();
              }),
            ),
          ),
        );

    testWidgets('does nothing until the remote switch is on', (tester) async {
      provider.adBlockGateEnabled = false;
      await pumpHost(tester);
      expect(await gate().allowPlayback(host), isTrue);
      expect(checks, 0);
    });

    testWidgets('lets viewers without a blocker straight through',
        (tester) async {
      blocked = false;
      await pumpHost(tester);
      expect(await gate().allowPlayback(host), isTrue);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('waits for the blocker to go, then continues', (tester) async {
      await pumpHost(tester);
      final result = gate().allowPlayback(host);
      await tester.pumpAndSettle();
      expect(find.text('Turn off your ad blocker'), findsOneWidget);

      // Still blocked: the dialog returns with the reminder.
      await tester.tap(find.text('I turned it off'));
      await tester.pumpAndSettle();
      expect(find.textContaining('still on'), findsOneWidget);

      blocked = false;
      await tester.tap(find.text('I turned it off'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('cancelling stops playback', (tester) async {
      await pumpHost(tester);
      final result = gate().allowPlayback(host, download: true);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });

    testWidgets('a passed check covers the next few minutes', (tester) async {
      blocked = false;
      await pumpHost(tester);
      final shared = gate();
      expect(await shared.allowPlayback(host), isTrue);
      expect(checks, 1);

      blocked = true;
      now = now.add(const Duration(minutes: 4));
      expect(await shared.allowPlayback(host), isTrue);
      expect(checks, 1);

      now = now.add(const Duration(minutes: 2));
      final result = shared.allowPlayback(host);
      await tester.pumpAndSettle();
      expect(find.text('Turn off your ad blocker'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });
  });
}
