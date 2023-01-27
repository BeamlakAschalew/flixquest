// ignore_for_file: avoid_unnecessary_containers

import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/movie_widgets.dart';
import '/models/person.dart';
import 'package:flutter/material.dart';
import '/widgets/person_widgets.dart';

class SearchedPersonDetailPage extends StatefulWidget {
  final Person? person;
  final String heroId;

  const SearchedPersonDetailPage({
    Key? key,
    this.person,
    required this.heroId,
  }) : super(key: key);
  @override
  SearchedPersonDetailPageState createState() =>
      SearchedPersonDetailPageState();
}

class SearchedPersonDetailPageState extends State<SearchedPersonDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SearchedPersonDetailPage> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed person pages', properties: {
      'Person name': '${widget.person!.name}',
      'Person id': '${widget.person!.id}',
      'Is Person adult?': '${widget.person!.adult}'
    });
  }

  int selectedIndex = 0;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: isDark ? Colors.white : Colors.black,
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.person!.name!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 210,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  SearchedPersonQuickInfo(
                    widget: widget,
                    imageQuality: imageQuality,
                  )
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                SearchedPersonAbout(
                    person: widget.person,
                    selectedIndex: selectedIndex,
                    tabController: tabController)
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
