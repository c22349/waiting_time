import 'dart:io';
import 'package:flutter/foundation.dart';

String getAdBannerUnitId() {
  String bannerUnitId = "";
  if (Platform.isAndroid) {
    // Androidの場合
    bannerUnitId = kDebugMode
        ? "ca-app-pub-3940256099942544/6300978111" // Androidのデモ用バナー広告ID
        : "ca-app-pub-6406325278701298/2538907813";
  } else if (Platform.isIOS) {
    // iOSの場合
    bannerUnitId = kDebugMode
        ? "ca-app-pub-3940256099942544/2934735716" // iOSのデモ用バナー広告ID
        : "ca-app-pub-6406325278701298/3610584391";
  }
  return bannerUnitId;
}
