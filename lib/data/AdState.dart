import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  static String get BannerAdId => Platform.isAndroid
      ? 'ca-app-pub-8734362508424778/5281092780'
      : 'ca-app-pub-8734362508424778/1891662051';

  static String get InterstitialAdId => Platform.isAndroid
      ? 'ca-app-pub-8734362508424778/4512110050'
      : 'ca-app-pub-8734362508424778/8911176602';
}
