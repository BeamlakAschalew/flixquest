import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_constants.dart';
import '../../design/app_palette.dart';
import '../../design/app_tokens.dart';
import '../../provider/app_dependency_provider.dart';
import '../../services/telegram_channel_prompt_store.dart';
import 'pill_button.dart';

/// How someone answered the invite; null when they closed it.
enum TelegramChannelChoice { join, dontShowAgain }

/// Invites people to the Telegram channel over [child], Home, a moment after
/// it is on screen. Asks only while Home is the tab and page on show, once a
/// launch, and not while "Don't show again" lasts.
class TelegramChannelPrompt extends StatefulWidget {
  const TelegramChannelPrompt({
    required this.child,
    this.preferences,
    this.openChannel,
    this.delay = const Duration(seconds: 2),
    super.key,
  });

  final Widget child;

  /// Where the answer is kept; the app's preferences by default.
  final SharedPreferences? preferences;

  /// Opens the channel, outside the app by default. True when it opened.
  final Future<bool> Function(Uri channel)? openChannel;

  /// How long Home is on show before the invite.
  final Duration delay;

  @override
  State<TelegramChannelPrompt> createState() => _TelegramChannelPromptState();
}

class _TelegramChannelPromptState extends State<TelegramChannelPrompt> {
  Timer? _timer;
  TelegramChannelPromptStore? _store;

  TelegramChannelPromptStore get _prompts => _store ??=
      TelegramChannelPromptStore(widget.preferences ?? sharedPrefsSingleton);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Uri? _channel(BuildContext context) =>
      Provider.of<AppDependencyProvider?>(context)?.telegramChannelUrl;

  /// Home is the tab on show (the others' tickers are off) and no page is
  /// pushed over it.
  bool _onShow(BuildContext context) =>
      TickerMode.of(context) && (ModalRoute.of(context)?.isCurrent ?? true);

  /// The link and whether Home is on show, as of the last build; any change
  /// to either rebuilds.
  Uri? _channelNow;
  bool _onShowNow = false;

  bool get _due =>
      _channelNow != null && _onShowNow && _prompts.shouldAsk(_channelNow!);

  void _sync() {
    if (!_due) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer(widget.delay, _ask);
  }

  Future<void> _ask() async {
    _timer = null;
    if (!mounted || !_due) return;
    final channel = _channelNow!;
    _prompts.markAsked();
    final choice = await showTelegramChannelDialog(context);
    switch (choice) {
      case TelegramChannelChoice.join:
        final open = widget.openChannel ??
            (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
        if (await open(channel)) await _prompts.markJoined(channel);
      case TelegramChannelChoice.dontShowAgain:
        await _prompts.snooze();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _channelNow = _channel(context);
    _onShowNow = _onShow(context);
    _sync();
    return widget.child;
  }
}

/// The invite: the Telegram mark, a line on what the channel is for, Join and
/// "Don't show again", and a close button for "not now".
Future<TelegramChannelChoice?> showTelegramChannelDialog(BuildContext context) {
  return showDialog<TelegramChannelChoice>(
    context: context,
    builder: (dialogContext) {
      final palette = AppPalette.of(dialogContext);
      return Dialog(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.hero),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl,
                  AppSpace.xxl,
                  AppSpace.xl,
                  AppSpace.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: palette.idleFill,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIcons.telegramLogo(),
                          size: 22,
                          color: palette.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Text(
                      tr('telegram_prompt_title'),
                      style: AppType.sectionHeader.copyWith(
                        fontFamily: AppType.bold,
                        color: palette.foreground,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      tr('telegram_prompt_message'),
                      style: AppType.body.copyWith(color: palette.mutedText),
                    ),
                    const SizedBox(height: AppSpace.xxl),
                    PillButton(
                      label: tr('telegram_prompt_join'),
                      icon: PhosphorIcons.telegramLogo(),
                      primary: true,
                      onPressed: () => Navigator.pop(
                          dialogContext, TelegramChannelChoice.join),
                    ),
                    const SizedBox(height: AppSpace.md),
                    PillButton(
                      label: tr('telegram_prompt_dont_show_again'),
                      onPressed: () => Navigator.pop(
                          dialogContext, TelegramChannelChoice.dontShowAgain),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                top: AppSpace.sm,
                end: AppSpace.sm,
                child: IconButton(
                  tooltip: tr('close'),
                  icon: Icon(PhosphorIcons.x(), size: 20),
                  color: palette.mutedText,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
