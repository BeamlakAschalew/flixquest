// ignore_for_file: avoid_unnecessary_containers
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/movie_widgets.dart';
import '/models/tv.dart';
import 'package:flutter/material.dart';
import '/widgets/person_widgets.dart';

class CreatedByPersonDetailPage extends StatefulWidget {
  final CreatedBy? createdBy;
  final String heroId;

  const CreatedByPersonDetailPage({
    Key? key,
    this.createdBy,
    required this.heroId,
  }) : super(key: key);
  @override
  CreatedByPersonDetailPageState createState() =>
      CreatedByPersonDetailPageState();
}

class CreatedByPersonDetailPageState extends State<CreatedByPersonDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CreatedByPersonDetailPage> {
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
      'Person name': '${widget.createdBy!.name}',
      'Person id': '${widget.createdBy!.id}'
    });
  }

  int selectedIndex = 0;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: themeMode == "dark" || themeMode == "amoled"
                ? Colors.white
                : Colors.black,
            forceElevated: true,
            backgroundColor: themeMode == "dark" || themeMode == "amoled"
                ? Colors.black
                : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.createdBy!.name!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )),
            expandedHeight: 210,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  CreatedByQuickInfo(
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
                CreatedByAbout(
                    createdBy: widget.createdBy,
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
