import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../models/choice_chip.dart';
import '../../models/dropdown_select.dart';
import '../../models/filter_chip.dart';
import '../../widgets/common_widgets.dart';
import 'discover_tv_result.dart';

class DiscoverTVTab extends StatefulWidget {
  const DiscoverTVTab({Key? key}) : super(key: key);

  @override
  State<DiscoverTVTab> createState() => _DiscoverTVTabState();
}

class _DiscoverTVTabState extends State<DiscoverTVTab> {
  YearDropdownData yearDropdownData = YearDropdownData();
  int sortValue = 0;
  int tvStatusValue = 0;
  int adultValue = 1;
  String tvSort = 'popularity.desc';
  String tvSeriesStatusValue = '';
  bool includeAdult = false;
  String defaultMovieReleaseYear = '';
  double tvTotalRatingSlider = 1;
  bool enableOptionForSliderMovie = false;
  String joinedIds = '';
  String joinedProviderIds = '';
  final List<String> genreNames = <String>[];
  final List<String> genreIds = <String>[];
  final List<String> providersName = <String>[];
  final List<String> providersId = <String>[];

  void setSliderValue(newValue) {
    setState(() {
      tvTotalRatingSlider = newValue;
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

    final List<TVSeriesStatus> tvSeriesStatusList = <TVSeriesStatus>[
      TVSeriesStatus(statusId: '', statusName: tr('any'), index: 0),
      TVSeriesStatus(
          statusId: '0', statusName: tr('returning_series'), index: 1),
      TVSeriesStatus(statusId: '1', statusName: tr('planned'), index: 2),
      TVSeriesStatus(statusId: '2', statusName: tr('in_production'), index: 3),
      TVSeriesStatus(statusId: '3', statusName: tr('ended'), index: 4),
      TVSeriesStatus(statusId: '4', statusName: tr('cancelled'), index: 5),
      TVSeriesStatus(statusId: '5', statusName: tr('pilot'), index: 6),
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

    List<TVGenreFilterChipWidget> tvGenreList = <TVGenreFilterChipWidget>[
      TVGenreFilterChipWidget(
          genreName: tr('action_and_adventure'), genreValue: '10759'),
      TVGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
      TVGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
      TVGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
      TVGenreFilterChipWidget(genreName: tr('documentary'), genreValue: '99'),
      TVGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
      TVGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
      TVGenreFilterChipWidget(genreName: tr('kids'), genreValue: '10762'),
      TVGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
      TVGenreFilterChipWidget(genreName: tr('news'), genreValue: '10763'),
      TVGenreFilterChipWidget(genreName: tr('reality'), genreValue: '10764'),
      TVGenreFilterChipWidget(
          genreName: tr('scifi_and_fantasy'), genreValue: '10765'),
      TVGenreFilterChipWidget(genreName: tr('soap'), genreValue: '10766'),
      TVGenreFilterChipWidget(genreName: tr('talk'), genreValue: '10767'),
      TVGenreFilterChipWidget(
          genreName: tr('war_and_politics'), genreValue: '10768'),
      TVGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
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
                Text(
                  tr("sort_by"),
                  style: kTextHeaderStyle,
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
                            tvSort = choiceChipWidget.value;
                          });
                        },
                      ))
                  .toList(),
            ),
            Row(
              children: [
                const LeadingDot(),
                Text(
                  tr("tv_series_status"),
                  style: kTextHeaderStyle,
                ),
              ],
            ),
            Wrap(
              spacing: 3,
              children: tvSeriesStatusList
                  .map((TVSeriesStatus tvSeriesStatus) => ChoiceChip(
                        selectedColor: Theme.of(context).colorScheme.primary,
                        label: Text(tvSeriesStatus.statusName),
                        selected: tvStatusValue == tvSeriesStatus.index,
                        onSelected: (bool selected) {
                          setState(() {
                            tvStatusValue =
                                (selected ? tvSeriesStatus.index : null)!;
                            tvSeriesStatusValue = tvSeriesStatus.statusId;
                          });
                        },
                      ))
                  .toList(),
            ),
            const Row(
              children: [
                LeadingDot(),
                Text(
                  'First air year',
                  style: kTextHeaderStyle,
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
                    Row(
                      children: [
                        const LeadingDot(),
                        Text(
                          tr("total_ratings"),
                          style: kTextHeaderStyle,
                        ),
                      ],
                    ),
                    Checkbox(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: enableOptionForSliderMovie,
                      onChanged: (newValue) {
                        setState(() {
                          enableOptionForSliderMovie = newValue!;
                          tvTotalRatingSlider = 0;
                        });
                      },
                    ),
                  ],
                ),
                Slider(
                  value: tvTotalRatingSlider,
                  onChanged: enableOptionForSliderMovie
                      ? (newValue) {
                          setSliderValue(newValue);
                        }
                      : null,
                  min: 0,
                  max: 30000,
                  label: '${tvTotalRatingSlider.toInt()}',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30, 15),
                  child: Text(
                    tr("ratings_count", namedArgs: {
                      "r": tvTotalRatingSlider.toInt().toString()
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
                Text(
                  tr("with_genres"),
                  style: kTextHeaderStyle,
                ),
              ],
            ),
            Wrap(
              spacing: 3,
              children: tvGenreList
                  .map((TVGenreFilterChipWidget tvGenreFilterChipWidget) =>
                      FilterChip(
                        selectedColor: Theme.of(context).colorScheme.primary,
                        label: Text(tvGenreFilterChipWidget.genreName),
                        selected: genreNames
                            .contains(tvGenreFilterChipWidget.genreName),
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
                              genreNames.add(tvGenreFilterChipWidget.genreName);
                              genreIds.add(tvGenreFilterChipWidget.genreValue);
                              genreIds.join(',');
                            } else {
                              genreNames.removeWhere((String name) {
                                return name ==
                                    tvGenreFilterChipWidget.genreName;
                              });
                              genreIds.removeWhere((String value) {
                                return value ==
                                    tvGenreFilterChipWidget.genreValue;
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
                Text(
                  tr("with_streaming_services"),
                  style: kTextHeaderStyle,
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
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50)),
                  ),
                  onPressed: () {
                    joinGenreStrings();
                    joinProviderStrings();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return DiscoverTVResult(
                        api:
                            '$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY&sort_by=$tvSort&watch_region=US&with_status=$tvSeriesStatusValue&first_air_date_year=$defaultMovieReleaseYear&vote_count.gte=${tvTotalRatingSlider.toInt()}&with_genres=$joinedIds&with_watch_providers=$joinedProviderIds',
                        page: 1,
                      );
                    }));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(tr("discover")),
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
