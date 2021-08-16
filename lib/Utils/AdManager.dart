import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-1263585791218775~7583046167";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1263585791218775~7590785020";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-1263585791218775/2530030030";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1263585791218775/1570325675";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "<YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID>";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "<YOUR_ANDROID_REWARDED_AD_UNIT_ID>";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_REWARDED_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}