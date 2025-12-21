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
        title: Text(
          tr('choose_provider_order'),
          style: const TextStyle(
            fontFamily: 'FigtreeSB',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RearrangeableListView(),
              const SizedBox(
                height: 24,
              ),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr('provider_precedence_help'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Figtree',
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
            Container(
              key: Key(videoProviders[index].codeName),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: 'FigtreeSB',
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  videoProviders[index].fullName,
                  style: const TextStyle(
                    fontFamily: 'FigtreeSB',
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(
                  Icons.drag_handle_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ]);
  }
}
