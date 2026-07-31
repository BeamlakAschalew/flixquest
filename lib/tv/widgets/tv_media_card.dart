import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../functions/function.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../app/tv_design.dart';
import '../models/tv_media_item.dart';

class TvMediaCard extends StatelessWidget {
  const TvMediaCard({
    required this.item,
    required this.width,
    super.key,
  });

  final TvMediaItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();
    final proxy = context.watch<AppDependencyProvider>().tmdbProxy;
    final path = item.backdropPath ?? item.posterPath;
    final imageUrl = path == null
        ? null
        : '${buildImageUrl(
            TMDB_BASE_IMAGE_URL,
            proxy,
            settings.enableProxy,
            context,
          )}${settings.imageQuality}$path';

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TvDesign.cardRadius - 3),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (imageUrl == null)
                    _ImageFallback(item: item)
                  else
                    CachedNetworkImage(
                      cacheManager: cacheProp(),
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: colors.surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => _ImageFallback(item: item),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0x08000000),
                          Color(0xb8000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            item.kind == TvMediaKind.movie
                                ? PhosphorIcons.filmSlate()
                                : PhosphorIcons.television(),
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.kind == TvMediaKind.movie ? 'Movie' : 'Series',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'FigtreeSB',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (item.rating case final rating?)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              PhosphorIcons.star(PhosphorIconsStyle.fill),
                              color: colors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'FigtreeSB',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (item.progress case final progress?)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        color: colors.primary,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontFamily: 'FigtreeSB',
              fontSize: 19,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.progressLabel ??
                <String>[
                  if (item.year != null) item.year!,
                  item.kind == TvMediaKind.movie ? 'Movie' : 'Series',
                ].join('  •  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.item});

  final TvMediaItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          item.kind == TvMediaKind.movie
              ? PhosphorIcons.filmSlate()
              : PhosphorIcons.television(),
          color: colors.onSurfaceVariant,
          size: 42,
        ),
      ),
    );
  }
}
