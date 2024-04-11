import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class SettingModel with ChangeNotifier {
  // 初期値
  bool _startSettingPage = true;
  bool get startSettingPage => _startSettingPage;
  Locale _currentLocale = Locale('ja', ''); // 初期値を日本語に設定
  Locale get currentLocale => _currentLocale;

  // SharedPreferencesへの設定値の保存と通知を行う非同期メソッド
  Future<void> setStartPageA(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("startSettingPage", value);
    _startSettingPage = value;
    notifyListeners(); // 設定が変更されたことをリスナーに通知
  }

  // SharedPreferencesから設定値を読み込む非同期メソッド
  Future<void> getSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final startSettingPageValue = prefs.getBool("startSettingPage") ?? false;
    _startSettingPage = startSettingPageValue;
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

  Future<void> updateLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners(); // 設定が変更されたことをリスナーに通知
  }

  void setCurrentLocale(Locale locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    setCurrentLocale(locale);
  }

  void restartApp() {
    notifyListeners();
  }
}
