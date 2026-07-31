import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/tv.dart';
import '/provider/settings_provider.dart';
import '/widgets/person_widgets.dart';

class CreatedByPersonDetailPage extends StatefulWidget {
  final CreatedBy? createdBy;
  final String heroId;

  const CreatedByPersonDetailPage({
    super.key,
    this.createdBy,
    required this.heroId,
  });

  @override
  CreatedByPersonDetailPageState createState() =>
      CreatedByPersonDetailPageState();
}

class CreatedByPersonDetailPageState extends State<CreatedByPersonDetailPage>
    with AutomaticKeepAliveClientMixin<CreatedByPersonDetailPage> {
  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    Provider.of<SettingsProvider>(context, listen: false)
        .analytics
        .trackPersonPageView(
          personName: widget.createdBy!.name,
          personId: widget.createdBy!.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PersonDetailView(
      personId: widget.createdBy!.id!,
      name: widget.createdBy!.name ?? '',
      profilePath: widget.createdBy!.profilePath,
      heroId: widget.heroId,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
