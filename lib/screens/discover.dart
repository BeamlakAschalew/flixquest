import 'package:cinemax/models/choice_chip.dart';
import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int value = 0;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  final List<ChoiceChipWidget> choiceChip = <ChoiceChipWidget>[
    ChoiceChipWidget(
        name: 'Popularity descending', value: 'popularity.desc', index: 0),
    ChoiceChipWidget(
        name: 'Popularity ascending', value: 'popularity.asc', index: 1),
  ];

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sort by'),
                    Wrap(
                      children: choiceChip
                          .map(
                              (ChoiceChipWidget choiceChipWidget) => ChoiceChip(
                                    label: Text(choiceChipWidget.name),
                                    selected: value == choiceChipWidget.index,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        value = (selected
                                            ? choiceChipWidget.index
                                            : null)!;
                                      });
                                    },
                                  ))
                          .toList(),
                    ),
                  ],
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
