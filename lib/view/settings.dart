import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _selectedLanguage = '日本語';

  var Provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)?.translate('settings') ?? '設定'),
      ),
      body: Center(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          onChanged: (String? newValue) {
            // UIを更新するために状態を設定
            setState(() {
              _selectedLanguage = newValue!;
            });
            // 言語設定を非同期で更新
            Provider.of<SettingModel>(context, listen: false)
                .setSelectedLanguage(newValue)
                .then((_) {
              // 必要に応じて非同期処理の完了後に何かをする
            }).catchError((error) {
              // エラー処理
              print("言語設定の更新中にエラーが発生しました: $error");
            });
          },
          items: <DropdownMenuItem<String>>[], // 空のリストを設定
        ),
      ),
    );
  }
}

mixin SettingModel {}
