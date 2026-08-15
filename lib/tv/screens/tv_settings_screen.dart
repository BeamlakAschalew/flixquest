import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/app_colors.dart';
import '../../provider/settings_provider.dart';
import '../../provider/app_dependency_provider.dart';
import '../app/tv_design.dart';
import '../focus/tv_screen_focus_controller.dart';
import '../focus/tv_focusable.dart';
import '../widgets/tv_dialog.dart';

class TvSettingsScreen extends StatelessWidget {
  const TvSettingsScreen({
    required this.metrics,
    this.focusController,
    super.key,
  });

  final TvShellMetrics metrics;
  final TvScreenFocusController? focusController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();
    final appDependencies = context.watch<AppDependencyProvider>();
    final occasionalCatalog = appDependencies.occasionalThemeCatalog;
    final occasionalThemes = appDependencies.availableOccasionalThemes;
    return _TvSettingsFocusEntry(
      focusController: focusController,
      builder: (themeFocusNode) => Padding(
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
                      key: const ValueKey<String>('theme-mode'),
                      focusNode: themeFocusNode,
                      label: 'Theme mode',
                      value: _themeLabel(settings.appTheme),
                      icon: PhosphorIcons.moonStars(),
                      onActivate: () => _showThemeModePicker(context, settings),
                    ),
                    const SizedBox(height: 14),
                    _TvSettingTile(
                      key: const ValueKey<String>('ambient-mode'),
                      label: 'Ambient mode',
                      value: appDependencies.ambientModeEnabled ? 'On' : 'Off',
                      icon: PhosphorIcons.imageSquare(),
                      onActivate: () => appDependencies.ambientModeEnabled =
                          !appDependencies.ambientModeEnabled,
                    ),
                    if (occasionalCatalog.enabled) ...<Widget>[
                      const SizedBox(height: 14),
                      _TvSettingTile(
                        key: const ValueKey<String>('seasonal-themes'),
                        label: 'Seasonal themes',
                        value: appDependencies.occasionalThemeEnabled
                            ? 'On'
                            : 'Off',
                        icon: PhosphorIcons.sparkle(),
                        onActivate: () =>
                            appDependencies.occasionalThemeEnabled =
                                !appDependencies.occasionalThemeEnabled,
                      ),
                    ],
                    if (occasionalCatalog.enabled &&
                        appDependencies.occasionalThemeEnabled &&
                        occasionalCatalog.allowUserSelection &&
                        occasionalThemes.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 14),
                      _TvSettingTile(
                        key: const ValueKey<String>('seasonal-theme'),
                        label: 'Seasonal theme',
                        value: _occasionalThemeLabel(appDependencies),
                        icon: PhosphorIcons.sparkle(),
                        onActivate: () => _showOccasionalThemePicker(
                          context,
                          appDependencies,
                        ),
                      ),
                    ],
                    if (occasionalCatalog.enabled &&
                        appDependencies.occasionalThemeEnabled &&
                        occasionalCatalog.effectsEnabled &&
                        occasionalCatalog.allowUserEffectsToggle) ...<Widget>[
                      const SizedBox(height: 14),
                      _TvSettingTile(
                        key: const ValueKey<String>('seasonal-effects'),
                        label: 'Seasonal effects',
                        value: appDependencies.occasionalEffectsEnabled
                            ? 'On'
                            : 'Off',
                        icon: PhosphorIcons.sparkle(),
                        onActivate: () =>
                            appDependencies.occasionalEffectsEnabled =
                                !appDependencies.occasionalEffectsEnabled,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _TvSettingTile(
                      key: const ValueKey<String>('color-theme'),
                      label: 'Color theme',
                      value: _colorThemeLabel(settings.appColorIndex),
                      icon: PhosphorIcons.palette(),
                      onActivate: () => _showColorThemePicker(context),
                    ),
                    const SizedBox(height: 14),
                    _TvSettingTile(
                      key: const ValueKey<String>('tmdb-proxy'),
                      label: 'TMDB proxy',
                      value: settings.enableProxy ? 'On' : 'Off',
                      icon: PhosphorIcons.globeHemisphereWest(),
                      onActivate: () =>
                          settings.enableProxy = !settings.enableProxy,
                    ),
                    const SizedBox(height: 14),
                    _TvSettingTile(
                      key: const ValueKey<String>('image-quality'),
                      label: 'Image quality',
                      value: _imageQualityLabel(settings.imageQuality),
                      icon: PhosphorIcons.image(),
                      onActivate: () =>
                          _showImageQualityPicker(context, settings),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  static String _imageQualityLabel(String value) {
    return switch (value) {
      'original/' => 'High',
      'w600_and_h900_bestv2/' => 'Medium',
      _ => 'Low',
    };
  }

  static String _occasionalThemeLabel(AppDependencyProvider provider) {
    if (provider.selectedOccasionalThemeId == 'automatic') return 'Automatic';
    for (final theme in provider.availableOccasionalThemes) {
      if (theme.id == provider.selectedOccasionalThemeId) {
        return theme.displayName;
      }
    }
    return 'Automatic';
  }

  static String _colorThemeLabel(int index) => switch (index) {
        -1 => 'FlixQuest',
        1 => 'Indigo',
        2 => 'Pink',
        3 => 'Emerald',
        4 => 'Amber',
        5 => 'Violet',
        6 => 'Cyan',
        7 => 'Red',
        8 => 'Teal',
        9 => 'Orange',
        10 => 'Purple',
        11 => 'Blue',
        12 => 'Lime',
        13 => 'Rose',
        14 => 'Sky blue',
        15 => 'Green',
        16 => 'Yellow',
        17 => 'Slate',
        18 => 'Fuchsia',
        19 => 'Deep emerald',
        20 => 'Coral',
        _ => 'FlixQuest',
      };

  static Future<void> _showThemeModePicker(
    BuildContext context,
    SettingsProvider settings,
  ) {
    const options = <String, String>{
      'dark': 'Dark',
      'light': 'Light',
      'amoled': 'AMOLED',
    };
    return showTvDialog<void>(
      context: context,
      title: 'Theme mode',
      content: const Text('Choose how FlixQuest looks on this TV.'),
      actions: <TvDialogAction>[
        for (final option in options.entries)
          TvDialogAction(
            label: option.value,
            autofocus: settings.appTheme == option.key,
            isPrimary: settings.appTheme == option.key,
            onPressed: () {
              settings.appTheme = option.key;
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  static Future<void> _showImageQualityPicker(
    BuildContext context,
    SettingsProvider settings,
  ) {
    const options = <String, String>{
      'original/': 'High',
      'w600_and_h900_bestv2/': 'Medium',
      'w500/': 'Low',
    };
    return showTvDialog<void>(
      context: context,
      title: 'Image quality',
      content: const Text(
        'Higher quality uses more bandwidth and may load more slowly.',
      ),
      actions: <TvDialogAction>[
        for (final option in options.entries)
          TvDialogAction(
            label: option.value,
            autofocus: settings.imageQuality == option.key,
            isPrimary: settings.imageQuality == option.key,
            onPressed: () {
              settings.imageQuality = option.key;
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  static Future<void> _showColorThemePicker(BuildContext context) {
    return showTvDialog<void>(
      context: context,
      title: 'Color theme',
      content: const _TvColorThemePicker(),
      autofocusFirstAction: false,
      actions: <TvDialogAction>[
        TvDialogAction(
          label: 'Done',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  static Future<void> _showOccasionalThemePicker(
    BuildContext context,
    AppDependencyProvider provider,
  ) {
    final options = <String, String>{
      'automatic': 'Automatic',
      for (final theme in provider.availableOccasionalThemes)
        theme.id: theme.displayName,
    };
    return showTvDialog<void>(
      context: context,
      title: 'Seasonal theme',
      content: const Text(
        'Automatic uses the highest-priority active occasion.',
      ),
      actions: <TvDialogAction>[
        for (final option in options.entries)
          TvDialogAction(
            label: option.value,
            autofocus: provider.selectedOccasionalThemeId == option.key,
            isPrimary: provider.selectedOccasionalThemeId == option.key,
            onPressed: () {
              provider.selectOccasionalTheme(option.key);
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}

class _TvSettingsFocusEntry extends StatefulWidget {
  const _TvSettingsFocusEntry({
    required this.builder,
    this.focusController,
  });

  final Widget Function(FocusNode themeFocusNode) builder;
  final TvScreenFocusController? focusController;

  @override
  State<_TvSettingsFocusEntry> createState() => _TvSettingsFocusEntryState();
}

class _TvSettingsFocusEntryState extends State<_TvSettingsFocusEntry> {
  final FocusNode _themeFocusNode =
      FocusNode(debugLabel: 'TV setting theme mode');

  @override
  void initState() {
    super.initState();
    widget.focusController?.attach(this, _requestFocus);
  }

  @override
  void didUpdateWidget(_TvSettingsFocusEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.focusController, widget.focusController)) {
      oldWidget.focusController?.detach(this);
      widget.focusController?.attach(this, _requestFocus);
    }
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _themeFocusNode.context == null ||
          !_themeFocusNode.canRequestFocus) {
        return;
      }
      _themeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.focusController?.detach(this);
    _themeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_themeFocusNode);
}

class _TvColorThemePicker extends StatefulWidget {
  const _TvColorThemePicker();

  @override
  State<_TvColorThemePicker> createState() => _TvColorThemePickerState();
}

class _TvColorThemePickerState extends State<_TvColorThemePicker> {
  final Map<int, FocusNode> _focusNodes = <int, FocusNode>{};

  FocusNode _nodeFor(int index) {
    return _focusNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'color-$index'),
    );
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _selectColor(SettingsProvider settings, int index) {
    settings.appColorIndex = index;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colors = Theme.of(context).colorScheme;
    final isDark = settings.appTheme == 'dark' || settings.appTheme == 'amoled';
    final palette = AppColorsList().appColors(isDark);
    final selectedIndex =
        palette.any((color) => color.index == settings.appColorIndex)
            ? settings.appColorIndex
            : palette.first.index;

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: <Widget>[
        for (final appColor in palette)
          TvFocusable(
            key: ValueKey<int>(appColor.index),
            focusNode: _nodeFor(appColor.index),
            semanticLabel:
                '${TvSettingsScreen._colorThemeLabel(appColor.index)} color theme'
                '${selectedIndex == appColor.index ? ', selected' : ''}',
            autofocus: selectedIndex == appColor.index,
            focusScale: 1.025,
            onActivate: () => _selectColor(settings, appColor.index),
            child: Container(
              width: 116,
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: appColor.cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: selectedIndex == appColor.index
                        ? Icon(
                            PhosphorIcons.check(PhosphorIconsStyle.bold),
                            size: 17,
                            color: appColor.cs.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      TvSettingsScreen._colorThemeLabel(appColor.index),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontFamily: 'FigtreeSB',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TvSettingTile extends StatelessWidget {
  const _TvSettingTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onActivate,
    this.focusNode,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onActivate;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TvFocusable(
      focusNode: focusNode,
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
