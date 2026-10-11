import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Load the app catalog for TV widgets tested without an EasyLocalization root.
void initializeTvTranslations() {
  setUpAll(() async {
    Localization.load(const Locale('en'),
        translations: Translations(
          jsonDecode(File('assets/translations/en.json').readAsStringSync())
              as Map<String, dynamic>,
        ));
    await initializeDateFormatting();
  });
}
