import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/credits.dart';
import '/provider/settings_provider.dart';
import '/widgets/person_widgets.dart';

class CastDetailPage extends StatefulWidget {
  final Cast? cast;
  final String heroId;

  const CastDetailPage({
    super.key,
    this.cast,
    required this.heroId,
  });

  @override
  CastDetailPageState createState() => CastDetailPageState();
}

class CastDetailPageState extends State<CastDetailPage>
    with AutomaticKeepAliveClientMixin<CastDetailPage> {
  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed person pages', properties: {
      'Person name': '${widget.cast!.name}',
      'Person id': '${widget.cast!.id}'
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PersonDetailView(
      personId: widget.cast!.id!,
      name: widget.cast!.name ?? '',
      subtitle: widget.cast!.character?.isNotEmpty == true
          ? widget.cast!.character
          : widget.cast!.department,
      profilePath: widget.cast!.profilePath,
      heroId: widget.heroId,
      isPersonAdult: widget.cast!.adult,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
