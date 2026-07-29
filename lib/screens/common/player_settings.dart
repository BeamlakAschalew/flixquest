import '../../screens/common/sublanguage_choose.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_constants.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../ui_components/app_ui_components.dart';

class PlayerSettings extends StatefulWidget {
  const PlayerSettings({super.key});

  @override
  State<PlayerSettings> createState() => _PlayerSettingsState();
}

class _PlayerSettingsState extends State<PlayerSettings> {
  @override
  Widget build(BuildContext context) {
    final settingValues = Provider.of<SettingsProvider>(context);
    // final subtitleLanguage = Provider.of<SettingsProvider>(context);
    String backgroundColorString = settingValues.subtitleBackgroundColor;
    String foregroundColorString = settingValues.subtitleForegroundColor;
    String hexColorBackground =
        backgroundColorString.replaceAll('Color(0x', '').replaceAll(')', '');
    String hexColorForeground =
        foregroundColorString.replaceAll('Color(0x', '').replaceAll(')', '');

    Color backgroundColor = Color(int.parse('0x$hexColorBackground'));
    Color foregroundColor = Color(int.parse('0x$hexColorForeground'));

    Color pickerColor = const Color(0xff443a49);
    Color currentColor = const Color(0xff443a49);

    String st = settingValues.subtitleTextStyle;

// ValueChanged<Color> callback
    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    void colorPickerDialog(int type) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: type == 1 ? foregroundColor : backgroundColor,
                onColorChanged: (color) {
                  changeColor(color);
                },
                hexInputBar: true,
                enableAlpha: true,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(
                  tr('save'),
                ),
                onPressed: () {
                  setState(() => currentColor = pickerColor);
                  type == 1
                      ? settingValues.subtitleForegroundColor =
                          currentColor.toString()
                      : settingValues.subtitleBackgroundColor =
                          currentColor.toString();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('player_settings'),
        ),
      ),
      body: AppResponsiveContent(
        maxWidth: 760,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
                child: Text(
                  tr('subtitle'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        height: 250,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            Image.asset('assets/images/sample_frame.jpg',
                                fit: BoxFit.cover),
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: Text(tr('sample_player_text'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      backgroundColor: backgroundColor,
                                      color: foregroundColor,
                                      fontFamily: st == 'regular'
                                          ? 'Figtree'
                                          : st == 'bold'
                                              ? 'FigtreeSB'
                                              : 'FigtreeLight',
                                      fontSize: settingValues.subtitleFontSize
                                          .toDouble())),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('text_size'),
                            style: kTextSmallBodyStyle,
                          ),
                          Text(
                            settingValues.subtitleFontSize.toString(),
                            style: kTextSmallBodyStyle,
                          )
                        ],
                      ),
                      Slider(
                        value: settingValues.subtitleFontSize.toDouble(),
                        onChanged: (value) {
                          settingValues.subtitleFontSize = value.toInt();
                        },
                        min: 5,
                        max: 30,
                        label: '${settingValues.subtitleFontSize.toInt()}',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('text_color'),
                            style: kTextSmallBodyStyle,
                          ),
                          GestureDetector(
                            onTap: () => colorPickerDialog(1),
                            child: Container(
                              height: 30,
                              width: 60,
                              color: foregroundColor,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('background_color'),
                            style: kTextSmallBodyStyle,
                          ),
                          GestureDetector(
                            onTap: () => colorPickerDialog(2),
                            child: Container(
                              height: 30,
                              width: 60,
                              color: backgroundColor,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _PlayerChoiceTile<String>(
                        title: tr('text_weight'),
                        value: settingValues.subtitleTextStyle,
                        options: {
                          'light': tr('light'),
                          'regular': tr('regular'),
                          'bold': tr('bold'),
                        },
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) => setState(
                          () => settingValues.subtitleTextStyle = value,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
                child: Text(
                  tr('general'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: settingValues.defaultViewMode,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF9B9B9B),
                      secondary: Icon(
                        PhosphorIcons.arrowsOut(),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        tr('auto_full_screen'),
                      ),
                      onChanged: ((value) {
                        setState(() {
                          settingValues.defaultViewMode = value;
                        });
                      }),
                    ),
                    _PlayerChoiceTile<int>(
                      icon: PhosphorIcons.arrowsClockwise(),
                      title: tr('seek_second'),
                      value: settingValues.defaultSeekDuration,
                      options: const {
                        5: '5s',
                        10: '10s',
                        15: '15s',
                        20: '20s',
                        30: '30s',
                      },
                      onChanged: (value) => setState(
                        () => settingValues.defaultSeekDuration = value,
                      ),
                    ),
                    _PlayerChoiceTile<int>(
                      icon: PhosphorIcons.spinner(),
                      title: tr('buffer_amount'),
                      value: settingValues.defaultMaxBufferDuration,
                      options: const {
                        15000: '15s',
                        30000: '30s',
                        45000: '45s',
                        60000: '60s',
                        90000: '90s',
                        120000: '120s',
                        150000: '150s',
                        180000: '180s',
                        240000: '240s',
                        300000: '300s',
                        360000: '360s',
                        420000: '420s',
                        500000: '500s',
                        600000: '600s',
                      },
                      onChanged: (value) => setState(
                        () => settingValues.defaultMaxBufferDuration = value,
                      ),
                    ),
                    _PlayerChoiceTile<int>(
                      icon: PhosphorIcons.filmStrip(),
                      title: tr('video_resolution'),
                      value: settingValues.defaultVideoResolution,
                      options: {
                        0: tr('auto'),
                        360: '360p',
                        720: '720p',
                        1080: '1080p',
                      },
                      onChanged: (value) => setState(
                        () => settingValues.defaultVideoResolution = value,
                      ),
                    ),
                    _PlayerChoiceTile<int>(
                      icon: PhosphorIcons.clock(PhosphorIconsStyle.fill),
                      title: tr('player_time_display'),
                      value: settingValues.playerTimeDisplay,
                      options: {
                        1: tr('elapsed_total'),
                        2: tr('elapsed_remaining'),
                      },
                      onChanged: (value) => setState(
                        () => settingValues.playerTimeDisplay = value,
                      ),
                    ),
                    SwitchListTile(
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF9B9B9B),
                      secondary: Icon(
                        PhosphorIcons.translate(),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: settingValues.fetchSpecificLangSubs,
                      title: Text(tr('fetch_all_subs')),
                      onChanged: ((value) {
                        setState(() {
                          settingValues.fetchSpecificLangSubs = value;
                        });
                      }),
                    ),
                    SwitchListTile(
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF9B9B9B),
                      secondary: Icon(
                        PhosphorIcons.fastForward(),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      value: settingValues.enableNextEpisodeButton,
                      title: Text(tr('enable_next_episode_button')),
                      onChanged: ((value) {
                        setState(() {
                          settingValues.enableNextEpisodeButton = value;
                        });
                      }),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: ((context) {
                          return const SubLangChoose();
                        })));
                      },
                      leading: Icon(
                        PhosphorIcons.closedCaptioning(),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        tr('subtitle_language'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerChoiceTile<T> extends StatelessWidget {
  const _PlayerChoiceTile({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.contentPadding,
  });

  final IconData? icon;
  final String title;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      onTap: () => _showChoices(context),
      leading: icon == null
          ? null
          : Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              options[value] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Icon(PhosphorIcons.caretRight()),
        ],
      ),
    );
  }

  Future<void> _showChoices(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  for (final option in options.entries)
                    ListTile(
                      title: Text(option.value),
                      trailing: option.key == value
                          ? Icon(
                              PhosphorIcons.check(),
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, option.key),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) onChanged(selected);
  }
}
