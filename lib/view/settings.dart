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
  String _selectedLanguage = '日本語';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage =
          prefs.getString('language') == 'ja' ? '日本語' : 'English';
    });
  }

  _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.language_settings),
            DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) async {
                setState(() {
                  _selectedLanguage = newValue!;
                });
                await _saveLanguage(newValue == '日本語' ? 'ja' : 'en');
                Provider.of<SettingModel>(context, listen: false).setLocale(
                    newValue == '日本語' ? Locale('ja', '') : Locale('en', ''));
              },
              items: <String>['日本語', 'English']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
