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
