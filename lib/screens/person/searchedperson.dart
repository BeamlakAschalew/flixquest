import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/person.dart';
import '/provider/settings_provider.dart';
import '/widgets/person_widgets.dart';

class SearchedPersonDetailPage extends StatefulWidget {
  final Person? person;
  final String heroId;

  const SearchedPersonDetailPage({
    super.key,
    this.person,
    required this.heroId,
  });

  @override
  SearchedPersonDetailPageState createState() =>
      SearchedPersonDetailPageState();
}

class SearchedPersonDetailPageState extends State<SearchedPersonDetailPage>
    with AutomaticKeepAliveClientMixin<SearchedPersonDetailPage> {
  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    Provider.of<SettingsProvider>(context, listen: false)
        .analytics
        .trackPersonPageView(
          personName: widget.person!.name,
          personId: widget.person!.id,
          isAdult: widget.person!.adult,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PersonDetailView(
      personId: widget.person!.id!,
      name: widget.person!.name ?? '',
      subtitle: widget.person!.department,
      profilePath: widget.person!.profilePath,
      heroId: widget.heroId,
      isPersonAdult: widget.person!.adult,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
