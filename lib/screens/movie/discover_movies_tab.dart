import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../models/choice_chip.dart';
import '../../models/dropdown_select.dart';
import '../../models/filter_chip.dart';
import '../../widgets/common_widgets.dart';
import 'discover_movie_result.dart';

class DiscoverMoviesTab extends StatefulWidget {
  const DiscoverMoviesTab({super.key});

  @override
  State<DiscoverMoviesTab> createState() => _DiscoverMoviesTabState();
}

class _DiscoverMoviesTabState extends State<DiscoverMoviesTab> {
  YearDropdownData yearDropdownData = YearDropdownData();
  int sortValue = 0;
  int adultValue = 1;
  String moviesSort = 'popularity.desc';
  bool includeAdult = false;
  String defaultMovieReleaseYear = '';
  double movieTotalRatingSlider = 1;
  bool enableOptionForSliderMovie = false;
  String joinedIds = '';
  String joinedProviderIds = '';
  final List<String> genreNames = <String>[];
  final List<String> genreIds = <String>[];
  final List<String> providersName = <String>[];
  final List<String> providersId = <String>[];

  void setSliderValue(newValue) {
    setState(() {
      movieTotalRatingSlider = newValue;
    });
  }

  void joinGenreStrings() {
    setState(() {
      joinedIds = genreIds.join(',');
    });
  }

  void joinProviderStrings() {
    setState(() {
      joinedProviderIds = providersId.join(',');
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<SortChoiceChipWidget> sortChoiceChip = <SortChoiceChipWidget>[
      SortChoiceChipWidget(
          name: tr('popularity_descending'),
          value: 'popularity.desc',
          index: 0),
      SortChoiceChipWidget(
          name: tr('popularity_ascending'), value: 'popularity.asc', index: 1),
      SortChoiceChipWidget(
          name: tr('average_vote_descending'),
          value: 'vote_average.desc',
          index: 2),
      SortChoiceChipWidget(
          name: tr('average_vote_ascending'),
          value: 'vote_average.asc',
          index: 3)
    ];

    final List<AdultChoiceChipWidget> adultChoiceChip = <AdultChoiceChipWidget>[
      AdultChoiceChipWidget(name: tr('yes'), value: true, index: 0),
      AdultChoiceChipWidget(name: tr('no'), value: false, index: 1),
    ];

    List<DropdownMenuItem<String>> getDropdownItems() {
      List<DropdownMenuItem<String>> dropdownItems = [];
      for (int i = 0; i < yearDropdownData.yearsList.length; i++) {
        String years = yearDropdownData.yearsList[i];
        var newItem = DropdownMenuItem(
          value: years,
          child: Text(years.isEmpty ? tr('any') : years),
        );
        dropdownItems.add(newItem);
      }
      return dropdownItems;
    }

    List<MovieGenreFilterChipWidget> movieGenreFilterdata =
        <MovieGenreFilterChipWidget>[
      MovieGenreFilterChipWidget(genreName: tr('action'), genreValue: '28'),
      MovieGenreFilterChipWidget(genreName: tr('adventure'), genreValue: '12'),
      MovieGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
      MovieGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
      MovieGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
      MovieGenreFilterChipWidget(
          genreName: tr('documentary'), genreValue: '99'),
      MovieGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
      MovieGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
      MovieGenreFilterChipWidget(genreName: tr('fantasy'), genreValue: '14'),
      MovieGenreFilterChipWidget(genreName: tr('history'), genreValue: '36'),
      MovieGenreFilterChipWidget(genreName: tr('horror'), genreValue: '27'),
      MovieGenreFilterChipWidget(genreName: tr('music'), genreValue: '10402'),
      MovieGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
      MovieGenreFilterChipWidget(genreName: tr('romance'), genreValue: '10749'),
      MovieGenreFilterChipWidget(
          genreName: tr('science_fiction'), genreValue: '878'),
      MovieGenreFilterChipWidget(
          genreName: tr('tv_movie'), genreValue: '10770'),
      MovieGenreFilterChipWidget(genreName: tr('thriller'), genreValue: '53'),
      MovieGenreFilterChipWidget(genreName: tr('war'), genreValue: '10752'),
      MovieGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
    ];

    List<WatchProvidersFilterChipWidget> providerFilterData =
        <WatchProvidersFilterChipWidget>[
      WatchProvidersFilterChipWidget(networkName: 'Netflix', networkId: '8'),
      WatchProvidersFilterChipWidget(
          networkName: 'Amazon Prime', networkId: '9'),
      WatchProvidersFilterChipWidget(
          networkName: 'Disney Plus', networkId: '337'),
      WatchProvidersFilterChipWidget(networkName: 'hulu', networkId: '15'),
      WatchProvidersFilterChipWidget(networkName: 'HBO Max', networkId: '384'),
      WatchProvidersFilterChipWidget(
          networkName: 'Apple TV plus', networkId: '350'),
      WatchProvidersFilterChipWidget(networkName: 'Peacock', networkId: '387'),
      WatchProvidersFilterChipWidget(networkName: 'iTunes', networkId: '2'),
      WatchProvidersFilterChipWidget(
          networkName: 'YouTube Premium', networkId: '188'),
      WatchProvidersFilterChipWidget(
          networkName: 'Paramount Plus', networkId: '531'),
      WatchProvidersFilterChipWidget(
          networkName: 'Netflix Kids', networkId: '175'),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr('sort_by'),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 3,
              children: sortChoiceChip
                  .map((SortChoiceChipWidget choiceChipWidget) => ChoiceChip(
                        selectedColor: Theme.of(context).colorScheme.primary,
                        label: Text(choiceChipWidget.name),
                        selected: sortValue == choiceChipWidget.index,
                        onSelected: (bool selected) {
                          setState(() {
                            sortValue =
                                (selected ? choiceChipWidget.index : null)!;
                            moviesSort = choiceChipWidget.value;
                          });
                        },
                      ))
                  .toList(),
            ),
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr('include_adult'),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 3,
              children: adultChoiceChip
                  .map((AdultChoiceChipWidget adultChoiceChipWidget) =>
                      ChoiceChip(
                        selectedColor: Theme.of(context).colorScheme.primary,
                        label: Text(adultChoiceChipWidget.name),
                        selected: adultValue == adultChoiceChipWidget.index,
                        onSelected: (bool selected) {
                          setState(() {
                            adultValue = (selected
                                ? adultChoiceChipWidget.index
                                : null)!;
                            includeAdult = adultChoiceChipWidget.value;
                          });
                        },
                      ))
                  .toList(),
            ),
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr('release_year'),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              items: getDropdownItems(),
              onChanged: (value) {
                setState(() {
                  defaultMovieReleaseYear = value!;
                });
              },
              value: defaultMovieReleaseYear,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const LeadingDot(),
                          Expanded(
                            child: Text(
                              tr('total_ratings'),
                              style: kTextHeaderStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: enableOptionForSliderMovie,
                      onChanged: (newValue) {
                        setState(() {
                          enableOptionForSliderMovie = newValue!;
                          movieTotalRatingSlider = 0;
                        });
                      },
                    ),
                  ],
                ),
                Slider(
                  value: movieTotalRatingSlider,
                  onChanged: enableOptionForSliderMovie
                      ? (newValue) {
                          setSliderValue(newValue);
                        }
                      : null,
                  min: 0,
                  max: 30000,
                  label: '${movieTotalRatingSlider.toInt()}',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30, 15),
                  child: Text(
                    tr('ratings_count', namedArgs: {
                      'r': movieTotalRatingSlider.toInt().toString()
                    }),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr('with_genres'),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 3,
              children: movieGenreFilterdata
                  .map((MovieGenreFilterChipWidget
                          movieGenreFilterChipWidget) =>
                      FilterChip(
                        selectedColor: Theme.of(context).colorScheme.primary,
                        label: Text(movieGenreFilterChipWidget.genreName),
                        selected: genreNames
                            .contains(movieGenreFilterChipWidget.genreName),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              genreNames
                                  .add(movieGenreFilterChipWidget.genreName);
                              genreIds
                                  .add(movieGenreFilterChipWidget.genreValue);
                              genreIds.join(',');
                            } else {
                              genreNames.removeWhere((String name) {
                                return name ==
                                    movieGenreFilterChipWidget.genreName;
                              });
                              genreIds.removeWhere((String value) {
                                return value ==
                                    movieGenreFilterChipWidget.genreValue;
                              });
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr('with_streaming_services'),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 3,
              children: providerFilterData
                  .map((WatchProvidersFilterChipWidget
                          watchProvidersFilterChipWidget) =>
                      FilterChip(
                        selectedColor: Theme.of(context).colorScheme.primary,
                        label: Text(watchProvidersFilterChipWidget.networkName),
                        selected: providersName.contains(
                            watchProvidersFilterChipWidget.networkName),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              providersName.add(
                                  watchProvidersFilterChipWidget.networkName);
                              providersId.add(
                                  watchProvidersFilterChipWidget.networkId);
                            } else {
                              providersName.removeWhere((String name) {
                                return name ==
                                    watchProvidersFilterChipWidget.networkName;
                              });
                              providersId.removeWhere((String value) {
                                return value ==
                                    watchProvidersFilterChipWidget.networkId;
                              });
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  style: const ButtonStyle(
                    minimumSize:
                        WidgetStatePropertyAll(Size(double.infinity, 50)),
                  ),
                  onPressed: () {
                    joinGenreStrings();
                    joinProviderStrings();

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return DiscoverMovieResult(
                          api:
                              '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY&sort_by=$moviesSort&watch_region=US&include_adult=${includeAdult.toString()}&primary_release_year=$defaultMovieReleaseYear&vote_count.gte=${movieTotalRatingSlider.toInt()}&with_genres=$joinedIds&with_watch_providers=$joinedProviderIds',
                          page: 1,
                          includeAdult: includeAdult);
                    }));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(tr('discover')),
                      ),
                      const Icon(FontAwesomeIcons.wandMagicSparkles)
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
