import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:waiting_time/viewmodel/setting_model.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _selectedLanguage = 'ja';
  bool _isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadSoundSetting();
  }

  _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'ja';
    });
  }

  _saveLanguage(String language) async {
    Provider.of<SettingModel>(context, listen: false).updateLanguage(language);
  }

  _loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = prefs.getBool('soundEnabled') ?? true;
    });
  }

  _saveSoundSetting(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', isEnabled);
    Provider.of<SettingModel>(context, listen: false)
        .updateSoundSetting(isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    // 現在のロケールを取得
    Locale locale = Localizations.localeOf(context);
    // ロケールに基づいてフォントサイズを設定
    double settingsTitleFontSize = locale.languageCode == 'ja' ? 22.0 : 20.0;
    double settingsFontSize = locale.languageCode == 'ja' ? 18.0 : 16.0;
    double settingsLanguageFontSize = locale.languageCode == 'ja' ? 16.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // 戻るボタンの統一
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(fontSize: settingsTitleFontSize),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFEEEDF3), // タイトルバーの背景色
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 60), // 上のスペース
          child: Container(
            color: Colors.white, // Container背景色 // 左端スペース
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // 左端に配置
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Icon(Icons.language), // 言語設定のアイコン
                    ),
                    SizedBox(width: 8), // アイコンとテキストの間
                    Text(
                      AppLocalizations.of(context)!.language_settings,
                      style: TextStyle(fontSize: settingsFontSize),
                    ),
                    Spacer(), // 左側の要素と右側のドロップダウンを分ける
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      onChanged: (String? newValue) async {
                        setState(() {
                          _selectedLanguage = newValue!;
                        });
                        await _saveLanguage(newValue!);
                        Provider.of<SettingModel>(context, listen: false)
                            .setLocale(newValue == 'ja'
                                ? Locale('ja', '')
                                : Locale('en', ''));
                      },
                      items: <String>['日本語', 'English']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value == '日本語' ? 'ja' : 'en',
                          child: Text(
                            value,
                            style:
                                TextStyle(fontSize: settingsLanguageFontSize),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 40), // ドロップダウン右側スペース
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.025),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEEEDF3),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Icon(Icons.volume_up), // スピーカーのアイコン
                    ),
                    SizedBox(width: 8), // アイコンとテキストの間
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.sound_settings,
                        style: TextStyle(fontSize: settingsFontSize),
                      ),
                    ),
                    Switch(
                      value: _isSoundEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isSoundEnabled = value;
                        });
                        _saveSoundSetting(value);
                      },
                      activeColor: Colors.white, // ONスイッチ色
                      activeTrackColor: Colors.green, // ONのトラックの色
                      inactiveThumbColor: Colors.white, // OFFスイッチ色
                      inactiveTrackColor: Colors.grey.shade400, // OFFのトラック色
                    ),
                    SizedBox(width: 60), // スイッチの右側スペース
                  ],
                ),
                Expanded(
                  child: Container(
                    color: Color(0xFFEEEDF3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFEEEDF3), // 設定画面の背景色
    );
  }
}
