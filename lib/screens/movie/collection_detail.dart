import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../functions/function.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/models/movie.dart';
import '/widgets/movie_widgets.dart';

class CollectionDetailsWidget extends StatefulWidget {
  final BelongsToCollection? belongsToCollection;

  const CollectionDetailsWidget({
    Key? key,
    this.belongsToCollection,
  }) : super(key: key);
  @override
  CollectionDetailsWidgetState createState() => CollectionDetailsWidgetState();
}

class CollectionDetailsWidgetState extends State<CollectionDetailsWidget>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CollectionDetailsWidget> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Scaffold(
        body: CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 1,
          shadowColor: themeMode == 'dark' || themeMode == 'amoled'
              ? Colors.white
              : Colors.black,
          forceElevated: true,
          backgroundColor: themeMode == 'dark' || themeMode == 'amoled'
              ? Colors.black
              : Colors.white,
          leading: SABTN(
            onBack: () {
              Navigator.pop(context);
            },
          ),
          title: SABT(
              child: Text(
            widget.belongsToCollection!.name!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          )),
          expandedHeight: 320,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Column(
              children: [
                SizedBox(
                  height: 310,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black,
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent
                                  ],
                                ).createShader(Rect.fromLTRB(
                                    0, 0, rect.width, rect.height));
                              },
                              blendMode: BlendMode.dstIn,
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.transparent)),
                                ),
                                child: SizedBox(
                                  height: 220,
                                  child: Stack(
                                    children: [
                                      PageView.builder(
                                        itemBuilder: (context, index) {
                                          return widget.belongsToCollection!
                                                      .backdropPath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedNetworkImage(
                                                  cacheManager: cacheProp(),
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Image.asset(
                                                    'assets/images/loading_5.gif',
                                                    fit: BoxFit.cover,
                                                  ),
                                                  imageUrl:
                                                      '${buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled, context)}original/${widget.belongsToCollection!.backdropPath!}',
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // poster and title movie details
                      Positioned(
                        bottom: 0.0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              // poster
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 94,
                                        height: 140,
                                        child: widget.belongsToCollection!
                                                    .posterPath ==
                                                null
                                            ? Image.asset(
                                                'assets/images/na_logo.png',
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                cacheManager: cacheProp(),
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) =>
                                                    scrollingImageShimmer(
                                                        themeMode),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                ),
                                                imageUrl: buildImageUrl(
                                                        TMDB_BASE_IMAGE_URL,
                                                        proxyUrl,
                                                        isProxyEnabled,
                                                        context) +
                                                    imageQuality +
                                                    widget.belongsToCollection!
                                                        .posterPath!,
                                              ),
                                      ),
                                    ),
                                  )),
                              const SizedBox(width: 16),
                              //  titles
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        // _utilityController.toggleTitleVisibility();
                                      },
                                      child: Text(
                                        widget.belongsToCollection!.name!,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'PoppinsSB'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // body
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              const LeadingDot(),
                              Text(
                                tr('overview'),
                                style: kTextHeaderStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CollectionOverviewWidget(
                        api: Endpoints.getCollectionDetails(
                            widget.belongsToCollection!.id!, lang),
                      ),
                      // child: CollectionOverviewWidget(),
                    ),
                    PartsList(
                      title: tr('movies'),
                      api: Endpoints.getCollectionDetails(
                          widget.belongsToCollection!.id!, lang),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
