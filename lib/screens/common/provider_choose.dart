import 'package:easy_localization/easy_localization.dart';
import 'package:flixquest/provider/settings_provider.dart';
import 'package:flixquest/video_providers/names.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../functions/function.dart';

class ProviderChooseScreen extends StatelessWidget {
  const ProviderChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('choose_provider_order')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RearrangeableListView(),
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 300,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10)),
                width: double.infinity,
                child: Stack(
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            tr('provider_precedence_help'),
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RearrangeableListView extends StatefulWidget {
  const RearrangeableListView({super.key});

  @override
  RearrangeableListViewState createState() => RearrangeableListViewState();
}

class RearrangeableListViewState extends State<RearrangeableListView> {
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  @override
  void initState() {
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) => provider != null)
            .cast<VideoProvider>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final VideoProvider item = videoProviders.removeAt(oldIndex);
            videoProviders.insert(newIndex, item);
          });

          String prov = '';
          for (int i = 0; i < videoProviders.length; i++) {
            prov +=
                '${videoProviders[i].codeName}-${videoProviders[i].fullName} ';
          }
          prefString.proPreference = prov;
        },
        onReorderEnd: (index) {},
        children: [
          for (int index = 0; index < videoProviders.length; index++)
            Column(
              key: Key('${videoProviders[index].codeName}_column'),
              children: [
                ListTile(
                  key: Key(videoProviders[index].codeName),
                  title:
                      Text('${index + 1}) ${videoProviders[index].fullName}'),
                ),
                if (index < videoProviders.length - 1)
                  const Divider(thickness: 3),
              ],
            ),
        ]);
  }
}
