import 'package:cinemax/models/watchprovider_countries.dart';
import 'package:cinemax/provider/settings_provider.dart';
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final countryChange = Provider.of<SettingsProvider>(context);
    List<WatchProviderCountries> count = countryData.countries;
    count.sort(
      (a, b) => a.countryName.compareTo(b.countryName),
    );

    return Scaffold(
        appBar: AppBar(title: const Text('Choose country')),
        body: Container(
            child: SingleChildScrollView(
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
                                fillColor: const MaterialStatePropertyAll(
                                    Color(0xFFF57C00)),
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
        )));
    // ListTile(
    //   title: const Text('Lafayette'),
    //   leading: Radio(
    //     value: 'STH1',
    //     groupValue: 'country',
    //     onChanged: (value) {
    //       setState(() {});
    //     },
    //   ),
    // ),
  }
}
