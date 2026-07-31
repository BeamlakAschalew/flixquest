import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/credits.dart';
import '/provider/settings_provider.dart';
import '/widgets/person_widgets.dart';

class GuestStarDetailPage extends StatefulWidget {
  final TVEpisodeGuestStars? cast;
  final String heroId;

  const GuestStarDetailPage({
    super.key,
    this.cast,
    required this.heroId,
  });

  @override
  GuestStarDetailPageState createState() => GuestStarDetailPageState();
}

class GuestStarDetailPageState extends State<GuestStarDetailPage>
    with AutomaticKeepAliveClientMixin<GuestStarDetailPage> {
  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    Provider.of<SettingsProvider>(context, listen: false)
        .analytics
        .trackPersonPageView(
          personName: widget.cast!.name,
          personId: widget.cast!.id,
        );
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
