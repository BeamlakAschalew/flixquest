import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../models/occasional_theme.dart';
import '../preferences/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  final AppDependencies _preferences = AppDependencies();

  String _flixquestAPIUrl = flixquestApiUrl;
  String get flixquestAPIURL => _flixquestAPIUrl;

  String _flixQuestLogo = 'default';
  String get flixQuestLogo => _flixQuestLogo;

  bool _displayWatchNowButton = true;
  bool get displayWatchNowButton => _displayWatchNowButton;

  bool _displayOTTDrawer = true;
  bool get displayOTTDrawer => _displayOTTDrawer;

  bool _isForcedUpdate = false;
  bool get isForcedUpdate => _isForcedUpdate;

  String _tmdbProxy = '';
  String get tmdbProxy => _tmdbProxy;

  OccasionalThemeCatalog _occasionalThemeCatalog =
      const OccasionalThemeCatalog.disabled();
  String _selectedOccasionalThemeId = 'automatic';
  bool _occasionalThemeEnabled = true;
  bool _occasionalEffectsEnabled = true;
  bool _ambientModeEnabled = false;
  int _nextAmbientScopeId = 0;
  final Map<int, Color?> _ambientScopes = <int, Color?>{};
  int _nextEffectSuppressionId = 0;
  final Set<int> _effectSuppressionScopes = <int>{};
  Timer? _occasionalThemeBoundaryTimer;

  OccasionalThemeCatalog get occasionalThemeCatalog => _occasionalThemeCatalog;
  String get selectedOccasionalThemeId => _selectedOccasionalThemeId;
  bool get occasionalThemeEnabled => _occasionalThemeEnabled;
  bool get occasionalEffectsEnabled => _occasionalEffectsEnabled;
  bool get ambientModeEnabled => _ambientModeEnabled;
  Color? get activeAmbientColor {
    if (!_ambientModeEnabled || activeOccasionalTheme != null) return null;
    for (final color in _ambientScopes.values.toList().reversed) {
      if (color != null) return color;
    }
    return null;
  }

  List<OccasionalTheme> get availableOccasionalThemes =>
      _occasionalThemeCatalog.activeThemes
          .where((theme) => theme.userSelectable)
          .toList(growable: false);
  OccasionalTheme? get activeOccasionalTheme => !_occasionalThemeEnabled
      ? null
      : _occasionalThemeCatalog.resolve(
          selectedThemeId: _selectedOccasionalThemeId,
        );
  bool get shouldShowOccasionalEffects {
    final theme = activeOccasionalTheme;
    return theme != null &&
        _occasionalThemeCatalog.effectsEnabled &&
        _occasionalEffectsEnabled &&
        _effectSuppressionScopes.isEmpty &&
        theme.effect.enabled &&
        theme.effect.type != OccasionalEffectType.none;
  }

  String get effectiveLogoUrl {
    final occasionalLogo = activeOccasionalTheme?.logoUrl.trim() ?? '';
    if (occasionalLogo.isNotEmpty) return occasionalLogo;
    return _flixQuestLogo == 'default' ? '' : _flixQuestLogo.trim();
  }

  Future<void> getFQUrl() async {
    flixquestAPIURL = await _preferences.getFQURL();
  }

  set flixquestAPIURL(String value) {
    _flixquestAPIUrl = value;
    _preferences.setFlixquestAPIUrl(value);
    notifyListeners();
  }

  Future<void> getFlixQuestLogo() async {
    flixQuestLogo = await _preferences.getFlixQuestLogo();
  }

  set flixQuestLogo(String value) {
    final normalized = value.trim().isEmpty ? 'default' : value.trim();
    if (_flixQuestLogo == normalized) return;
    _flixQuestLogo = normalized;
    _preferences.setFlixQuestUrl(normalized);
    notifyListeners();
  }

  set displayWatchNowButton(bool value) {
    _displayWatchNowButton = value;
    notifyListeners();
  }

  set displayOTTDrawer(bool value) {
    _displayOTTDrawer = value;
    notifyListeners();
  }

  set isForcedUpdate(bool value) {
    _isForcedUpdate = value;
    notifyListeners();
  }

  Future<void> getTmdbProxy() async {
    tmdbProxy = await _preferences.getTmdbProxy();
  }

  set tmdbProxy(String value) {
    _tmdbProxy = value;
    _preferences.setTmdbProxy(value);
    notifyListeners();
  }

  Future<void> getOccasionalTheme() async {
    _occasionalThemeCatalog = OccasionalThemeCatalog.fromJsonString(
      await _preferences.getOccasionalTheme(),
    );
    _selectedOccasionalThemeId =
        (await _preferences.getOccasionalThemeSelection()).trim().toLowerCase();
    _occasionalThemeEnabled = await _preferences.getOccasionalThemeEnabled();
    _occasionalEffectsEnabled =
        await _preferences.getOccasionalEffectsEnabled();
    _normalizeOccasionalThemeSelection(persist: true);
    _scheduleOccasionalThemeBoundary();
    notifyListeners();
  }

  Future<void> getAmbientMode() async {
    _ambientModeEnabled = await _preferences.getAmbientModeEnabled();
    notifyListeners();
  }

  set ambientModeEnabled(bool value) {
    if (_ambientModeEnabled == value) return;
    _ambientModeEnabled = value;
    _preferences.setAmbientModeEnabled(value);
    notifyListeners();
  }

  int pushAmbientScope() {
    final id = ++_nextAmbientScopeId;
    _ambientScopes[id] = null;
    return id;
  }

  void updateAmbientScope(int id, Color color) {
    if (!_ambientScopes.containsKey(id) || _ambientScopes[id] == color) return;
    _ambientScopes[id] = color;
    notifyListeners();
  }

  void popAmbientScope(int id) {
    if (!_ambientScopes.containsKey(id)) return;
    final wasActive = activeAmbientColor;
    _ambientScopes.remove(id);
    if (wasActive == activeAmbientColor) return;
    notifyListeners();
  }

  int suppressOccasionalEffects() {
    final id = ++_nextEffectSuppressionId;
    final wasSuppressed = _effectSuppressionScopes.isNotEmpty;
    _effectSuppressionScopes.add(id);
    if (!wasSuppressed) notifyListeners();
    return id;
  }

  void releaseOccasionalEffectsSuppression(int id) {
    if (!_effectSuppressionScopes.remove(id)) return;
    if (_effectSuppressionScopes.isEmpty) notifyListeners();
  }

  set occasionalThemeCatalog(OccasionalThemeCatalog value) {
    _occasionalThemeCatalog = value;
    _preferences.setOccasionalTheme(value.toJsonString());
    _normalizeOccasionalThemeSelection(persist: true);
    _scheduleOccasionalThemeBoundary();
    notifyListeners();
  }

  /// Applies a remotely supplied catalog only when it is structurally valid.
  /// Invalid updates leave the persisted/active catalog untouched so built-in
  /// occasion presets continue to provide the fallback experience.
  bool applyRemoteOccasionalTheme(String json) {
    final catalog = OccasionalThemeCatalog.tryFromJsonString(json);
    if (catalog == null) return false;
    occasionalThemeCatalog = catalog;
    return true;
  }

  void selectOccasionalTheme(String id) {
    final normalized = id.trim().toLowerCase();
    if (normalized != 'automatic' &&
        !availableOccasionalThemes.any((theme) => theme.id == normalized)) {
      return;
    }
    if (_selectedOccasionalThemeId == normalized) return;
    _selectedOccasionalThemeId = normalized;
    _preferences.setOccasionalThemeSelection(normalized);
    notifyListeners();
  }

  set occasionalThemeEnabled(bool value) {
    if (_occasionalThemeEnabled == value) return;
    _occasionalThemeEnabled = value;
    _preferences.setOccasionalThemeEnabled(value);
    notifyListeners();
  }

  set occasionalEffectsEnabled(bool value) {
    if (_occasionalEffectsEnabled == value) return;
    _occasionalEffectsEnabled = value;
    _preferences.setOccasionalEffectsEnabled(value);
    notifyListeners();
  }

  void _normalizeOccasionalThemeSelection({required bool persist}) {
    final valid = _selectedOccasionalThemeId == 'automatic' ||
        (_occasionalThemeCatalog.allowUserSelection &&
            availableOccasionalThemes
                .any((theme) => theme.id == _selectedOccasionalThemeId));
    if (valid) return;
    _selectedOccasionalThemeId = 'automatic';
    if (persist) {
      _preferences.setOccasionalThemeSelection('automatic');
    }
  }

  void _scheduleOccasionalThemeBoundary() {
    _occasionalThemeBoundaryTimer?.cancel();
    final now = DateTime.now().toUtc();
    DateTime? boundary;
    for (final theme in _occasionalThemeCatalog.themes) {
      if (!theme.enabled) continue;
      DateTime? candidate;
      if (theme.startsAt != null && now.isBefore(theme.startsAt!.toUtc())) {
        candidate = theme.startsAt!.toUtc();
      } else if (theme.isActiveAt(now) && theme.endsAt != null) {
        candidate = theme.endsAt!.toUtc().add(
              const Duration(milliseconds: 1),
            );
      }
      if (candidate != null &&
          (boundary == null || candidate.isBefore(boundary))) {
        boundary = candidate;
      }
    }
    if (boundary == null) return;
    _occasionalThemeBoundaryTimer = Timer(boundary.difference(now), () {
      _normalizeOccasionalThemeSelection(persist: true);
      _scheduleOccasionalThemeBoundary();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _occasionalThemeBoundaryTimer?.cancel();
    super.dispose();
  }
}
