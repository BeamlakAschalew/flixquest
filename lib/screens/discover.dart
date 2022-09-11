import 'package:cinemax/constants/app_constants.dart';
import 'package:cinemax/models/choice_chip.dart';
import 'package:cinemax/models/dropdown_select.dart';
import 'package:cinemax/models/filter_chip.dart';
import 'package:cinemax/screens/discover_movie_result.dart';
import 'package:cinemax/screens/movie_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/api_constants.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  SortChoiceChipData sortChoiceChipData = SortChoiceChipData();
  AdultChoiceChipData adultChoiceChipData = AdultChoiceChipData();
  YearDropdownData yearDropdownData = YearDropdownData();
  GenreFilterChipData genreFilterChipData = GenreFilterChipData();
  WatchProvidersFilterChipData watchProvidersFilterChipData =
      WatchProvidersFilterChipData();
  int sortValue = 0;
  int adultValue = 1;
  String moviesSort = 'popularity.desc';
  bool includeAdult = false;
  String defaultMovieReleaseYear = '';
  double movieTotalRatingSlider = 100;
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
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFF57C00),
          width: double.infinity,
          child: TabBar(
            tabs: [
              Tab(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.movie_creation_rounded),
                  ),
                  Text(
                    'Movies',
                  ),
                ],
              )),
              Tab(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.live_tv_rounded)),
                  Text(
                    'TV Series',
                  ),
                ],
              ))
            ],
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            //isScrollable: true,
            labelStyle: const TextStyle(
              fontFamily: 'PoppinsSB',
              color: Colors.black,
              fontSize: 17,
            ),
            unselectedLabelStyle:
                const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
            labelColor: Colors.black,
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              SingleChildScrollView(
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
                            .map((SortChoiceChipWidget choiceChipWidget) =>
                                ChoiceChip(
                                  label: Text(choiceChipWidget.name),
                                  selected: sortValue == choiceChipWidget.index,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      sortValue = (selected
                                          ? choiceChipWidget.index
                                          : null)!;
                                      moviesSort = choiceChipWidget.value;
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                      const Text(
                        'Include explicit results',
                        style: kTextHeaderStyle,
                      ),
                      Wrap(
                        spacing: 3,
                        children: adultChoiceChipData.adultChoiceChip
                            .map((AdultChoiceChipWidget
                                    adultChoiceChipWidget) =>
                                ChoiceChip(
                                  label: Text(adultChoiceChipWidget.name),
                                  selected:
                                      adultValue == adultChoiceChipWidget.index,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      adultValue = (selected
                                          ? adultChoiceChipWidget.index
                                          : null)!;
                                      includeAdult =
                                          adultChoiceChipWidget.value as bool;
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                      const Text(
                        'Release year',
                        style: kTextHeaderStyle,
                      ),
                      DropdownButton<String>(
                        items: yearDropdownData.getDropdownItems(),
                        onChanged: (value) {
                          setState(() {
                            defaultMovieReleaseYear = value!;
                          });
                          print(defaultMovieReleaseYear);
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
                                activeColor: Color(0xFFF57C00),
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
                            padding:
                                const EdgeInsets.fromLTRB(30.0, 0.0, 30, 15),
                            child: Text(
                              '${movieTotalRatingSlider.toInt().toString()}: ratings',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
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
                        children: genreFilterChipData.genreFilterdata
                            .map((GenreFilterChipWidget
                                    genreFilterChipWidget) =>
                                FilterChip(
                                  label: Text(genreFilterChipWidget.genreName),
                                  selected: genreNames.contains(
                                      genreFilterChipWidget.genreName),
                                  onSelected: (bool value) {
                                    setState(() {
                                      if (value) {
                                        genreNames.add(
                                            genreFilterChipWidget.genreName);
                                        genreIds.add(
                                            genreFilterChipWidget.genreValue);
                                        genreIds.join(',');
                                      } else {
                                        genreNames.removeWhere((String name) {
                                          return name ==
                                              genreFilterChipWidget.genreName;
                                        });
                                        genreIds.removeWhere((String value) {
                                          return value ==
                                              genreFilterChipWidget.genreValue;
                                        });
                                      }
                                    });
                                    print(genreNames);
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
                        children: watchProvidersFilterChipData
                            .providerFilterData
                            .map((WatchProvidersFilterChipWidget
                                    watchProvidersFilterChipWidget) =>
                                FilterChip(
                                  label: Text(watchProvidersFilterChipWidget
                                      .networkName),
                                  selected: providersName.contains(
                                      watchProvidersFilterChipWidget
                                          .networkName),
                                  onSelected: (bool value) {
                                    setState(() {
                                      if (value) {
                                        providersName.add(
                                            watchProvidersFilterChipWidget
                                                .networkName);
                                        providersId.add(
                                            watchProvidersFilterChipWidget
                                                .networkId);
                                      } else {
                                        providersName
                                            .removeWhere((String name) {
                                          return name ==
                                              watchProvidersFilterChipWidget
                                                  .networkName;
                                        });
                                        providersId.removeWhere((String value) {
                                          return value ==
                                              watchProvidersFilterChipWidget
                                                  .networkId;
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
                                    Size(double.infinity, 50)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xFFF57C00))),
                            onPressed: () {
                              joinGenreStrings();
                              joinProviderStrings();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DiscoverMovieResult(
                                    api:
                                        '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY&sort_by=$moviesSort&include_adult=${includeAdult.toString()}&year=$defaultMovieReleaseYear&vote_count.gte=${movieTotalRatingSlider.toInt()}&with_genres=$joinedIds&with_watch_providers=$joinedProviderIds',
                                    page: 1,
                                    includeAdult: includeAdult);
                              }));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
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
              ),
              const Text('data')
            ],
            controller: tabController,
          ),
        )
      ],
    );
  }
}
