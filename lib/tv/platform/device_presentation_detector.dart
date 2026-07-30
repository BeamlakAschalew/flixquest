import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_presentation.dart';

const _forceTvModeFromEnvironment = bool.fromEnvironment('FQ_FORCE_TV_MODE');

class MethodChannelDevicePresentationDetector
    implements DevicePresentationDetector {
  const MethodChannelDevicePresentationDetector({
    MethodChannel channel = const MethodChannel(
      'dev.beamlak.flixquest/device_presentation',
    ),
    TargetPlatform? platformOverride,
    bool? isWebOverride,
    bool forceTvMode = _forceTvModeFromEnvironment,
  })  : _channel = channel,
        _platformOverride = platformOverride,
        _isWebOverride = isWebOverride,
        _forceTvMode = forceTvMode;

  final MethodChannel _channel;
  final TargetPlatform? _platformOverride;
  final bool? _isWebOverride;
  final bool _forceTvMode;

  @override
  Future<DevicePresentation> detect() async {
    if (_forceTvMode && kDebugMode) {
      return DevicePresentation.television;
    }

    final isWeb = _isWebOverride ?? kIsWeb;
    final platform = _platformOverride ?? defaultTargetPlatform;
    if (isWeb || platform != TargetPlatform.android) {
      return DevicePresentation.handheld;
    }

    try {
      final isTelevision =
          await _channel.invokeMethod<bool>('isTelevision') ?? false;
      return isTelevision
          ? DevicePresentation.television
          : DevicePresentation.handheld;
    } on Object {
      return DevicePresentation.handheld;
    }
  }
}

Future<DevicePresentation> resolveDevicePresentation({
  DevicePresentationDetector? detector,
}) {
  return (detector ?? const MethodChannelDevicePresentationDetector()).detect();
}
