import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../provider/app_dependency_provider.dart';
import '../services/telegram_channel_prompt_store.dart';

/// Null means the invite was closed for this launch only.
enum TelegramChannelChoice { join, dontShowAgain }

/// Shares the invite timing and preferences between phone and TV Home.
class TelegramChannelPromptGate extends StatefulWidget {
  const TelegramChannelPromptGate({
    required this.child,
    required this.showInvite,
    this.enabled = true,
    this.preferences,
    this.openChannel,
    this.delay = const Duration(seconds: 2),
    super.key,
  });

  final Widget child;
  final Future<TelegramChannelChoice?> Function(BuildContext, Uri) showInvite;
  final bool enabled;
  final SharedPreferences? preferences;
  final Future<bool> Function(Uri channel)? openChannel;
  final Duration delay;

  @override
  State<TelegramChannelPromptGate> createState() =>
      _TelegramChannelPromptGateState();
}

class _TelegramChannelPromptGateState extends State<TelegramChannelPromptGate> {
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
      widget.enabled &&
      TickerMode.of(context) &&
      (ModalRoute.of(context)?.isCurrent ?? true);

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
    final choice = await widget.showInvite(context, channel);
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
