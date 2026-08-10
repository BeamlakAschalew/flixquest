import 'package:flixquest/services/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  final packageInfo = PackageInfo(
    appName: 'FlixQuest',
    packageName: 'com.example.flixquest',
    version: '4.0.0',
    buildNumber: '3',
  );

  test('build number takes precedence when checking for an update', () {
    expect(
      AppUpdateService.isAvailable(
        packageInfo: packageInfo,
        remoteVersion: '4.0.0',
        latestBuildNumber: 4,
        minimumBuildNumber: 0,
      ),
      isTrue,
    );
    expect(
      AppUpdateService.isAvailable(
        packageInfo: packageInfo,
        remoteVersion: '9.0.0',
        latestBuildNumber: 3,
        minimumBuildNumber: 0,
      ),
      isFalse,
    );
  });

  test('semantic version fallback only reports newer releases', () {
    expect(
      AppUpdateService.isAvailable(
        packageInfo: packageInfo,
        remoteVersion: '4.1.0',
        latestBuildNumber: 0,
        minimumBuildNumber: 0,
      ),
      isTrue,
    );
    expect(
      AppUpdateService.isAvailable(
        packageInfo: packageInfo,
        remoteVersion: '3.9.9',
        latestBuildNumber: 0,
        minimumBuildNumber: 0,
      ),
      isFalse,
    );
  });

  test('notification identity follows the configured build or version', () {
    expect(
      AppUpdateService.notificationId(
        remoteVersion: '4.1.0',
        latestBuildNumber: 5,
        minimumBuildNumber: 0,
      ),
      '5',
    );
    expect(
      AppUpdateService.notificationId(
        remoteVersion: '4.1.0',
        latestBuildNumber: 0,
        minimumBuildNumber: 0,
      ),
      '4.1.0',
    );
  });
}
