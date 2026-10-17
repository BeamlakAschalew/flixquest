import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/telegram_channel_prompt_gate.dart';
import 'tv_dialog.dart';

/// Invites viewers to join on their phone, without leaving TV Home.
class TvTelegramChannelPrompt extends StatelessWidget {
  const TvTelegramChannelPrompt({
    required this.child,
    this.enabled = true,
    this.preferences,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final SharedPreferences? preferences;

  @override
  Widget build(BuildContext context) => TelegramChannelPromptGate(
        enabled: enabled,
        preferences: preferences,
        showInvite: showTvTelegramChannelDialog,
        child: child,
      );
}

Future<TelegramChannelChoice?> showTvTelegramChannelDialog(
    BuildContext context, Uri channel) {
  return showTvDialog<TelegramChannelChoice>(
    context: context,
    title: tr('telegram_prompt_title'),
    content: LayoutBuilder(
      builder: (context, constraints) {
        final qr = Semantics(
          label: channel.toString(),
          image: true,
          child: QrImageView(
            data: channel.toString(),
            size: constraints.maxWidth < 520 ? 160 : 200,
            // Keep the code scannable in both light and dark themes, with a
            // white quiet zone around all four sides.
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
        );
        final description = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('telegram_prompt_message')),
            const SizedBox(height: 16),
            Text(tr('telegram_prompt_scan')),
          ],
        );
        if (constraints.maxWidth < 400) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [qr, const SizedBox(height: 20), description],
          );
        }
        return Row(
          children: [
            qr,
            const SizedBox(width: 28),
            Expanded(child: description),
          ],
        );
      },
    ),
    actions: [
      TvDialogAction(
        label: tr('close'),
        isPrimary: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
      TvDialogAction(
        label: tr('telegram_prompt_dont_show_again'),
        onPressed: () =>
            Navigator.of(context).pop(TelegramChannelChoice.dontShowAgain),
      ),
    ],
  );
}
