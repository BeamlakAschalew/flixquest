import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../models/choice_chip.dart';
import '../../models/dropdown_select.dart';
import '../../models/filter_chip.dart';
import 'discover_tv_result.dart';

class DiscoverTVTab extends StatefulWidget {
  const DiscoverTVTab({Key? key}) : super(key: key);

  @override
  State<DiscoverTVTab> createState() => _DiscoverTVTabState();
}

class _DiscoverTVTabState extends State<DiscoverTVTab> {
  SortChoiceChipData sortChoiceChipData = SortChoiceChipData();
  YearDropdownData yearDropdownData = YearDropdownData();
  TVSeriesStatusData tvSeriesStatusData = TVSeriesStatusData();
  TVGenreFilterChipData tvGenreFilterChipData = TVGenreFilterChipData();
  MovieGenreFilterChipData movieGenreFilterChipData =
      MovieGenreFilterChipData();
  WatchProvidersFilterChipData watchProvidersFilterChipData =
      WatchProvidersFilterChipData();
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: kTextHeaderStyle,
            ),
            Wrap(
              spacing: 3,
              children: sortChoiceChipData.sortChoiceChip
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
            const Text(
              'TV Series status',
              style: kTextHeaderStyle,
            ),
            Wrap(
              spacing: 3,
              children: tvSeriesStatusData.tvSeriesStatusList
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
            const Text(
              'First air year',
              style: kTextHeaderStyle,
            ),
            DropdownButton<String>(
              items: yearDropdownData.getDropdownItems(),
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
                    const Text(
                      'Total ratings',
                      style: kTextHeaderStyle,
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
                    '${tvTotalRatingSlider.toInt().toString()}: ratings',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            const Text(
              'With Genres',
              style: kTextHeaderStyle,
            ),
            Wrap(
              spacing: 3,
              children: tvGenreFilterChipData.tvGenreList
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
            const Text(
              'With Sreaming services',
              style: kTextHeaderStyle,
            ),
            Wrap(
              spacing: 3,
              children: watchProvidersFilterChipData.providerFilterData
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text('Discover'),
                      ),
                      Icon(FontAwesomeIcons.wandMagicSparkles)
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
