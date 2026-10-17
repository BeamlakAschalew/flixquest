import 'package:flixquest/constants/app_constants.dart';
import 'package:flixquest/provider/app_dependency_provider.dart';
import 'package:flixquest/services/app_remote_config.dart';
import 'package:flixquest/services/telegram_channel_prompt_store.dart';
import 'package:flixquest/tv/widgets/tv_pill_button.dart';
import 'package:flixquest/tv/widgets/tv_telegram_channel_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_remote_config.dart';
import 'support/tv_localization.dart';

void main() {
  initializeTvTranslations();
  late SharedPreferences preferences;
  late AppDependencyProvider dependencies;
  const channel = 'https://t.me/flixquestapp';

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
    TelegramChannelPromptStore.resetLaunch();
  });

  Future<void> pumpHome(WidgetTester tester, {bool enabled = true}) async {
    tester.view.physicalSize = const Size(960, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: dependencies,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TvTelegramChannelPrompt(
              enabled: enabled,
              preferences: preferences,
              child: TvPillButton(
                label: 'TV Home',
                autofocus: true,
                onActivate: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(body: Text('Title')))),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  Future<void> showInvite(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('remote-config link becomes a scannable QR after two seconds',
      (tester) async {
    await pumpHome(tester);
    await showInvite(tester);
    expect(find.byType(QrImageView), findsNothing);

    final remote = FakeFirebaseRemoteConfig()
      ..defaults = {AppRemoteConfig.telegramChannelUrlKey: ''};
    const updatedChannel = 'https://t.me/another_channel';
    remote.setMockString(AppRemoteConfig.telegramChannelUrlKey, updatedChannel);
    AppRemoteConfig.apply(remote, dependencies);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(QrImageView), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.backgroundColor, Colors.white);
    final painter = tester
        .widget<CustomPaint>(find.descendant(
            of: find.byType(QrImageView), matching: find.byType(CustomPaint)))
        .painter! as QrPainter;
    // Compare the rendered modules, since QrImageView keeps its data private.
    await tester.runAsync(() async {
      final expected = QrPainter(
        data: updatedChannel,
        version: QrVersions.auto,
        gapless: true,
      );
      final actualImage = await painter.toImageData(200);
      final expectedImage = await expected.toImageData(200);
      expect(actualImage!.buffer.asUint8List(),
          expectedImage!.buffer.asUint8List());
    });
    expect(
        find.text(
            'Scan this QR code with your phone to join our Telegram channel.'),
        findsOneWidget);
    expect(find.text('Join channel'), findsNothing);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Close');
    final qrBounds = tester.getRect(find.byType(QrImageView));
    expect(qrBounds.top, greaterThan(28));
    expect(qrBounds.bottom, lessThan(512));
    expect(tester.takeException(), isNull);
  });

  testWidgets('remote closes, restores Home focus and skips this launch',
      (tester) async {
    dependencies.setTelegramChannelUrl(channel);
    await pumpHome(tester);
    await showInvite(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'TV Home');
    await showInvite(tester);
    expect(find.byType(QrImageView), findsNothing);
    expect(
        preferences.getString(TelegramChannelPromptStore.joinedUrlKey), isNull);
    TelegramChannelPromptStore.resetLaunch();
    expect(
        TelegramChannelPromptStore(preferences).shouldAsk(Uri.parse(channel)),
        isTrue);
  });

  testWidgets('D-pad selects the two-week snooze and survives another launch',
      (tester) async {
    dependencies.setTelegramChannelUrl(channel);
    await pumpHome(tester);
    await showInvite(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, "Don't show again");
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
    final until =
        preferences.getInt(TelegramChannelPromptStore.snoozedUntilKey)!;
    expect(
        DateTime.fromMillisecondsSinceEpoch(until)
            .difference(DateTime.now())
            .inDays,
        13);
    TelegramChannelPromptStore.resetLaunch();
    await tester.pumpWidget(const SizedBox());
    await pumpHome(tester);
    await showInvite(tester);
    expect(find.byType(QrImageView), findsNothing);
  });

  testWidgets('Back dismisses only the invite', (tester) async {
    dependencies.setTelegramChannelUrl(channel);
    await pumpHome(tester);
    await showInvite(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.goBack,
        physicalKey: PhysicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('TV Home'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'TV Home');
    expect(
        preferences.getInt(TelegramChannelPromptStore.snoozedUntilKey), isNull);
  });

  testWidgets('does not interrupt another destination or a pushed page',
      (tester) async {
    dependencies.setTelegramChannelUrl(channel);
    await pumpHome(tester, enabled: false);
    await showInvite(tester);
    expect(find.byType(QrImageView), findsNothing);
    await pumpHome(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    await showInvite(tester);
    expect(find.byType(QrImageView), findsNothing);
    Navigator.of(tester.element(find.text('Title'))).pop();
    await tester.pumpAndSettle();
    await showInvite(tester);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('removing the configured link cancels a pending invite',
      (tester) async {
    dependencies.setTelegramChannelUrl(channel);
    await pumpHome(tester);
    await tester.pump(const Duration(seconds: 1));
    dependencies.setTelegramChannelUrl('');
    await tester.pump();
    await showInvite(tester);
    expect(find.byType(QrImageView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('QR and remote actions fit a compact TV viewport',
      (tester) async {
    dependencies.setTelegramChannelUrl(channel);
    await pumpHome(tester);
    tester.view.physicalSize = const Size(640, 480);
    await tester.pump();
    await showInvite(tester);
    final bounds = tester.getRect(find.byType(QrImageView));
    expect(bounds.top, greaterThan(28));
    expect(bounds.bottom, lessThan(452));
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Close');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, "Don't show again");
    expect(tester.takeException(), isNull);
  });
}
