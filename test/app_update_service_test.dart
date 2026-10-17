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

  group('resolveDownloadUrl', () {
    const universal = 'https://example.com/flixquest.apk';
    const abiUrls = {
      'arm64-v8a': 'https://example.com/flixquest-arm64-v8a.apk',
      'armeabi-v7a': 'https://example.com/flixquest-armeabi-v7a.apk',
    };

    test('picks the most preferred ABI that has a link', () {
      expect(
        AppUpdateService.resolveDownloadUrl(
          deviceAbis: const ['arm64-v8a', 'armeabi-v7a', 'armeabi'],
          abiUrls: abiUrls,
          universalUrl: universal,
        ),
        abiUrls['arm64-v8a'],
      );
    });

    test('falls through to a compatible ABI when the preferred one is empty',
        () {
      expect(
        AppUpdateService.resolveDownloadUrl(
          deviceAbis: const ['arm64-v8a', 'armeabi-v7a'],
          abiUrls: {...abiUrls, 'arm64-v8a': '  '},
          universalUrl: universal,
        ),
        abiUrls['armeabi-v7a'],
      );
    });

    test('uses the universal APK when the ABI is unknown or unpublished', () {
      expect(
        AppUpdateService.resolveDownloadUrl(
          deviceAbis: const [],
          abiUrls: abiUrls,
          universalUrl: universal,
        ),
        universal,
      );
      expect(
        AppUpdateService.resolveDownloadUrl(
          deviceAbis: const ['x86_64'],
          abiUrls: abiUrls,
          universalUrl: universal,
        ),
        universal,
      );
    });
  });
}
