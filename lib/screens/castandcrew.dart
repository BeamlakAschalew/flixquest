import 'package:flutter/material.dart';
import '/constants/api_constants.dart';
import '/models/credits.dart';

class CastAndCrew extends StatelessWidget {
  final Credits? credits;
  const CastAndCrew({Key? key, this.credits}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF57C00),
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Color(0xFFF57C00),
            tabs: [
              Tab(
                child: Text(
                  'Cast',
                  // style: themeData!.textTheme.bodyText1,
                ),
              ),
              Tab(
                child: Text(
                  'Crew',
                  // style: themeData!.textTheme.bodyText1,
                ),
              ),
            ],
          ),
          title: const Text(
            'Cast And Crew',
            // style: themeData!.textTheme.headline5,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              // color: themeData!.accentColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: TabBarView(
          children: [castList(), creditsList()],
        ),
      ),
    );
  }

  Widget castList() {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
      color: const Color(0xFFF57C00),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: credits!.cast!.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: credits!.cast![index].profilePath == null
                        ? Image.asset(
                            'assets/images/na_square.png',
                            fit: BoxFit.cover,
                          )
                        : FadeInImage(
                            image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                'w500/' +
                                credits!.cast![index].profilePath!),
                            fit: BoxFit.cover,
                            placeholder:
                                const AssetImage('assets/images/loading.gif'),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Name : ' + credits!.cast![index].name!,
                          // style: themeData!.textTheme.bodyText2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Character : ' + credits!.cast![index].character!,
                          // style: themeData!.textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget creditsList() {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
      color: const Color(0xFFF57C00),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: credits!.crew!.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: credits!.crew![index].profilePath == null
                        ? Image.asset(
                            'assets/images/na_square.png',
                            fit: BoxFit.cover,
                          )
                        : FadeInImage(
                            image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                'w500/' +
                                credits!.crew![index].profilePath!),
                            fit: BoxFit.cover,
                            placeholder:
                                const AssetImage('assets/images/loading.gif'),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Name : ' + credits!.crew![index].name!,
                          // style: themeData!.textTheme.bodyText2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Job : ' + credits!.crew![index].job!,
                          // style: themeData!.textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
