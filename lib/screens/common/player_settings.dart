import 'package:flixquest/screens/common/provider_choose.dart';

import '../../screens/common/sublanguage_choose.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class PlayerSettings extends StatefulWidget {
  const PlayerSettings({Key? key}) : super(key: key);

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const LeadingDot(),
                  Expanded(
                    child: Text(
                      tr('subtitle'),
                      style: kTextHeaderStyle,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                height: 250,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Image.asset('assets/images/sample_frame.jpg'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
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
                              fontSize:
                                  settingValues.subtitleFontSize.toDouble())),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('text_weight'),
                    style: kTextSmallBodyStyle,
                  ),
                  DropdownButton(
                      value: settingValues.subtitleTextStyle,
                      items: [
                        DropdownMenuItem(
                            value: 'light', child: Text(tr('light'))),
                        DropdownMenuItem(
                            value: 'regular', child: Text(tr('regular'))),
                        DropdownMenuItem(
                            value: 'bold', child: Text(tr('bold'))),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          settingValues.subtitleTextStyle = value!;
                        });
                      }),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  const LeadingDot(),
                  Expanded(
                    child: Text(
                      tr('general'),
                      style: kTextHeaderStyle,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: settingValues.defaultViewMode,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF9B9B9B),
                secondary: Icon(
                  FontAwesomeIcons.expand,
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
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.rotateRight,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  tr('seek_second'),
                ),
                trailing: DropdownButton(
                    value: settingValues.defaultSeekDuration,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5s')),
                      DropdownMenuItem(value: 10, child: Text('10s')),
                      DropdownMenuItem(value: 15, child: Text('15s')),
                      DropdownMenuItem(value: 20, child: Text('20s')),
                      DropdownMenuItem(value: 30, child: Text('30s'))
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        settingValues.defaultSeekDuration = value!;
                      });
                    }),
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.spinner,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  tr('buffer_amount'),
                ),
                trailing: DropdownButton(
                    value: settingValues.defaultMaxBufferDuration,
                    items: [
                      DropdownMenuItem(
                          value: const Duration(seconds: 15).inMilliseconds,
                          child: const Text('15s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 30).inMilliseconds,
                          child: const Text('30s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 45).inMilliseconds,
                          child: const Text('45s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 60).inMilliseconds,
                          child: const Text('60s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 90).inMilliseconds,
                          child: const Text('90s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 120).inMilliseconds,
                          child: const Text('120s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 150).inMilliseconds,
                          child: const Text('150s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 180).inMilliseconds,
                          child: const Text('180s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 240).inMilliseconds,
                          child: const Text('240s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 300).inMilliseconds,
                          child: const Text('300s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 360).inMilliseconds,
                          child: const Text('360s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 420).inMilliseconds,
                          child: const Text('420s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 500).inMilliseconds,
                          child: const Text('500s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 600).inMilliseconds,
                          child: const Text('600s')),
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        settingValues.defaultMaxBufferDuration = value!;
                      });
                    }),
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.fileVideo,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  tr('video_resolution'),
                ),
                trailing: DropdownButton(
                    value: settingValues.defaultVideoResolution,
                    items: [
                      DropdownMenuItem(
                          value: 0,
                          child: Text(
                            tr('auto'),
                          )),
                      const DropdownMenuItem(value: 360, child: Text('360p')),
                      const DropdownMenuItem(value: 720, child: Text('720p')),
                      const DropdownMenuItem(value: 1080, child: Text('1080p')),
                    ],
                    onChanged: (int? value) {
                      settingValues.defaultVideoResolution = value!;
                    }),
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.solidClock,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  tr('player_time_display'),
                ),
                trailing: DropdownButton(
                    value: settingValues.playerTimeDisplay,
                    items: [
                      DropdownMenuItem(
                          value: 1, child: Text(tr('elapsed_total'))),
                      DropdownMenuItem(
                          value: 2, child: Text(tr('elapsed_remaining'))),
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        settingValues.playerTimeDisplay = value!;
                      });
                    }),
              ),
              SwitchListTile(
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF9B9B9B),
                secondary: Icon(
                  FontAwesomeIcons.language,
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
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return const SubLangChoose();
                  })));
                },
                leading: Icon(
                  FontAwesomeIcons.closedCaptioning,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  tr('subtitle_language'),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return const ProviderChooseScreen();
                  })));
                },
                leading: Icon(
                  FontAwesomeIcons.server,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  tr('provider_precedence'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
