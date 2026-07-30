import 'package:flutter/foundation.dart';

abstract final class TvDebugOptions {
  static const _previewHomeShellFromEnvironment = bool.fromEnvironment(
    'FQ_PREVIEW_TV_HOME',
  );

  /// Lets a signed-out development emulator enter the Phase 2 shell without
  /// adding an authentication flow before Phase 3. This is always false in
  /// profile and release builds, even if the Dart define is supplied.
  static bool get previewHomeShell {
    return kDebugMode && _previewHomeShellFromEnvironment;
  }
}
