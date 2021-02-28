import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2887406119671521~7279352894";
      // return "ca-app-pub-3940256099942544~3347511713";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2887406119671521~4124873224";
      // return "ca-app-pub-3940256099942544/2934735716";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2887406119671521/6866139520";
      // return "ca-app-pub-3940256099942544/6300978111";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2887406119671521/1598975754";
      // return "ca-app-pub-3940256099942544/2934735716";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2887406119671521/6866139520";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2887406119671521/1598975754";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2887406119671521/6866139520";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2887406119671521/1598975754";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}