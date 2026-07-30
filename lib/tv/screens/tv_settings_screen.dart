import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../provider/settings_provider.dart';
import '../app/tv_design.dart';
import '../focus/tv_focusable.dart';

class TvSettingsScreen extends StatelessWidget {
  const TvSettingsScreen({required this.metrics, super.key});

  final TvShellMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.contentPadding,
        0,
        metrics.contentPadding,
        metrics.contentPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(PhosphorIcons.gear(), color: colors.primary, size: 32),
              const SizedBox(width: 13),
              Text(
                'Settings',
                style: TextStyle(
                  color: colors.onSurface,
                  fontFamily: 'FigtreeSB',
                  fontSize: 34,
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.compact ? 18 : 28),
          Expanded(
            child: SingleChildScrollView(
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.all(TvDesign.focusOutset),
              child: Column(
                children: <Widget>[
                  _TvSettingTile(
                    label: 'Appearance',
                    value: _themeLabel(settings.appTheme),
                    icon: PhosphorIcons.moonStars(),
                    onActivate: () =>
                        settings.appTheme = _nextTheme(settings.appTheme),
                  ),
                  const SizedBox(height: 14),
                  _TvSettingTile(
                    label: 'Adult content',
                    value: settings.isAdult ? 'Included' : 'Hidden',
                    icon: PhosphorIcons.shieldCheck(),
                    onActivate: () => settings.isAdult = !settings.isAdult,
                  ),
                  const SizedBox(height: 14),
                  _TvSettingTile(
                    label: 'TMDB proxy',
                    value: settings.enableProxy ? 'On' : 'Off',
                    icon: PhosphorIcons.globeHemisphereWest(),
                    onActivate: () =>
                        settings.enableProxy = !settings.enableProxy,
                  ),
                  const SizedBox(height: 14),
                  _TvSettingTile(
                    label: 'Image quality',
                    value: settings.imageQuality.replaceAll('/', ''),
                    icon: PhosphorIcons.image(),
                    onActivate: () => settings.imageQuality =
                        settings.imageQuality == 'w500/'
                            ? 'original/'
                            : 'w500/',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _themeLabel(String value) {
    return switch (value) {
      'amoled' => 'AMOLED',
      'light' => 'Light',
      _ => 'Dark',
    };
  }

  static String _nextTheme(String current) {
    return switch (current) {
      'dark' => 'amoled',
      'amoled' => 'light',
      _ => 'dark',
    };
  }
}

class _TvSettingTile extends StatelessWidget {
  const _TvSettingTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onActivate,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TvFocusable(
      semanticLabel: '$label, $value',
      onActivate: onActivate,
      focusScale: 1.015,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: TvDesign.surfaceFor(context, emphasis: 0.025),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.38),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: colors.primary, size: 27),
            const SizedBox(width: 17),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.onSurface,
                  fontFamily: 'FigtreeSB',
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 19,
              ),
            ),
            const SizedBox(width: 15),
            Icon(PhosphorIcons.caretRight(),
                color: colors.onSurfaceVariant, size: 21),
          ],
        ),
      ),
    );
  }
}
