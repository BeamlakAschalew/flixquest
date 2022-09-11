class SortChoiceChipWidget {
  SortChoiceChipWidget(
      {required this.name, required this.value, required this.index});
  final String value;
  final String name;
  final int index;
}

class AdultChoiceChipWidget {
  AdultChoiceChipWidget(
      {required this.index, required this.name, required this.value});
  final String name;
  final bool value;
  final int index;
}

class TVSeriesStatus {
  TVSeriesStatus(
      {required this.statusId, required this.statusName, required this.index});
  String statusName;
  String statusId;
  final int index;
}

class SortChoiceChipData {
  final List<SortChoiceChipWidget> sortChoiceChip = <SortChoiceChipWidget>[
    SortChoiceChipWidget(
        name: 'Popularity descending', value: 'popularity.desc', index: 0),
    SortChoiceChipWidget(
        name: 'Popularity ascending', value: 'popularity.asc', index: 1),
    SortChoiceChipWidget(
        name: 'Average rating descending',
        value: 'vote_average.desc',
        index: 2),
    SortChoiceChipWidget(
        name: 'Average rating ascending', value: 'vote_average.asc', index: 3)
  ];
}

class AdultChoiceChipData {
  final List<AdultChoiceChipWidget> adultChoiceChip = <AdultChoiceChipWidget>[
    AdultChoiceChipWidget(name: 'Yes', value: true, index: 0),
    AdultChoiceChipWidget(name: 'No', value: false, index: 1),
  ];
}

class TVSeriesStatusData {
  final List<TVSeriesStatus> tvSeriesStatusList = <TVSeriesStatus>[
    TVSeriesStatus(statusId: '', statusName: 'Any', index: 0),
    TVSeriesStatus(statusId: '0', statusName: 'Returning Series', index: 1),
    TVSeriesStatus(statusId: '1', statusName: 'Planned', index: 2),
    TVSeriesStatus(statusId: '2', statusName: 'In Production', index: 3),
    TVSeriesStatus(statusId: '3', statusName: 'Ended', index: 4),
    TVSeriesStatus(statusId: '4', statusName: 'Cancelled', index: 5),
    TVSeriesStatus(statusId: '5', statusName: 'Pilot', index: 6),
  ];
}
