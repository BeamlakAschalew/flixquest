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
import '../focus/tv_focusable.dart';
import '../models/tv_media_item.dart';

class TvHero extends StatelessWidget {
  const TvHero({
    required this.item,
    required this.compact,
    required this.onOpenDetails,
    super.key,
  });

  final TvMediaItem item;
  final bool compact;
  final VoidCallback onOpenDetails;

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
          )}original/$path';

    return SizedBox(
      height: compact ? 230 : 340,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (imageUrl == null)
              ColoredBox(color: TvDesign.surfaceFor(context, emphasis: 0.03))
            else
              CachedNetworkImage(
                cacheManager: cacheProp(),
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                placeholder: (_, __) =>
                    ColoredBox(color: TvDesign.surfaceFor(context)),
                errorWidget: (_, __, ___) =>
                    ColoredBox(color: TvDesign.surfaceFor(context)),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: <Color>[
                    Color(0x10000000),
                    Color(0xcc000000),
                    Color(0xf2000000),
                  ],
                  stops: <double>[0, 0.58, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 24 : 38),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: compact ? 430 : 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            item.kind == TvMediaKind.movie
                                ? PhosphorIcons.filmSlate()
                                : PhosphorIcons.television(),
                            color: colors.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            item.kind == TvMediaKind.movie
                                ? 'FEATURED MOVIE'
                                : 'FEATURED SERIES',
                            style: TextStyle(
                              color: colors.primary,
                              fontFamily: 'FigtreeSB',
                              fontSize: compact ? 14 : 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'FigtreeSB',
                          fontSize: compact ? 34 : 48,
                          height: 1.02,
                        ),
                      ),
                      if (!compact && item.overview.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 14),
                        Text(
                          item.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xffdddddd),
                            fontSize: 18,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      TvFocusable(
                        semanticLabel: 'More information about ${item.title}',
                        onActivate: onOpenDetails,
                        focusScale: 1.025,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                PhosphorIcons.info(),
                                color: colors.onPrimary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'More info',
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontFamily: 'FigtreeSB',
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
