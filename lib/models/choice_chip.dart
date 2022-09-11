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
  final String value;
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
    AdultChoiceChipWidget(name: 'Yes', value: 'true', index: 0),
    AdultChoiceChipWidget(name: 'No', value: 'false', index: 1),
  ];
}
