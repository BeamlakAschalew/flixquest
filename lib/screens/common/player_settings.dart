import 'package:cinemax/screens/common/sublanguage_choose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_constants.dart';
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
    final seekSecond = Provider.of<SettingsProvider>(context);
    final bufferAmount = Provider.of<SettingsProvider>(context);
    final videoResolution = Provider.of<SettingsProvider>(context);
    final videoOrientation = Provider.of<SettingsProvider>(context);
    // final subtitleLanguage = Provider.of<SettingsProvider>(context);
    String backgroundColorString = videoOrientation.subtitleBackgroundColor;
    String foregroundColorString = videoOrientation.subtitleForegroundColor;
    String hexColorBackground =
        backgroundColorString.replaceAll("Color(0x", "").replaceAll(")", "");
    String hexColorForeground =
        foregroundColorString.replaceAll("Color(0x", "").replaceAll(")", "");

    Color backgroundColor = Color(int.parse("0x$hexColorBackground"));
    Color foregroundColor = Color(int.parse("0x$hexColorForeground"));

    Color pickerColor = const Color(0xff443a49);
    Color currentColor = const Color(0xff443a49);

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
                child: const Text('Save'),
                onPressed: () {
                  setState(() => currentColor = pickerColor);
                  type == 1
                      ? videoOrientation.subtitleForegroundColor =
                          currentColor.toString()
                      : videoOrientation.subtitleBackgroundColor =
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
        title: const Text('Player settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subtitle',
                style: kTextHeaderStyle,
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
                      child: Text('I\'m looking for your syptoms on WebMd',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              backgroundColor: backgroundColor,
                              color: foregroundColor,
                              fontSize: videoOrientation.subtitleFontSize
                                  .toDouble())),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Text size',
                    style: kTextSmallBodyStyle,
                  ),
                  Text(
                    videoOrientation.subtitleFontSize.toString(),
                    style: kTextSmallBodyStyle,
                  )
                ],
              ),
              Slider(
                value: videoOrientation.subtitleFontSize.toDouble(),
                onChanged: (value) {
                  videoOrientation.subtitleFontSize = value.toInt();
                },
                min: 5,
                max: 30,
                label: '${videoOrientation.subtitleFontSize.toInt()}',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Text color',
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
                  const Text(
                    'Background color',
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
                height: 25,
              ),
              const Text(
                'General',
                style: kTextHeaderStyle,
              ),
              ListTile(
                  leading: const Icon(Icons.fullscreen),
                  title: const Text('Auto full screen'),
                  trailing: Switch(
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFF9B9B9B),
                    value: videoOrientation.defaultViewMode,
                    onChanged: ((value) {
                      setState(() {
                        videoOrientation.defaultViewMode = value;
                      });
                    }),
                  )),
              ListTile(
                leading: const Icon(Icons.forward_10),
                title: const Text('Seek second'),
                trailing: DropdownButton(
                    value: seekSecond.defaultSeekDuration,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5s')),
                      DropdownMenuItem(value: 10, child: Text('10s')),
                      DropdownMenuItem(value: 15, child: Text('15s')),
                      DropdownMenuItem(value: 20, child: Text('20s')),
                      DropdownMenuItem(value: 30, child: Text('30s'))
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        seekSecond.defaultSeekDuration = value!;
                      });
                    }),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.spinner),
                title: const Text('Buffer amount'),
                trailing: DropdownButton(
                    value: bufferAmount.defaultMaxBufferDuration,
                    items: [
                      DropdownMenuItem(
                          value: const Duration(seconds: 15).inMilliseconds,
                          child: const Text('15s')),
                      DropdownMenuItem(
                          value: const Duration(seconds: 15).inMilliseconds,
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
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        bufferAmount.defaultMaxBufferDuration = value!;
                      });
                    }),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.fileVideo),
                title: const Text('Video resolution'),
                trailing: DropdownButton(
                    value: videoResolution.defaultVideoResolution,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Auto')),
                      DropdownMenuItem(value: 360, child: Text('360p')),
                      DropdownMenuItem(value: 720, child: Text('720p')),
                      DropdownMenuItem(value: 1080, child: Text('1080p')),
                    ],
                    onChanged: (int? value) {
                      videoResolution.defaultVideoResolution = value!;
                    }),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return const SubLangChoose();
                  })));
                },
                leading: const Icon(FontAwesomeIcons.closedCaptioning),
                title: const Text('Subtitle language'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
