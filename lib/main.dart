import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:auto_size_text/auto_size_text.dart'; // 使用していない可能性あり
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
// 使用していない可能性あり(Android側未検証)
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

// 読み込みファイル
import 'const.dart';
import 'firebase_options.dart';
import 'function/version_check_service.dart';
import 'view/admob_helper.dart';
import 'view/calculate_button.dart';
import 'view/counter_behind.dart';
import 'view/counter_front.dart';
import 'view/settings.dart';
import 'view/timer_widget.dart';
import 'view/update_prompt_dialog.dart';
import 'viewmodel/setting_model.dart';
import 'viewmodel/counter_model.dart';

// 使用していない可能性あり(Android側未検証)
// Future<Locale> loadLocale() async {
//   final prefs = await SharedPreferences.getInstance();
//   final languageCode = prefs.getString('language') ?? 'ja';
//   return Locale(languageCode, '');
// }

class MyApp extends StatelessWidget {
  MyApp({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: settings.currentLocale, // 現在のローカル
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('ja', ''),
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale != null &&
                supportedLocales.contains(deviceLocale)) {
              return deviceLocale;
            }
            return Locale('en', '');
          },
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: backgroundColor,
            appBarTheme: AppBarTheme(
              color: backgroundColor,
            ),
          ),
          home: FutureBuilder<bool>(
            future: VersionCheckService().versionCheck(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // ネット未接続の場合スキップ
                return CounterPage();
              } else if (snapshot.data == true) {
                // アップデートが必要な場合の画面を表示
                return UpdatePromptDialog();
              }
              // 通常のホーム画面を表示
              return CounterPage();
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
  int _timer = defaultTimerSeconds;
  Timer? _countdownTimer;
  late BannerAd myBanner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initBannerAd();
  }

  void _initBannerAd() {
    final AdSize adSize = _getAdSize();
    myBanner = BannerAd(
      adUnitId: getAdBannerUnitId(),
      size: adSize,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
    myBanner.load();
  }

  AdSize _getAdSize() {
    final width = MediaQuery.of(context).size.width.toInt();
    return AdSize(width: width, height: 60);
  }

  void _toggleTimer() {
    if (_timer == 0) {
      setState(() {
        _timer = defaultTimerSeconds; // タイマーが0秒の場合、60秒にリセット
      });
    }
    if (_countdownTimer == null) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_timer > 0) {
            _timer--;
          } else {
            _countdownTimer?.cancel();
            _countdownTimer = null;
            if (Provider.of<SettingModel>(context, listen: false)
                .soundEnabled) {
              // スイッチがONの場合のみアラームを鳴らす
              _playAlarm();
            }
            _startRepeatedVibration();
          }
        });
      });
    } else {
      _countdownTimer?.cancel();
      setState(() {
        _countdownTimer = null;
      });
    }
  }

  // Androidで利用している可能性あり
  // void _startTimer() {
  //   _countdownTimer?.cancel();
  //   setState(() {
  //     _timer = defaultTimerSeconds;
  //   });
  //   _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     setState(() {
  //       if (_timer > 0) {
  //         _timer--;
  //       } else {
  //         if (Provider.of<SettingModel>(context, listen: false).soundEnabled) {
  //           // スイッチがONの場合のみアラームを鳴らす
  //           _startRepeatedVibration();
  //           _countdownTimer?.cancel();
  //           final player = AudioPlayer();
  //           player.setSource(AssetSource(alarmAudioPath));
  //           player.play(AssetSource(alarmAudioPath));
  //           // Android alarm time
  //           Future.delayed(const Duration(seconds: 2), () {
  //             player.stop();
  //           });
  //         }
  //       }
  //     });
  //   });
  // }

  void _playAlarm() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    final player = AudioPlayer();
    await player.setSource(AssetSource(alarmAudioPath));
    await player.play(AssetSource(alarmAudioPath));
    // iOS alarm time
    Future.delayed(const Duration(seconds: 2), () {
      player.stop();
    });
  }

  void _startRepeatedVibration() {
    Vibration.vibrate(duration: 250);
    Timer.periodic(const Duration(seconds: 1), (Timer vibrationOrder) {
      if (vibrationOrder.tick < 2) {
        Vibration.vibrate(duration: 250);
      } else {
        vibrationOrder.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterModel>(
      builder: (context, counterModel, child) {
        // 現在のロケールを取得
        Locale locale = Localizations.localeOf(context);
        double titleFontSize = getTitleFontSize(locale.languageCode);
        double bodyFontSize = getBodyFontSize(locale.languageCode);
        double dialogFontSize = getDialogFontSize(locale.languageCode);

        return Scaffold(
          appBar: AppBar(
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            //タイマー部分
                            TimerWidget(
                              timer: _timer,
                              countdownTimer: _countdownTimer,
                              bodyFontSize: bodyFontSize,
                              timerNumbersSize: timerNumbersSize,
                              iconSize: iconSize,
                              containerBackgroundColor:
                                  containerBackgroundColor,
                              toggleTimer: _toggleTimer,
                              resetTimer: () {
                                _countdownTimer?.cancel();
                                setState(() {
                                  _timer = defaultTimerSeconds;
                                  _countdownTimer = null;
                                });
                              },
                            ),
                            SizedBox(width: 0),
                            // 計算ボタンの部分
                            CalculateButton(
                              bodyFontSize: bodyFontSize,
                              iconSize: iconSize,
                              containerBackgroundColor:
                                  containerBackgroundColor,
                              counterFront: counterModel.counterFront,
                              counterBehind: counterModel.counterBehind,
                            ),
                          ],
                        ),
                      ),
                      // バナー部分
                      SizedBox(height: 24),
                      Container(
                        width: AdSize.fullBanner.width.toDouble(),
                        height: AdSize.fullBanner.height.toDouble(),
                        alignment: Alignment.center,
                        child: AdWidget(ad: myBanner),
                      ),
                      const SafeArea(child: SizedBox.shrink()),
                    ],
                  ),
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
