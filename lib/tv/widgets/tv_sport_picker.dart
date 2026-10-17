import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../functions/live_sport_preferences.dart';
import 'tv_dialog.dart';
import 'tv_pill_button.dart';

/// Asks which sports the viewer follows. Resolves to the chosen ids on Save.
/// The [firstTime] question offers Skip, which resolves to an empty set;
/// later it offers Cancel. Cancel and Back resolve to null.
Future<Set<String>?> showTvSportPicker(
  BuildContext context, {
  required Set<String> initial,
  required bool firstTime,
}) {
  final selection = <String>{...initial};
  return showTvDialog<Set<String>>(
    context: context,
    title: tr('live_sports_prompt_title'),
    // The first sport takes focus instead, so the remote starts on the list.
    autofocusFirstAction: false,
    content: TvSportPickerContent(selection: selection),
    actions: <TvDialogAction>[
      TvDialogAction(
        label: tr('save'),
        isPrimary: true,
        onPressed: () => Navigator.of(context).pop(selection),
      ),
      TvDialogAction(
        label: firstTime ? tr('live_sports_skip') : tr('cancel'),
        onPressed: () =>
            Navigator.of(context).pop(firstTime ? const <String>{} : null),
      ),
    ],
  );
}

/// Every sport on [liveSports] as a button the remote toggles; toggles land
/// in [selection], which the dialog's Save returns.
class TvSportPickerContent extends StatefulWidget {
  const TvSportPickerContent({required this.selection, super.key});

  final Set<String> selection;

  @override
  State<TvSportPickerContent> createState() => _TvSportPickerContentState();
}

class _TvSportPickerContentState extends State<TvSportPickerContent> {
  void _toggle(String id) {
    setState(() {
      if (!widget.selection.remove(id)) widget.selection.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(tr('live_sports_prompt_message')),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final (index, sport) in liveSports.indexed)
              TvPillButton(
                key: ValueKey<String>('live-sport-${sport.id}'),
                autofocus: index == 0,
                icon: widget.selection.contains(sport.id)
                    ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                    : PhosphorIcons.circle(),
                label: '${sport.emoji} ${tr(sport.labelKey)}',
                semanticLabel: tr(sport.labelKey),
                onActivate: () => _toggle(sport.id),
              ),
          ],
        ),
      ],
    );
  }
}
