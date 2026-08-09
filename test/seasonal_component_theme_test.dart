import 'package:flixquest/constants/theme_data.dart';
import 'package:flixquest/models/app_colors.dart';
import 'package:flixquest/models/occasional_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('seasonal accent reaches every Material control theme',
      (tester) async {
    late ThemeData seasonalTheme;
    final occasionalTheme = OccasionalTheme.fromJson(<String, dynamic>{
      'id': 'ethiopian_new_year',
      'enabled': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seasonalTheme = Styles.themeData(
              appThemeMode: 'dark',
              isM3Enabled: true,
              lightDynamicColor: null,
              darkDynamicColor: null,
              context: context,
              appColor: AppColor(
                cs: AppColor.colorGetter(Colors.deepPurple, true),
                index: 1,
              ),
              occasionalTheme: occasionalTheme,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final accent = occasionalTheme.primaryColor;
    expect(seasonalTheme.colorScheme.primary, accent);
    expect(seasonalTheme.iconTheme.color, accent);
    expect(
      seasonalTheme.iconButtonTheme.style?.foregroundColor
          ?.resolve(<WidgetState>{}),
      accent,
    );
    expect(
      seasonalTheme.radioTheme.fillColor?.resolve(<WidgetState>{}),
      accent,
    );
    expect(
      seasonalTheme.checkboxTheme.fillColor
          ?.resolve(<WidgetState>{WidgetState.selected}),
      accent,
    );
    expect(seasonalTheme.progressIndicatorTheme.color, accent);
    expect(seasonalTheme.sliderTheme.activeTrackColor, accent);
    expect(seasonalTheme.sliderTheme.thumbColor, accent);
    expect(seasonalTheme.textSelectionTheme.cursorColor, accent);
    expect(seasonalTheme.floatingActionButtonTheme.backgroundColor, accent);
    expect(seasonalTheme.bottomNavigationBarTheme.selectedItemColor, accent);
    expect(seasonalTheme.navigationRailTheme.selectedIconTheme?.color, accent);
    expect(seasonalTheme.badgeTheme.backgroundColor, accent);

    expect(seasonalTheme.iconTheme.color, isNot(Colors.deepPurple));

    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: seasonalTheme,
        home: Scaffold(
          body: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
              ),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.bookmark),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final shareContext = tester.element(find.byIcon(Icons.share));
    expect(Theme.of(shareContext).useMaterial3, seasonalTheme.useMaterial3);
    expect(Theme.of(shareContext).iconTheme.color, accent);
    expect(
      IconTheme.of(shareContext).color,
      accent,
    );
    expect(
      IconTheme.of(tester.element(find.byIcon(Icons.bookmark))).color,
      accent,
    );
  });
}
