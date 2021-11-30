import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;
  AdState(this.initialization);

  String get InterstitialAdId => Platform.isAndroid
      ? 'ca-app-pub-8734362508424778/4512110050'
      : 'ca-app-pub-8734362508424778/8911176602';
}
