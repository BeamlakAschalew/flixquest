import 'package:easy_localization/easy_localization.dart';
import '/models/watchprovider_countries.dart';
import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountryChoose extends StatefulWidget {
  const CountryChoose({Key? key}) : super(key: key);

  @override
  State<CountryChoose> createState() => _CountryChooseState();
}

class _CountryChooseState extends State<CountryChoose> {
  CountryData countryData = CountryData();
  // String? textInput;
  // List search = [];

  // void searchCountries() {
  //   List<WatchProviderCountries> count = countryData.countries;
  //   for (int i = 0; i < count.length; i++) {
  //     // print(count[i].countryName);
  //     if (count[i].countryName.startsWith(
  //         textInput!.replaceFirst(textInput!, textInput!.toUpperCase()))) {
  //       search.add(count[i].countryName);
  //     }
  //     print(search);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final countryChange = Provider.of<SettingsProvider>(context);
    List<WatchProviderCountries> count = countryData.countries;
    count.sort(
      (a, b) => a.countryName.compareTo(b.countryName),
    );

    return Scaffold(
        appBar: AppBar(title: Text(tr("choose_country"))),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                  children: count
                      .map(
                        (WatchProviderCountries countries) => ListTile(
                          title: Text(countries.countryName),
                          leading: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Radio(
                                value: countries.isoCode,
                                groupValue: countryChange.defaultCountry,
                                onChanged: (String? value) {
                                  setState(() {
                                    countryChange.defaultCountry = value!;
                                  });
                                },
                              ),
                              Image.asset(
                                countries.flagPath,
                                width: 25,
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList())),
        ));
  }
}
