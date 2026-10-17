import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design/app_palette.dart';
import '../../design/app_tokens.dart';
import '../../widgets/telegram_channel_prompt_gate.dart';
import 'pill_button.dart';

export '../../widgets/telegram_channel_prompt_gate.dart'
    show TelegramChannelChoice;

/// The phone/tablet invite, with timing shared with the TV QR invite.
class TelegramChannelPrompt extends StatelessWidget {
  const TelegramChannelPrompt({
    required this.child,
    this.preferences,
    this.openChannel,
    this.delay = const Duration(seconds: 2),
    super.key,
  });

  final Widget child;
  final SharedPreferences? preferences;
  final Future<bool> Function(Uri channel)? openChannel;
  final Duration delay;

  @override
  Widget build(BuildContext context) => TelegramChannelPromptGate(
        preferences: preferences,
        openChannel: openChannel,
        delay: delay,
        showInvite: (context, _) => showTelegramChannelDialog(context),
        child: child,
      );
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
