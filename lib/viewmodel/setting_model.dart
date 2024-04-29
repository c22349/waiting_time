import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'dart:io';

class SettingModel with ChangeNotifier {
  // 初期値
  bool _startSettingPage = true;
  bool get startSettingPage => _startSettingPage;
  Locale _currentLocale = Locale('ja', '');
  Locale get currentLocale => _currentLocale;
  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

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
    await prefs.setString("language", languageCode);
    notifyListeners();
  }

  Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("language") ?? "ja";
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

  Locale getDeviceLocale() {
    return Locale(Platform.localeName.split('_')[0]);
  }

  // アプリ起動時に呼び出すメソッド
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('language');
    Locale deviceLocale = getDeviceLocale();
    String defaultLanguageCode =
        deviceLocale.languageCode == 'ja' ? 'ja' : 'en';
    _currentLocale = Locale(savedLanguageCode ?? defaultLanguageCode, '');
    notifyListeners();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
  }

  void updateSoundSetting(bool isEnabled) {
    _soundEnabled = isEnabled;
    notifyListeners();
  }

  void setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    _soundEnabled = value;
    notifyListeners();
  }
}
