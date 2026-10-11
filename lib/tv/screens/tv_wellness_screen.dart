import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/wellness_insights.dart';
import '../../models/wellness_time_series.dart';
import '../../provider/wellness_provider.dart';
import '../../widgets/wellness_charts.dart';
import '../app/tv_design.dart';
import '../focus/tv_screen_focus_controller.dart';
import '../widgets/tv_page_header.dart';
import '../widgets/tv_pill_button.dart';
import '../widgets/tv_loading_skeletons.dart';

class TvWellnessScreen extends StatelessWidget {
  const TvWellnessScreen(
      {required this.metrics, this.focusController, super.key});

  final TvShellMetrics metrics;
  final TvScreenFocusController? focusController;

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final provider = context.watch<WellnessProvider>();
    return TvWellnessContent(
      metrics: metrics,
      insights: provider.insights,
      range: provider.range,
      loading: provider.loading,
      onRangeSelected: provider.setRange,
      focusController: focusController,
    );
  }
}

/// Separated from storage so TV layout and D-pad behavior can be tested with
/// deterministic viewing sessions.
class TvWellnessContent extends StatefulWidget {
  const TvWellnessContent({
    required this.metrics,
    required this.insights,
    required this.range,
    required this.loading,
    required this.onRangeSelected,
    this.focusController,
    super.key,
  });

  final TvShellMetrics metrics;
  final WellnessInsights insights;
  final WellnessRange range;
  final bool loading;
  final ValueChanged<WellnessRange> onRangeSelected;
  final TvScreenFocusController? focusController;

  @override
  State<TvWellnessContent> createState() => _TvWellnessContentState();
}

class _TvWellnessContentState extends State<TvWellnessContent> {
  late final FocusNode _entry = FocusNode(debugLabel: 'TV insights week');
  final Map<String, GlobalKey> _sections = <String, GlobalKey>{
    'Time': GlobalKey(),
    'Titles': GlobalKey(),
    'Taste': GlobalKey(),
    'Patterns': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    widget.focusController?.attach(this, _requestEntryFocus);
  }

  @override
  void didUpdateWidget(TvWellnessContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusController != widget.focusController) {
      oldWidget.focusController?.detach(this);
      widget.focusController?.attach(this, _requestEntryFocus);
    }
  }

  @override
  void dispose() {
    widget.focusController?.detach(this);
    _entry.dispose();
    super.dispose();
  }

  bool _requestEntryFocus() {
    if (_entry.context == null || !_entry.canRequestFocus) return false;
    _entry.requestFocus();
    return true;
  }

  void _jumpTo(String section) {
    final target = _sections[section]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final palette = TvPalette.of(context);
    final theme = Theme.of(context);
    final insights = widget.insights;
    final series = WellnessTimeSeries.forRange(insights, widget.range);
    // The charts are shared with the phone and draw in the theme's accent;
    // on TV they read in greys, and the accent stays with the brand.
    final chartTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: palette.secondaryText,
        secondary: palette.mutedText,
      ),
    );
    return Theme(
      data: chartTheme,
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(widget.metrics.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // The header keeps the real accent; the charts below do not.
              Theme(
                data: theme,
                child: TvPageHeader(
                  kicker: tr('tv_your_viewing_story'),
                  title: tr('viewing_insights'),
                  compact: widget.metrics.compact,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr('tv_active_playback_only_private_to_this_profile'),
                style: TextStyle(color: palette.mutedText, fontSize: 15),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  for (final range in WellnessRange.values)
                    TvPillButton(
                      key: Key('tv-insights-range-${range.name}'),
                      focusNode: range == WellnessRange.week ? _entry : null,
                      label: _rangeLabel(range),
                      semanticLabel: tr('tv_viewing_range', namedArgs: {
                        'range': _rangeLabel(range),
                        'selected': widget.range == range
                            ? tr('tv_selected_suffix')
                            : ''
                      }),
                      icon: widget.range == range
                          ? PhosphorIcons.check(PhosphorIconsStyle.bold)
                          : null,
                      prominent: widget.range == range,
                      onActivate: () => widget.onRangeSelected(range),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.loading)
                TvInsightsSkeleton(metrics: widget.metrics)
              else if (insights.isEmpty)
                _InsightPanel(
                  title: tr('tv_your_story_starts_here'),
                  child: Text(
                    tr('tv_watch_something_and_your_private_viewing_insights_will_appear_here_try_a_different_range_to_see_older_activity'),
                  ),
                )
              else ...<Widget>[
                _InsightPanel(
                  title: tr('tv_active_playback'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _duration(insights.totalWatchedMs),
                        style: TextStyle(
                          color: palette.foreground,
                          fontFamily: 'FigtreeBold',
                          fontSize: widget.metrics.compact ? 40 : 50,
                        ),
                      ),
                      WellnessBarChart(
                        data: <WellnessBarDatum>[
                          for (final bucket in series.buckets)
                            WellnessBarDatum(
                              label: bucket.label,
                              fullLabel: bucket.fullLabel,
                              value: bucket.totalMs,
                            ),
                        ],
                        averageMs: series.averageMs,
                        color: palette.secondaryText,
                        height: widget.metrics.compact ? 156 : 190,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr('tv_active_period_summary', namedArgs: {
                          'count': '${series.activeBuckets}',
                          'unit': tr(
                              'ins_unit_${series.unitLabel}${series.activeBuckets == 1 ? '' : 's'}'),
                          'time': _duration(insights.averageActiveDayMs)
                        }),
                      ),
                      if (series.indexOfBusiest() >= 0)
                        Text(
                          tr('tv_busiest_period', namedArgs: {
                            'unit': tr('ins_unit_${series.unitLabel}'),
                            'label': series
                                .buckets[series.indexOfBusiest()].fullLabel,
                            'time': _duration(
                                series.buckets[series.indexOfBusiest()].totalMs)
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _statGrid(insights),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    for (final section in _sections.keys)
                      TvPillButton(
                        label: _sectionLabel(section),
                        semanticLabel: tr('tv_jump_insights',
                            namedArgs: {'section': _sectionLabel(section)}),
                        onActivate: () => _jumpTo(section),
                      ),
                  ],
                ),
                _heading(tr('ins_time_title'), _sections['Time']!),
                _columns(<Widget>[
                  _facts(tr('ins_consistency'), <(String, String)>[
                    (
                      tr('tv_active_days'),
                      tr('tv_active_days_of', namedArgs: {
                        'active': '${insights.activeDays}',
                        'total': '${insights.periodDays}'
                      })
                    ),
                    (
                      tr('tv_current_streak'),
                      plural('tv_days_count', insights.currentStreakDays(),
                          name: 'count')
                    ),
                    (
                      tr('tv_longest_streak'),
                      plural('tv_days_count', insights.longestStreakDays,
                          name: 'count')
                    ),
                    (
                      tr('tv_typical_active_day'),
                      _duration(insights.medianActiveDayMs)
                    ),
                  ]),
                  _facts(tr('tv_what_you_watched'), <(String, String)>[
                    (tr('movies'), _duration(insights.movieMs)),
                    (tr('episodes'), _duration(insights.episodeMs)),
                    (tr('live_tv'), _duration(insights.liveMs)),
                    (
                      tr('tv_longest_session'),
                      _duration(insights.longestSessionMs)
                    ),
                    if (insights.hasNetworkUsage)
                      (
                        tr('tv_data_used'),
                        '${_dataSize(insights.networkBytes)} · '
                            '${_dataSize(insights.networkBytesPerHour)}/h'
                      ),
                  ]),
                ]),
                _heading(tr('ins_titles_title'), _sections['Titles']!),
                _columns(<Widget>[
                  _facts(tr('ins_follow_through'), <(String, String)>[
                    (
                      tr('tv_started'),
                      plural('tv_title_count', insights.titlesStarted,
                          name: 'count')
                    ),
                    (
                      tr('tv_finished'),
                      '${insights.completedTitles} · ${_percent(insights.completionRate)}'
                    ),
                    (tr('tv_sampled'), '${insights.sampledTitles}'),
                    (tr('tv_rewatched'), '${insights.rewatches}'),
                    (
                      tr('tv_average_session'),
                      _duration(insights.averageSessionMs)
                    ),
                  ]),
                  _ranked(tr('ins_most_watched'), insights.topTitles),
                  if (insights.topSeriesEpisodes.isNotEmpty)
                    _ranked(
                      tr('ins_series_kept'),
                      insights.topSeriesEpisodes,
                      format: (value) =>
                          plural('tv_episodes_count', value, name: 'count'),
                    ),
                  _facts(tr('tv_recent_viewing'), <(String, String)>[
                    for (final session in insights.sessions.take(5))
                      (
                        session.title,
                        '${_duration(session.watchedMs)} · ${tr(switch (session.viewingStatus) {
                          'completed' => 'ins_completed',
                          'sampled' => 'ins_sampled',
                          _ => 'ins_in_progress'
                        })}',
                      ),
                  ]),
                ]),
                _heading(tr('ins_taste_title'), _sections['Taste']!),
                _columns(<Widget>[
                  _ranked(tr('genres'), insights.topGenres),
                  _ranked(tr('ins_languages'), insights.topLanguages),
                  _ranked(tr('ins_countries'), insights.topCountries),
                  _ranked(tr('ins_decades'), insights.topDecades),
                  _ranked(tr('ins_providers'), insights.topProviders),
                ]),
                _heading(tr('ins_patterns_title'), _sections['Patterns']!),
                _InsightPanel(
                  title: tr('ins_weekly_rhythm'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(tr(
                          'tv_viewing_by_weekday_and_hour_across_this_range')),
                      const SizedBox(height: 14),
                      WellnessHeatmap(
                        values: insights.hourOfWeekMs,
                        rowHeight: widget.metrics.compact ? 18 : 22,
                        surfaceColor: TvDesign.surfaceFor(context),
                      ),
                      if (insights.peakHourOfWeek case final peak?)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            tr('tv_busiest_window', namedArgs: {
                              'day': _weekdays[peak.$1],
                              'hour': _hourLabel(peak.$2),
                              'time': _duration(peak.$3)
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _columns(<Widget>[
                  _facts(tr('tv_days_of_the_week'), <(String, String)>[
                    for (var day = 0; day < 7; day++)
                      (
                        _weekdays[day],
                        _duration(insights.weekdayTotalsMs[day])
                      ),
                  ]),
                  _facts(tr('tv_parts_of_the_day'), <(String, String)>[
                    for (var part = 0; part < 4; part++)
                      (_dayParts[part], _duration(insights.partOfDayMs[part])),
                  ]),
                  _facts(tr('tv_viewing_patterns'), <(String, String)>[
                    (tr('tv_weekdays'), _duration(insights.weekdayWatchedMs)),
                    (tr('tv_weekends'), _duration(insights.weekendWatchedMs)),
                    (tr('ins_late_night'), _duration(insights.lateNightMs)),
                  ]),
                ]),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

String _sectionLabel(String section) => tr(switch (section) {
      'Time' => 'ins_time',
      'Titles' => 'ins_titles',
      'Taste' => 'ins_taste',
      _ => 'ins_patterns'
    });

List<String> get _weekdays => List.generate(
    7, (day) => DateFormat.EEEE().format(DateTime(2024, 1, day + 1)));
List<String> get _dayParts => <String>[
      tr('ins_morning'),
      tr('ins_afternoon'),
      tr('ins_evening'),
      tr('ins_late_night')
    ];

String _rangeLabel(WellnessRange range) => switch (range) {
      WellnessRange.week => tr('ins_week'),
      WellnessRange.month => tr('ins_month'),
      WellnessRange.year => tr('year'),
      WellnessRange.allTime => tr('ins_all_time'),
    };

String _duration(int milliseconds) {
  final minutes = Duration(milliseconds: milliseconds).inMinutes;
  return tr('tv_duration',
      namedArgs: {'hours': '${minutes ~/ 60}', 'minutes': '${minutes % 60}'});
}

String _percent(double value) => '${(value * 100).round()}%';

String _hourLabel(int hour) =>
    DateFormat.j().format(DateTime(2024, 1, 1, hour));

Widget _heading(String title, Key key) => Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(0, 34, 0, 14),
      child: Builder(
        builder: (context) => Text(
          title,
          style: TextStyle(
            color: TvPalette.of(context).foreground,
            fontFamily: 'FigtreeBold',
            fontSize: 25,
          ),
        ),
      ),
    );

Widget _columns(List<Widget> children) => LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final columns = constraints.maxWidth >= 700 ? 2 : 1;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );

Widget _statGrid(WellnessInsights insights) => LayoutBuilder(
      builder: (context, constraints) {
        final palette = TvPalette.of(context);
        const gap = 12.0;
        final columns = constraints.maxWidth >= 800 ? 3 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final stats = <(String, String, IconData)>[
          (
            tr('movies'),
            '${insights.completedMovies}',
            PhosphorIcons.filmSlate()
          ),
          (
            tr('episodes'),
            '${insights.completedEpisodes}',
            PhosphorIcons.television()
          ),
          (tr('series'), '${insights.uniqueSeries}', PhosphorIcons.stack()),
          (
            tr('tv_sessions'),
            '${insights.sessionCount}',
            PhosphorIcons.playCircle()
          ),
          (
            tr('tv_active_days'),
            '${insights.activeDays}',
            PhosphorIcons.calendarDots()
          ),
          (
            tr('tv_rewatches'),
            '${insights.rewatches}',
            PhosphorIcons.arrowCounterClockwise()
          ),
        ];
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final stat in stats)
              SizedBox(
                width: width,
                child: _InsightPanel(
                  title: stat.$1,
                  child: Row(
                    children: <Widget>[
                      Icon(stat.$3, color: palette.mutedText),
                      const SizedBox(width: 12),
                      Text(
                        stat.$2,
                        style: TextStyle(
                          color: palette.foreground,
                          fontFamily: 'FigtreeBold',
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );

String _dataSize(int bytes) {
  const units = <String>['KB', 'MB', 'GB', 'TB'];
  if (bytes < 1024) return '$bytes B';
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(value < 10 ? 1 : 0)} ${units[unit]}';
}

Widget _facts(String title, List<(String, String)> rows) => _InsightPanel(
      title: title,
      child: Column(
        children: <Widget>[
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Builder(
                      builder: (context) => Text(
                        row.$2,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: TvPalette.of(context).foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

Widget _ranked(
  String title,
  List<WellnessRankedValue> values, {
  String Function(int)? format,
}) =>
    _facts(
      title,
      values.isEmpty
          ? <(String, String)>[
              (tr('tv_more_viewing_will_reveal_this_insight'), '')
            ]
          : <(String, String)>[
              for (final value in values.take(5))
                (value.label, (format ?? _duration)(value.value)),
            ],
    );

/// Read-only panels are focusable so arrow keys reveal each part of the
/// scrollable report, including sections below the first TV viewport.
class _InsightPanel extends StatefulWidget {
  const _InsightPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  State<_InsightPanel> createState() => _InsightPanelState();
}

class _InsightPanelState extends State<_InsightPanel> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final palette = TvPalette.of(context);
    return Focus(
      onFocusChange: (focused) {
        setState(() => _focused = focused);
        if (focused) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 220),
              alignment: 0.12,
            );
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TvDesign.surfaceFor(context),
          borderRadius: BorderRadius.circular(TvDesign.cardRadius),
          border: Border.all(
            color: _focused ? palette.foreground : palette.hairline,
            width: _focused ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(
                color: palette.foreground,
                fontFamily: 'FigtreeBold',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 14),
            DefaultTextStyle(
              style: TextStyle(color: palette.mutedText, fontSize: 16),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
