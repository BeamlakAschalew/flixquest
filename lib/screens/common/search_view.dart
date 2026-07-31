import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import '../../constants/app_constants.dart';
import '../../functions/function.dart';
import '../../provider/app_dependency_provider.dart';
import '../../preferences/setting_preferences.dart';
import '/api/endpoints.dart';
import '../../functions/network.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import '/constants/api_constants.dart';
import '/models/person.dart';
import 'package:flutter/material.dart';
import '/models/movie.dart';
import '/models/tv.dart';
import '/screens/movie/movie_detail.dart';
import '/screens/person/searchedperson.dart';
import '/screens/tv/tv_detail.dart';
import '../../ui_components/app_ui_components.dart';

class Search extends SearchDelegate<String> {
  final bool includeAdult;
  final String lang;
  Timer? _debounce;
  final SettingsPreferences _settingsPreferences = SettingsPreferences();

  Search(
      {required this.includeAdult, required this.lang})
      : super(
          searchFieldLabel: tr('search_text'),
        );

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String searchQuery) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (searchQuery.trim().isEmpty) return;

    _debounce = Timer(const Duration(seconds: 3), () {
      _settingsPreferences.addRecentSearch(searchQuery.trim());
    });
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        toolbarHeight: 76,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          PhosphorIcons.x(),
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        PhosphorIcons.caretLeft(),
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final analytics =
        Provider.of<SettingsProvider>(context, listen: false).analytics;

    // Trigger search saving timer when query changes
    if (query.isNotEmpty) {
      _onSearchChanged(query);
    }

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Column(
          children: [
            AppResponsiveContent(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(tr('movies')),
                  ),
                  Tab(
                    child: Text(tr('tv_shows')),
                  ),
                  Tab(
                    child: Text(tr('celebrities')),
                  )
                ],
              ),
            ),
            Expanded(
                child: TabBarView(children: [
              // ── Movies tab ──
              FutureBuilder<List<Movie>>(
                future: Future.delayed(const Duration(milliseconds: 700))
                    .then((value) async {
                  if (query.isNotEmpty) {
                    analytics.trackSearch(query);
                  }
                  return await fetchMovies(
                      Endpoints.movieSearchUrl(query, includeAdult, lang),
                      isProxyEnabled,
                      proxyUrl);
                }),
                builder: (context, snapshot) {
                  if (query.isEmpty) {
                    return _recentSearchesWidget(context);
                  }

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const AppMediaGridShimmer();
                    default:
                      if (snapshot.hasError || snapshot.data!.isEmpty) {
                        return _errorMessageWidget();
                      } else {
                        return _activeMovieSearch(snapshot.data!, context);
                      }
                  }
                },
              ),

              // ── TV tab ──
              FutureBuilder<List<TV>>(
                future: Future.delayed(const Duration(milliseconds: 700)).then(
                    (value) async => await fetchTV(
                        Endpoints.tvSearchUrl(query, includeAdult, lang),
                        isProxyEnabled,
                        proxyUrl)),
                builder: (context, snapshot) {
                  if (query.isEmpty) {
                    return _recentSearchesWidget(context);
                  }

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const AppMediaGridShimmer();
                    default:
                      if (snapshot.hasError || snapshot.data!.isEmpty) {
                        return _errorMessageWidget();
                      } else {
                        return _activeTVSearch(snapshot.data!, context);
                      }
                  }
                },
              ),

              // ── Celebrities tab ──
              FutureBuilder<List<Person>>(
                future: Future.delayed(const Duration(milliseconds: 700)).then(
                    (value) async => await fetchPerson(
                        Endpoints.personSearchUrl(query, includeAdult, lang),
                        isProxyEnabled,
                        proxyUrl)),
                builder: (context, snapshot) {
                  if (query.isEmpty) {
                    return _recentSearchesWidget(context);
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return _personShimmer(context);
                    default:
                      if (snapshot.hasError || snapshot.data!.isEmpty) {
                        return _errorMessageWidget();
                      } else {
                        return _activePersonSearch(snapshot.data!, context);
                      }
                  }
                },
              ),
            ])),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty / Error states
  // ─────────────────────────────────────────────────────────────────────────

  Widget _errorMessageWidget() {
    return AppEmptyState(
      title: tr('no_result'),
      message: tr('enter_word'),
      icon: PhosphorIcons.magnifyingGlassMinus(),
    );
  }

  Widget _searchATermWidget() {
    return AppEmptyState(
      title: tr('search'),
      message: tr('enter_word'),
      icon: PhosphorIcons.magnifyingGlassPlus(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Recent searches
  // ─────────────────────────────────────────────────────────────────────────

  Widget _recentSearchesWidget(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _settingsPreferences.getRecentSearches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _searchATermWidget();
        }

        final recentSearches = snapshot.data!;
        final colors = Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppUI.pagePadding(context), 16, AppUI.pagePadding(context), 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('recent_searches'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'FigtreeSB',
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _settingsPreferences.clearRecentSearches();
                      // Trigger rebuild
                      query = query; // This forces a rebuild
                    },
                    child: Text(
                      tr('clear_all'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  final searchTerm = recentSearches[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: AppUI.pagePadding(context)),
                    leading: Icon(
                      PhosphorIcons.clockCounterClockwise(),
                      color: colors.onSurfaceVariant,
                    ),
                    title: Text(
                      searchTerm,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        PhosphorIcons.x(),
                        color: colors.onSurfaceVariant,
                      ),
                      onPressed: () async {
                        await _settingsPreferences
                            .removeRecentSearch(searchTerm);
                        // Trigger rebuild
                        query = query;
                      },
                    ),
                    onTap: () {
                      query = searchTerm;
                      showResults(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Movie search results — poster grid
  // ─────────────────────────────────────────────────────────────────────────

  Widget _activeMovieSearch(List<Movie> moviesList, BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
          AppUI.pagePadding(context), 12, AppUI.pagePadding(context), 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppUI.mediaGridColumns(context),
        childAspectRatio: AppUI.mediaGridChildAspectRatio(context),
        crossAxisSpacing: AppUI.mediaGridCrossAxisSpacing,
        mainAxisSpacing: 16,
      ),
      itemCount: moviesList.length,
      itemBuilder: (BuildContext context, int index) {
        final movie = moviesList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MovieDetailPage(
                movie: movie,
                heroId: '${movie.id}',
              );
            }));
          },
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: AppUI.posterAspectRatio,
                child: Hero(
                  tag: '${movie.id}',
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
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity)
                                : CachedNetworkImage(
                                    cacheManager: cacheProp(),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration:
                                        const Duration(milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl: buildImageUrl(
                                            TMDB_BASE_IMAGE_URL,
                                            proxyUrl,
                                            isProxyEnabled,
                                            context) +
                                        imageQuality +
                                        movie.posterPath!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        const AppShimmerBlock(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: AppRatingBadge(
                            rating: movie.voteAverage,
                            compact: true,
                          ),
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
                  movie.title ?? '',
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TV search results — poster grid
  // ─────────────────────────────────────────────────────────────────────────

  Widget _activeTVSearch(List<TV> tvList, BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
          AppUI.pagePadding(context), 12, AppUI.pagePadding(context), 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppUI.mediaGridColumns(context),
        childAspectRatio: AppUI.mediaGridChildAspectRatio(context),
        crossAxisSpacing: AppUI.mediaGridCrossAxisSpacing,
        mainAxisSpacing: 16,
      ),
      itemCount: tvList.length,
      itemBuilder: (BuildContext context, int index) {
        final show = tvList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TVDetailPage(
                tvSeries: show,
                heroId: '${show.id}',
              );
            }));
          },
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: AppUI.posterAspectRatio,
                child: Hero(
                  tag: '${show.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppUI.cardRadius),
                            child: show.posterPath == null
                                ? Image.asset('assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity)
                                : CachedNetworkImage(
                                    cacheManager: cacheProp(),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 300),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration:
                                        const Duration(milliseconds: 700),
                                    fadeInCurve: Curves.easeIn,
                                    imageUrl: buildImageUrl(
                                            TMDB_BASE_IMAGE_URL,
                                            proxyUrl,
                                            isProxyEnabled,
                                            context) +
                                        imageQuality +
                                        show.posterPath!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        const AppShimmerBlock(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: AppRatingBadge(
                            rating: show.voteAverage,
                            compact: true,
                          ),
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
                  show.name ?? '',
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Person search results — card-based list
  // ─────────────────────────────────────────────────────────────────────────

  Widget _activePersonSearch(List<Person> personList, BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    final colors = Theme.of(context).colorScheme;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
          AppUI.pagePadding(context), 12, AppUI.pagePadding(context), 24),
      itemCount: personList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final person = personList[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SearchedPersonDetailPage(
                    person: person, heroId: '${person.id}');
              }));
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Hero(
                      tag: '${person.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: person.profilePath == null
                            ? Image.asset(
                                'assets/images/na_rect.png',
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                cacheManager: cacheProp(),
                                fadeOutDuration:
                                    const Duration(milliseconds: 300),
                                fadeOutCurve: Curves.easeOut,
                                fadeInDuration:
                                    const Duration(milliseconds: 700),
                                fadeInCurve: Curves.easeIn,
                                imageUrl: buildImageUrl(TMDB_BASE_IMAGE_URL,
                                        proxyUrl, isProxyEnabled, context) +
                                    imageQuality +
                                    person.profilePath!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    const AppShimmerBlock(radius: 100),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/na_rect.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name ?? '',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (person.department != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            person.department!,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(PhosphorIcons.caretRight(),
                      color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Person shimmer
  // ─────────────────────────────────────────────────────────────────────────

  Widget _personShimmer(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF202124) : const Color(0xFFE7E7E9);
    final highlight = dark ? const Color(0xFF303236) : const Color(0xFFF5F5F6);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
            AppUI.pagePadding(context), 12, AppUI.pagePadding(context), 24),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: base,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 140,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 90,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSuggestionsSuccess(List<TV> moviesList) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  text: tr('movies'),
                ),
                Tab(
                  text: tr('tv'),
                ),
                Tab(
                  text: tr('celebrities'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
