import 'dart:io' show Platform;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class VersionCheckService {
  static const String ANDROID_CONFIG_VERSION =
      "android_force_update_app_version";
  static const String IOS_CONFIG_VERSION = "ios_force_update_app_version";

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<bool> versionCheck() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(hours: 6),
      // minimumFetchInterval: Duration.zero,
    ));
    await _remoteConfig.fetchAndActivate();

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    String requiredVersion;
    if (Platform.isAndroid) {
      requiredVersion = _remoteConfig.getString(ANDROID_CONFIG_VERSION);
      print("Current Version: $currentVersion");
      print("Required Android Version: $requiredVersion");
    } else if (Platform.isIOS) {
      requiredVersion = _remoteConfig.getString(IOS_CONFIG_VERSION);
      print("Current Version: $currentVersion");
      print("Required iOS Version: $requiredVersion");
    } else {
      return false; // AndroidまたはiOS以外の場合はスキップ
    }

    return _isVersionOutdated(currentVersion, requiredVersion);
  }

  bool _isVersionOutdated(String currentVersion, String requiredVersion) {
    final current = Version.parse(currentVersion);
    final required = Version.parse(requiredVersion);
    return current < required;
  }
}
