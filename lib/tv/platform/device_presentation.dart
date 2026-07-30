enum DevicePresentation { handheld, television }

abstract interface class DevicePresentationDetector {
  Future<DevicePresentation> detect();
}
