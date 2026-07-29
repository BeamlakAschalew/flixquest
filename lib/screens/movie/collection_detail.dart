import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../functions/function.dart';
import '../../functions/network.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/app_ui_components.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/models/movie.dart';
import 'movie_detail.dart';

class CollectionDetailsWidget extends StatefulWidget {
  final BelongsToCollection? belongsToCollection;

  const CollectionDetailsWidget({
    super.key,
    this.belongsToCollection,
  });

  @override
  CollectionDetailsWidgetState createState() => CollectionDetailsWidgetState();
}

class CollectionDetailsWidgetState extends State<CollectionDetailsWidget>
    with AutomaticKeepAliveClientMixin<CollectionDetailsWidget> {
  final ScrollController _scrollController = ScrollController();

  late Future<CollectionDetails> _details;
  late Future<List<Movie>> _parts;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final dependencies =
        Provider.of<AppDependencyProvider>(context, listen: false);
    final api = Endpoints.getCollectionDetails(
        widget.belongsToCollection!.id!, settings.appLanguage);
    _details = fetchCollectionDetails(
        api, settings.enableProxy, dependencies.tmdbProxy);
    _parts = fetchCollectionMovies(
        api, settings.enableProxy, dependencies.tmdbProxy);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final collection = widget.belongsToCollection!;
    final heroHeight =
        (MediaQuery.sizeOf(context).height * .32).clamp(220.0, 320.0);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: heroHeight,
            toolbarHeight: 64,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 4,
            leadingWidth: 68,
            leading: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: _CollectionHeroButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: PhosphorIcons.caretLeft(),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final collapseAt = heroHeight -
                    kToolbarHeight -
                    MediaQuery.paddingOf(context).top -
                    12;
                final visible = _scrollController.hasClients &&
                    _scrollController.offset >= collapseAt;
                return AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Text(
                    collection.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'FigtreeSB',
                        ),
                  ),
                );
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [StretchMode.zoomBackground],
              background: _CollectionBackdrop(collection: collection),
            ),
          ),
          SliverToBoxAdapter(
            child: AppResponsiveContent(
              padding: EdgeInsets.fromLTRB(
                AppUI.pagePadding(context),
                22,
                AppUI.pagePadding(context),
                40 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CollectionSummary(collection: collection),
                  const SizedBox(height: 24),
                  Text(
                    tr('overview'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _CollectionOverview(details: _details),
                  const SizedBox(height: 28),
                  Text(
                    tr('movies'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _CollectionParts(parts: _parts),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CollectionBackdrop extends StatelessWidget {
  const _CollectionBackdrop({required this.collection});

  final BelongsToCollection collection;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dependencies = Provider.of<AppDependencyProvider>(context);
    final path = collection.backdropPath;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (path == null)
          Image.asset('assets/images/na_logo.png', fit: BoxFit.cover)
        else
          CachedNetworkImage(
            cacheManager: cacheProp(),
            imageUrl:
                '${buildImageUrl(TMDB_BASE_IMAGE_URL, dependencies.tmdbProxy, settings.enableProxy, context)}original$path',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            placeholder: (_, __) => const AppShimmerBlock(radius: 0),
            errorWidget: (_, __, ___) =>
                Image.asset('assets/images/na_logo.png', fit: BoxFit.cover),
          ),
        const AppDetailHeroGradient(),
      ],
    );
  }
}

class _CollectionSummary extends StatelessWidget {
  const _CollectionSummary({required this.collection});

  final BelongsToCollection collection;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dependencies = Provider.of<AppDependencyProvider>(context);
    final path = collection.posterPath;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          height: 144,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppUI.cardRadius),
            child: path == null
                ? Image.asset('assets/images/na_logo.png', fit: BoxFit.cover)
                : CachedNetworkImage(
                    cacheManager: cacheProp(),
                    imageUrl: buildImageUrl(
                          TMDB_BASE_IMAGE_URL,
                          dependencies.tmdbProxy,
                          settings.enableProxy,
                          context,
                        ) +
                        settings.imageQuality +
                        path,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const AppShimmerBlock(),
                    errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/na_logo.png',
                        fit: BoxFit.cover),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              collection.name ?? '',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionOverview extends StatelessWidget {
  const _CollectionOverview({required this.details});

  final Future<CollectionDetails> details;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<CollectionDetails>(
      future: details,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Column(
            children: [
              SizedBox(height: 13, child: AppShimmerBlock(radius: 6)),
              SizedBox(height: 9),
              SizedBox(height: 13, child: AppShimmerBlock(radius: 6)),
              SizedBox(height: 9),
              SizedBox(
                height: 13,
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: .6,
                  child: AppShimmerBlock(radius: 6),
                ),
              ),
            ],
          );
        }
        final overview = snapshot.data?.overview?.trim() ?? '';
        return Text(
          overview.isEmpty ? tr('no_overview_movie') : overview,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
        );
      },
    );
  }
}

class _CollectionParts extends StatelessWidget {
  const _CollectionParts({required this.parts});

  final Future<List<Movie>> parts;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dependencies = Provider.of<AppDependencyProvider>(context);
    return FutureBuilder<List<Movie>>(
      future: parts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppUI.mediaGridColumns(context),
              childAspectRatio: AppUI.mediaGridChildAspectRatio(context),
              crossAxisSpacing: AppUI.mediaGridCrossAxisSpacing,
              mainAxisSpacing: 16,
            ),
            itemCount: AppUI.mediaGridColumns(context),
            itemBuilder: (_, __) => const AspectRatio(
              aspectRatio: AppUI.posterAspectRatio,
              child: AppShimmerBlock(),
            ),
          );
        }
        final movies = snapshot.data!;
        if (movies.isEmpty) {
          return AppEmptyState(
            icon: PhosphorIcons.filmStrip(),
            title: tr('movies'),
            message: tr('no_genre_movie'),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppUI.mediaGridColumns(context),
            childAspectRatio: AppUI.mediaGridChildAspectRatio(context),
            crossAxisSpacing: AppUI.mediaGridCrossAxisSpacing,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(
                    movie: movie,
                    heroId: 'collection_${movie.id}',
                  ),
                ),
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: AppUI.posterAspectRatio,
                    child: Hero(
                      tag: 'collection_${movie.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppUI.cardRadius),
                                child: movie.posterPath == null
                                    ? Image.asset('assets/images/na_logo.png',
                                        fit: BoxFit.cover)
                                    : CachedNetworkImage(
                                        cacheManager: cacheProp(),
                                        imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              dependencies.tmdbProxy,
                                              settings.enableProxy,
                                              context,
                                            ) +
                                            settings.imageQuality +
                                            movie.posterPath!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const AppShimmerBlock(),
                                        errorWidget: (_, __, ___) =>
                                            Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                            PositionedDirectional(
                              top: 8,
                              start: 8,
                              child: AppRatingBadge(
                                  rating: movie.voteAverage, compact: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppUI.mediaGridTitleGap),
                  SizedBox(
                    width: double.infinity,
                    height: AppUI.mediaGridTitleHeight,
                    child: Text(
                      movie.title ?? movie.originalTitle ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontFamily: 'FigtreeSB',
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CollectionHeroButton extends StatelessWidget {
  const _CollectionHeroButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 42,
        child: Material(
          color: Colors.black.withValues(alpha: .38),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            color: Colors.white,
            padding: EdgeInsets.zero,
            icon: Icon(icon, size: 21),
          ),
        ),
      ),
    );
  }
}
