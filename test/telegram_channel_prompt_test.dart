import 'package:flixquest/constants/app_constants.dart';
import 'package:flixquest/mobile/widgets/telegram_channel_prompt.dart';
import 'package:flixquest/provider/app_dependency_provider.dart';
import 'package:flixquest/services/app_remote_config.dart';
import 'package:flixquest/services/telegram_channel_prompt_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_remote_config.dart';
import 'support/tv_localization.dart';

void main() {
  initializeTvTranslations();
  final channel = Uri.parse('https://t.me/flixquestapp');
  late SharedPreferences preferences;
  late AppDependencyProvider dependencies;
  late DateTime now;

  setUpAll(() {
    dotenv.testLoad(
        fileInput:
            'TMDB_API_KEY=test\nMIXPANEL_API_KEY=test\nFLIXQUEST_API_URL=https://example.com');
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    sharedPrefsSingleton = preferences;
    dependencies = AppDependencyProvider();
    now = DateTime(2026, 10, 16);
    TelegramChannelPromptStore.resetLaunch();
  });

  TelegramChannelPromptStore store() =>
      TelegramChannelPromptStore(preferences, now: () => now);

  group('TelegramChannelPromptStore', () {
    test('asks once a launch', () {
      expect(store().shouldAsk(channel), isTrue);
      store().markAsked();
      expect(store().shouldAsk(channel), isFalse);
      TelegramChannelPromptStore.resetLaunch();
      expect(store().shouldAsk(channel), isTrue);
    });

    test("Don't show again lasts two weeks", () async {
      await store().snooze();
      now = now.add(const Duration(days: 13, hours: 23));
      expect(store().shouldAsk(channel), isFalse);
      now = now.add(const Duration(hours: 1));
      expect(store().shouldAsk(channel), isTrue);
    });

    test('joining stops the invite until the link changes', () async {
      await store().markJoined(channel);
      now = now.add(const Duration(days: 365));
      expect(store().shouldAsk(channel), isFalse);
      expect(store().shouldAsk(Uri.parse('https://t.me/another')), isTrue);
    });
  });

  group('telegram_channel_url', () {
    test('takes Telegram links and turns the invite off for anything else', () {
      dependencies.setTelegramChannelUrl(' https://t.me/flixquestapp ');
      expect(dependencies.telegramChannelUrl, channel);
      dependencies.setTelegramChannelUrl('tg://resolve?domain=flixquestapp');
      expect(dependencies.telegramChannelUrl?.scheme, 'tg');
      for (final value in ['', 'flixquestapp', 'javascript:alert(1)']) {
        dependencies.setTelegramChannelUrl(value);
        expect(dependencies.telegramChannelUrl, isNull, reason: value);
      }
    });

    test('is read from Remote Config, off until published', () {
      final remote = FakeFirebaseRemoteConfig()
        ..defaults = {AppRemoteConfig.telegramChannelUrlKey: ''};
      AppRemoteConfig.apply(remote, dependencies);
      expect(dependencies.telegramChannelUrl, isNull);
      remote.setMockString(
          AppRemoteConfig.telegramChannelUrlKey, channel.toString());
      AppRemoteConfig.apply(remote, dependencies);
      expect(dependencies.telegramChannelUrl, channel);
    });
  });

  group('TelegramChannelPrompt', () {
    final opened = <Uri>[];
    setUp(opened.clear);

    Future<void> pumpHome(WidgetTester tester, {bool opens = true}) async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: dependencies,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TelegramChannelPrompt(
                preferences: preferences,
                openChannel: (uri) async {
                  opened.add(uri);
                  return opens;
                },
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(body: Text('Title')))),
                  child: const Text('Home'),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    testWidgets('waits for a published link, then invites once',
        (tester) async {
      await pumpHome(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Join our Telegram channel'), findsNothing);

      dependencies.setTelegramChannelUrl(channel.toString());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Join our Telegram channel'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Join our Telegram channel'), findsNothing);
      // Closing skips this launch only.
      expect(store().shouldAsk(channel), isFalse);
      TelegramChannelPromptStore.resetLaunch();
      expect(store().shouldAsk(channel), isTrue);
    });

    testWidgets("Don't show again snoozes the invite", (tester) async {
      dependencies.setTelegramChannelUrl(channel.toString());
      await pumpHome(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Don't show again"));
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      final until = DateTime.fromMillisecondsSinceEpoch(
          preferences.getInt(TelegramChannelPromptStore.snoozedUntilKey)!);
      expect(until.difference(DateTime.now()).inDays, 13);
    });

    testWidgets('Join opens the channel and remembers it', (tester) async {
      dependencies.setTelegramChannelUrl(channel.toString());
      await pumpHome(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Join channel'));
      await tester.pumpAndSettle();
      expect(opened, [channel]);
      expect(preferences.getString(TelegramChannelPromptStore.joinedUrlKey),
          channel.toString());
    });

    testWidgets('waits while a page covers Home', (tester) async {
      dependencies.setTelegramChannelUrl(channel.toString());
      await pumpHome(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Join our Telegram channel'), findsNothing);

      Navigator.of(tester.element(find.text('Title'))).pop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Join our Telegram channel'), findsOneWidget);
    });
  });
}
