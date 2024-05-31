import 'dart:io';
import '../main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

const APP_STORE_URL = 'https://apps.apple.com/jp/app/id[アプリのApple ID]?mt=8';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=[アプリのパッケージ名]';

// 指定のURLを起動 App Store or Play Storeのリンク
void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class UpdatePromptDialog extends StatelessWidget {
  const UpdatePromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // AndroidのBackボタンで閉じられないように
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.light, // テーマを設定
          barBackgroundColor: Colors.white, // ナビゲーションバーの背景色
          scaffoldBackgroundColor: Color(0xFFE8E2D7), // Scaffoldの背景色
        ),
        child: Container(
          color: Color(0xFFE8E2D7), // 外側の背景色
          child: Center(
            child: CupertinoAlertDialog(
              title: Text(
                AppLocalizations.of(context)!.update_message,
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CounterPage()));
                  },
                  child: Text(
                    AppLocalizations.of(context)!.later,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _launchURL(Platform.isIOS ? APP_STORE_URL : PLAY_STORE_URL);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.update,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
