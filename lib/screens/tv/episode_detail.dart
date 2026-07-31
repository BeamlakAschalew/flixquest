// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../provider/settings_provider.dart';
import '/models/tv.dart';
import 'package:flutter/material.dart';
import '../../api/endpoints.dart';
import '../../ui_components/app_ui_components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:readmore/readmore.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../functions/function.dart';
import '../../provider/app_dependency_provider.dart';
import '../../functions/network.dart';
import '../../models/credits.dart';
import '../../models/images.dart';
import '../person/cast_detail.dart';
import 'tvepisode_castandcrew.dart';
import '../../models/tv_stream_metadata.dart';
import '../../services/globle_method.dart';
import 'tv_video_loader.dart';

class EpisodeDetailPage extends StatefulWidget {
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  const EpisodeDetailPage({
    super.key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  });

  @override
  EpisodeDetailPageState createState() => EpisodeDetailPageState();
}

class EpisodeDetailPageState extends State<EpisodeDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<EpisodeDetailPage> {
  bool? isVisible = false;
  double? buttonWidth = 150;
  final scrollController = ScrollController();
  late Future<Credits> _credits;
  late Future<Images> _images;

  @override
  void initState() {
    super.initState();
    _loadData();
    mixpanelUpload(context);
  }

  void _loadData() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final proxy =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    final tvId = widget.tvId;
    final season = widget.episodeList.seasonNumber;
    final episode = widget.episodeList.episodeNumber;
    if (tvId == null || season == null || episode == null) {
      _credits = Future.value(Credits());
      _images = Future.value(Images());
      return;
    }
    _credits = fetchCredits(
      Endpoints.getEpisodeCredits(
        tvId,
        season,
        episode,
        settings.appLanguage,
      ),
      settings.enableProxy,
      proxy,
    );
    _images = fetchImages(
      Endpoints.getTVEpisodeImagesUrl(tvId, season, episode),
      settings.enableProxy,
      proxy,
    );
  }

  void mixpanelUpload(BuildContext context) {
    Provider.of<SettingsProvider>(context, listen: false)
        .analytics
        .trackEpisodeDetailView(
          tvName: widget.seriesName,
          episodeName: widget.episodeList.name,
        );
  }

  Future<void> _watchNow() async {
    if (!await checkConnection()) {
      if (!mounted) return;
      GlobalMethods.showCustomScaffoldMessage(
        SnackBar(content: Text(tr('check_connection'), maxLines: 3)),
        context,
      );
      return;
    }
    if (!mounted || widget.tvId == null || widget.posterPath == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TVVideoLoader(
          download: false,
          metadata: TVStreamMetadata(
            elapsed: null,
            episodeId: widget.episodeList.episodeId,
            episodeName: widget.episodeList.name,
            episodeNumber: widget.episodeList.episodeNumber!,
            posterPath: widget.posterPath!,
            backdropPath: widget.episodeList.stillPath,
            seasonNumber: widget.episodeList.seasonNumber!,
            seriesName: widget.seriesName ?? '',
            tvId: widget.tvId!,
            airDate: widget.episodeList.airDate,
          ),
        ),
      ),
    );
  }

  Future<void> _download() async {
    if (!await checkConnection()) {
      if (!mounted) return;
      GlobalMethods.showCustomScaffoldMessage(
        SnackBar(content: Text(tr('check_connection'), maxLines: 3)),
        context,
      );
      return;
    }
    if (!mounted || widget.tvId == null || widget.posterPath == null) return;
    final queued = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TVVideoLoader(
          download: true,
          metadata: TVStreamMetadata(
            elapsed: null,
            episodeId: widget.episodeList.episodeId,
            episodeName: widget.episodeList.name,
            episodeNumber: widget.episodeList.episodeNumber!,
            posterPath: widget.posterPath!,
            backdropPath: widget.episodeList.stillPath,
            seasonNumber: widget.episodeList.seasonNumber!,
            seriesName: widget.seriesName ?? '',
            tvId: widget.tvId!,
            airDate: widget.episodeList.airDate,
          ),
        ),
      ),
    );
    if (mounted && queued == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to downloads')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final title = widget.episodeList.name ?? tr('episodes');
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 1,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leadingWidth: 68,
            leading: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: _EpisodeBackButton(
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: AnimatedBuilder(
              animation: scrollController,
              builder: (context, _) => AnimatedOpacity(
                opacity:
                    scrollController.hasClients && scrollController.offset > 145
                        ? 1
                        : 0,
                duration: const Duration(milliseconds: 160),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _EpisodeHero(
                path: widget.episodeList.stillPath,
                images: _images,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppResponsiveContent(
              padding: EdgeInsets.fromLTRB(
                AppUI.pagePadding(context),
                18,
                AppUI.pagePadding(context),
                36,
              ),
              child: _EpisodeContent(
                episodeList: widget.episodeList,
                seriesName: widget.seriesName,
                tvId: widget.tvId,
                credits: _credits,
                images: _images,
                canWatch: Provider.of<AppDependencyProvider>(context)
                        .displayWatchNowButton &&
                    widget.posterPath != null &&
                    widget.tvId != null,
                onWatch: _watchNow,
                onDownload: _download,
                onShare: () => Share.share(tr('share_episode', namedArgs: {
                  'title': widget.seriesName ?? '',
                  'rating':
                      (widget.episodeList.voteAverage ?? 0).toStringAsFixed(1),
                  'id': widget.tvId.toString(),
                  'et': title,
                  'season': widget.episodeList.seasonNumber.toString(),
                  'episode': widget.episodeList.episodeNumber.toString(),
                })),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class _EpisodeBackButton extends StatelessWidget {
  const _EpisodeBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox.square(
          dimension: 42,
          child: Material(
            color: Colors.black.withValues(alpha: .38),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              color: Colors.white,
              icon: Icon(PhosphorIcons.caretLeft(), size: 21),
            ),
          ),
        ),
      );
}

class _EpisodeHero extends StatelessWidget {
  const _EpisodeHero({required this.path, required this.images});

  final String? path;
  final Future<Images> images;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final proxy = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return FutureBuilder<Images>(
      future: images,
      builder: (context, snapshot) {
        final paths = <String>{
          if ((path ?? '').isNotEmpty) path!,
          ...?snapshot.data?.still
              ?.map((item) => item.stillPath)
              .whereType<String>(),
          ...?snapshot.data?.backdrop
              ?.map((item) => item.filePath)
              .whereType<String>(),
        }.take(8).toList();
        return Stack(
          fit: StackFit.expand,
          children: [
            if (paths.isEmpty)
              Image.asset('assets/images/na_rect.png', fit: BoxFit.cover)
            else
              AppSwipeCarousel(
                itemCount: paths.length,
                indicatorBottom: 15,
                itemBuilder: (context, index) => CachedNetworkImage(
                  cacheManager: cacheProp(),
                  imageUrl:
                      '${buildImageUrl(TMDB_BASE_IMAGE_URL, proxy, settings.enableProxy, context)}original${paths[index]}',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const AppShimmerBlock(radius: 0),
                  errorWidget: (_, __, ___) => Image.asset(
                      'assets/images/na_rect.png',
                      fit: BoxFit.cover),
                ),
              ),
            // const AppDetailHeroGradient(),
          ],
        );
      },
    );
  }
}

class _EpisodeContent extends StatelessWidget {
  const _EpisodeContent({
    required this.episodeList,
    required this.seriesName,
    required this.tvId,
    required this.credits,
    required this.images,
    required this.canWatch,
    required this.onWatch,
    required this.onDownload,
    required this.onShare,
  });

  final EpisodeList episodeList;
  final String? seriesName;
  final int? tvId;
  final Future<Credits> credits;
  final Future<Images> images;
  final bool canWatch;
  final VoidCallback onWatch;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final season = episodeList.seasonNumber ?? 0;
    final episode = episodeList.episodeNumber ?? 0;
    final airDate = DateTime.tryParse(episodeList.airDate ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'S${season.toString().padLeft(2, '0')}  •  E${episode.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'FigtreeSB',
              ),
        ),
        const SizedBox(height: 7),
        Text(
          episodeList.name ?? tr('episodes'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'FigtreeSB',
                height: 1.12,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          seriesName ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppRatingBadge(rating: episodeList.voteAverage),
                const SizedBox(width: 7),
                Text(
                  tr('rating'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            if (airDate != null)
              _EpisodeMetadataPill(
                icon: PhosphorIcons.calendar(),
                label:
                    DateFormat.yMMMd(context.locale.toString()).format(airDate),
              ),
            _EpisodeMetadataPill(
              icon: PhosphorIcons.users(),
              label: '${episodeList.voteCount ?? 0} ${tr('total_ratings')}',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (canWatch)
              Expanded(
                child: FilledButton.icon(
                  onPressed: onWatch,
                  icon: Icon(PhosphorIcons.playCircle(PhosphorIconsStyle.fill)),
                  label: Text(tr('watch_now')),
                ),
              ),
            if (canWatch) const SizedBox(width: 12),
            if (canWatch)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDownload,
                  icon: Icon(PhosphorIcons.downloadSimple()),
                  label: Text(tr('download')),
                ),
              ),
            if (canWatch) const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: Icon(PhosphorIcons.shareNetwork()),
                label: Text(tr('share')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _EpisodeHeading(title: tr('overview')),
        const SizedBox(height: 10),
        ReadMoreText(
          (episodeList.overview ?? '').isEmpty
              ? tr('no_episode_overview')
              : episodeList.overview!,
          trimLines: 4,
          trimMode: TrimMode.Line,
          trimCollapsedText: ' ${tr('read_more')}',
          trimExpandedText: ' ${tr('read_less')}',
          colorClickableText: Theme.of(context).colorScheme.primary,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 28),
        _EpisodeCastRail(
          credits: credits,
          tvId: tvId,
          seasonNumber: season,
          episodeNumber: episode,
        ),
        const SizedBox(height: 28),
        _EpisodeGallery(images: images),
      ],
    );
  }
}

class _EpisodeHeading extends StatelessWidget {
  const _EpisodeHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'FigtreeSB',
            ),
      );
}

class _EpisodeMetadataPill extends StatelessWidget {
  const _EpisodeMetadataPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _EpisodeCastRail extends StatelessWidget {
  const _EpisodeCastRail({
    required this.credits,
    required this.tvId,
    required this.seasonNumber,
    required this.episodeNumber,
  });

  final Future<Credits> credits;
  final int? tvId;
  final int seasonNumber;
  final int episodeNumber;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Credits>(
      future: credits,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EpisodeSectionHeading(title: tr('cast')),
              const SizedBox(height: 14),
              const _EpisodeCastShimmer(),
            ],
          );
        }
        final cast = <Cast>[
          ...?snapshot.data?.cast,
          ...?snapshot.data?.episodeGuestStars?.map(
            (item) => Cast(
              id: item.id,
              name: item.name,
              character: item.character,
              profilePath: item.profilePath,
              creditId: item.creditId,
              department: item.department,
            ),
          ),
        ];
        if (cast.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EpisodeSectionHeading(
              title: tr('cast'),
              actionLabel: tvId == null ? null : tr('see_all_cast_crew'),
              onAction: tvId == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TVEpisodeCastAndCrew(
                            id: tvId!,
                            seasonNumber: seasonNumber,
                            episodeNumber: episodeNumber,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cast.take(16).length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) =>
                    _EpisodeCastCard(cast: cast[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EpisodeCastCard extends StatelessWidget {
  const _EpisodeCastCard({required this.cast});

  final Cast cast;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final proxy = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final tag = 'episode_cast_${cast.id}_${cast.creditId}';
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CastDetailPage(cast: cast, heroId: tag)),
      ),
      child: SizedBox(
        width: 86,
        child: Column(
          children: [
            Hero(
              tag: tag,
              child: SizedBox.square(
                dimension: 68,
                child: ClipOval(
                  child: (cast.profilePath ?? '').isEmpty
                      ? Image.asset('assets/images/na_rect.png',
                          fit: BoxFit.cover)
                      : CachedNetworkImage(
                          cacheManager: cacheProp(),
                          imageUrl: buildImageUrl(
                                TMDB_BASE_IMAGE_URL,
                                proxy,
                                settings.enableProxy,
                                context,
                              ) +
                              settings.imageQuality +
                              cast.profilePath!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const AppShimmerBlock(radius: 40),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cast.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              cast.character ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeGallery extends StatelessWidget {
  const _EpisodeGallery({required this.images});

  final Future<Images> images;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Images>(
      future: images,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EpisodeSectionHeading(title: tr('images')),
              const SizedBox(height: 14),
              const _EpisodeGalleryShimmer(),
            ],
          );
        }
        final paths = <String>[
          ...?snapshot.data?.still
              ?.map((item) => item.stillPath)
              .whereType<String>(),
          ...?snapshot.data?.backdrop
              ?.map((item) => item.filePath)
              .whereType<String>(),
        ];
        if (paths.isEmpty) return const SizedBox.shrink();
        final settings = Provider.of<SettingsProvider>(context);
        final proxy = Provider.of<AppDependencyProvider>(context).tmdbProxy;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EpisodeSectionHeading(title: tr('images')),
            const SizedBox(height: 14),
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: paths.take(16).length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppUI.cardRadius),
                  child: CachedNetworkImage(
                    width: 270,
                    imageUrl: buildImageUrl(
                          TMDB_BASE_IMAGE_URL,
                          proxy,
                          settings.enableProxy,
                          context,
                        ) +
                        settings.imageQuality +
                        paths[index],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const AppShimmerBlock(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EpisodeCastShimmer extends StatelessWidget {
  const _EpisodeCastShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => const SizedBox(
          width: 86,
          child: Column(
            children: [
              SizedBox.square(
                dimension: 68,
                child: AppShimmerBlock(radius: 40),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 76,
                height: 13,
                child: AppShimmerBlock(radius: 4),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 58,
                height: 10,
                child: AppShimmerBlock(radius: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodeGalleryShimmer extends StatelessWidget {
  const _EpisodeGalleryShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const SizedBox(
          width: 270,
          child: AppShimmerBlock(),
        ),
      ),
    );
  }
}

class _EpisodeSectionHeading extends StatelessWidget {
  const _EpisodeSectionHeading({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'FigtreeSB',
                  ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      );
}
