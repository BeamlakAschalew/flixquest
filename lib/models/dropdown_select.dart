import 'package:flutter/material.dart';

class YearDropdownData {
  List<String> yearsList = [
    '',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015',
    '2014',
    '2013',
    '2012',
    '2011',
    '2010',
    '2009',
    '2008',
    '2007',
    '2006',
    '2005',
    '2004',
    '2003',
    '2002',
    '2001',
    '2000',
    '1999',
    '1998',
    '1997',
    '1996',
    '1995',
    '1994',
    '1993',
    '1992',
    '1991',
    '1990',
    '1989',
    '1988',
    '1987',
    '1986',
    '1985',
  ];
  List<DropdownMenuItem<String>> getDropdownItems() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (int i = 0; i < yearsList.length; i++) {
      String years = yearsList[i];
      var newItem = DropdownMenuItem(
        value: years,
        child: Text(years.isEmpty ? 'Any' : years),
      );
      dropdownItems.add(newItem);
    }
    return dropdownItems;
  }
}
