import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class SettingModel with ChangeNotifier {
  // 初期値
  bool _startPageA = true;
  bool get startPageA => _startPageA;

  // SharedPreferencesへの設定値の保存と通知を行う非同期メソッド
  Future<void> setStartPageA(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("startPageA", value);
    _startPageA = value;
    notifyListeners(); // 設定が変更されたことをリスナーに通知
  }

  // SharedPreferencesから設定値を読み込む非同期メソッド
  Future<void> getSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final startPageAValue = prefs.getBool("startPageA") ?? false;
    _startPageA = startPageAValue;
    notifyListeners();
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedLanguage", languageCode);
    notifyListeners();
  }

  Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("selectedLanguage") ?? "ja";
  }
}
