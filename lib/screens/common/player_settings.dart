import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    // final subtitleLanguage = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player settings'),
      ),
      body: Column(
        children: [
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
          const ListTile(
            leading: Icon(FontAwesomeIcons.closedCaptioning),
            title: Text('Subtitle language'),
          )
        ],
      ),
    );
  }
}
