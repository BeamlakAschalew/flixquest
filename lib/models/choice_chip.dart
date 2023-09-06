import 'package:easy_localization/easy_localization.dart';

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
        name: tr('popularity_descending'), value: 'popularity.desc', index: 0),
    SortChoiceChipWidget(
        name: tr('popularity_ascending'), value: 'popularity.asc', index: 1),
    SortChoiceChipWidget(
        name: tr('average_vote_descending'),
        value: 'vote_average.desc',
        index: 2),
    SortChoiceChipWidget(
        name: tr('average_vote_ascending'), value: 'vote_average.asc', index: 3)
  ];
}

class AdultChoiceChipData {
  final List<AdultChoiceChipWidget> adultChoiceChip = <AdultChoiceChipWidget>[
    AdultChoiceChipWidget(name: tr('yes'), value: true, index: 0),
    AdultChoiceChipWidget(name: tr('no'), value: false, index: 1),
  ];
}

class TVSeriesStatusData {
  final List<TVSeriesStatus> tvSeriesStatusList = <TVSeriesStatus>[
    TVSeriesStatus(statusId: '', statusName: tr('any'), index: 0),
    TVSeriesStatus(statusId: '0', statusName: tr('returning_series'), index: 1),
    TVSeriesStatus(statusId: '1', statusName: tr('planned'), index: 2),
    TVSeriesStatus(statusId: '2', statusName: tr('in_production'), index: 3),
    TVSeriesStatus(statusId: '3', statusName: tr('ended'), index: 4),
    TVSeriesStatus(statusId: '4', statusName: tr('cancelled'), index: 5),
    TVSeriesStatus(statusId: '5', statusName: tr('pilot'), index: 6),
  ];
}
