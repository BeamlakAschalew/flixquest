import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/credits.dart';
import '/provider/settings_provider.dart';
import '/widgets/person_widgets.dart';

class CrewDetailPage extends StatefulWidget {
  final String heroId;
  final Crew? crew;

  const CrewDetailPage({
    super.key,
    this.crew,
    required this.heroId,
  });

  @override
  CrewDetailPageState createState() => CrewDetailPageState();
}

class CrewDetailPageState extends State<CrewDetailPage>
    with AutomaticKeepAliveClientMixin<CrewDetailPage> {
  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed person pages', properties: {
      'Person name': '${widget.crew!.name}',
      'Person id': '${widget.crew!.id}'
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PersonDetailView(
      personId: widget.crew!.id!,
      name: widget.crew!.name ?? '',
      subtitle: widget.crew!.job?.isNotEmpty == true
          ? widget.crew!.job
          : widget.crew!.department,
      profilePath: widget.crew!.profilePath,
      heroId: widget.heroId,
      isPersonAdult: widget.crew!.adult,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
