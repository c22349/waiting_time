import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// 読み込みファイル
import 'const.dart';
import 'firebase_options.dart';
import 'function/version_check_service.dart';
import 'view/admob_helper.dart';
import 'view/calculate_button.dart';
import 'view/counter_behind.dart';
import 'view/counter_front.dart';
import 'view/introduction_page.dart';
import 'view/settings.dart';
import 'view/timer_widget.dart';
import 'view/update_prompt_dialog.dart';
import 'viewmodel/counter_model.dart';
import 'viewmodel/setting_model.dart';
import 'viewmodel/timer_model.dart';

// 使用していない可能性あり(Android側未検証)
// import 'dart:async';
// import 'package:audio_session/audio_session.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vibration/vibration.dart';

Future<Locale> loadLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language') ?? 'ja';
  return Locale(languageCode, '');
}

// アプリ起動時
class MyApp extends StatelessWidget {
  MyApp({required this.locale});
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          locale: settings.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ja', ''),
            Locale('en', ''),
          ],
          home: FutureBuilder<bool>(
            future: VersionCheckService().versionCheck(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // ネット未接続の場合スキップ
                return const CounterPage();
              } else if (snapshot.data == true) {
                // アップデートが必要な場合の画面を表示
                return const UpdatePromptDialog();
              } else {
                // 説明画面をオーバーレイとして表示
                return const IntroductionPage();
              }
            },
          ),
        );
      },
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<CounterModel, TimerModel, SettingModel>(
      builder: (context, counterModel, timerModel, settingModel, child) {
        Locale locale = Localizations.localeOf(context);
        double titleFontSize = getTitleFontSize(locale.languageCode);
        double bodyFontSize = getBodyFontSize(locale.languageCode);
        double dialogFontSize = getDialogFontSize(locale.languageCode);

        return Scaffold(
          backgroundColor: backgroundColor, // コンテンツの背景色
          appBar: AppBar(
            backgroundColor: backgroundColor, // タイトルバーの背景色
            title: Text(
              AppLocalizations.of(context)!.main_title,
              style: TextStyle(fontSize: titleFontSize),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingPage()),
                  );
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10), // 上部のスペースを調整
                    // 前に並んでいる人数(1段目)
                    CounterFront(
                      counterFront: counterModel.counterFront,
                      bodyFontSize: bodyFontSize,
                      counterNumbersSize: counterNumbersSize,
                      iconSize: iconSize,
                      dialogFontSize: dialogFontSize,
                      containerBackgroundColor: containerBackgroundColor,
                      buttonColor: buttonColor,
                      counterFrontController:
                          counterModel.counterFrontController,
                      updateCounterFront: counterModel.updateCounterFront,
                      resetCounterFront: counterModel.resetFront,
                      decrementCounterFront: counterModel.decrementFront,
                      incrementCounterFront: counterModel.incrementFront,
                    ),
                    SizedBox(height: 12),
                    // 後ろに並んだ人数(2段目)
                    CounterBehind(
                      counterBehind: counterModel.counterBehind,
                      bodyFontSize: bodyFontSize,
                      counterNumbersSize: counterNumbersSize,
                      iconSize: iconSize,
                      dialogFontSize: dialogFontSize,
                      containerBackgroundColor: containerBackgroundColor,
                      buttonColor: buttonColor,
                      counterBehindController:
                          counterModel.counterBehindController,
                      updateCounterBehind: counterModel.updateCounterBehind,
                      resetCounterBehind: counterModel.resetBehind,
                      decrementCounterBehind: counterModel.decrementBehind,
                      incrementCounterBehind: counterModel.incrementBehind,
                    ),
                    SizedBox(height: 12),
                    // タイマー&計算ボタン(3段目)
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimerWidget(
                            timer: timerModel.timer,
                            countdownTimer: timerModel.countdownTimer,
                            bodyFontSize: bodyFontSize,
                            timerNumbersSize: timerNumbersSize,
                            iconSize: iconSize,
                            containerBackgroundColor: containerBackgroundColor,
                            toggleTimer: () => timerModel.toggleTimer(
                              context,
                              settingModel.soundEnabled,
                            ),
                            resetTimer: timerModel.resetTimer,
                          ),
                          SizedBox(width: 0),
                          // 計算ボタンの部分
                          CalculateButton(
                            bodyFontSize: bodyFontSize,
                            iconSize: iconSize,
                            containerBackgroundColor: containerBackgroundColor,
                            counterFront: counterModel.counterFront,
                            counterBehind: counterModel.counterBehind,
                          ),
                        ],
                      ),
                    ),
                    // バナー部分
                    SizedBox(height: 24),
                    const AdBannerWidget(),
                    const SafeArea(child: SizedBox.shrink()),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    final settingModel = SettingModel();
    await settingModel.loadLocale(); // 言語設定を読み込む
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingModel>(create: (_) => settingModel),
          ChangeNotifierProvider<CounterModel>(create: (_) => CounterModel()),
          ChangeNotifierProvider<TimerModel>(create: (_) => TimerModel()),
        ],
        child: Consumer<SettingModel>(
          builder: (context, model, child) {
            return MyApp(locale: model.currentLocale);
          },
        ),
      ),
    );
  });
}
