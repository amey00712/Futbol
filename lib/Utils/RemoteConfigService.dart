import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final RemoteConfig _remoteConfig;

  static RemoteConfigService _instance;
  bool get showMainBanner => _remoteConfig.getBool('showBannerAd');

  static Future<RemoteConfigService> getInstance() async {
    if (_instance == null) {
      _instance = RemoteConfigService(
        remoteConfig: await RemoteConfig.instance,
      );
    }

    return _instance;
  }

   Future _fetchAndActivate() async {
     await _remoteConfig.setConfigSettings(RemoteConfigSettings(
       fetchTimeout: Duration(seconds: 10),
       minimumFetchInterval: Duration(seconds: 1),
     ));
     await _remoteConfig.fetchAndActivate();
  }
  RemoteConfigService({RemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;
}