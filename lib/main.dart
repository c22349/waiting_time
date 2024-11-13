import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:auto_size_text/auto_size_text.dart'; // 使用していない可能性あり
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'view/counter_dialog.dart';
import 'view/result_dialog.dart';
import 'view/settings.dart';
import 'view/timer_widget.dart';
import 'view/update_prompt_dialog.dart';
import 'viewmodel/setting_model.dart';

// 使用していない可能性あり(Android側未検証)
// Future<Locale> loadLocale() async {
//   final prefs = await SharedPreferences.getInstance();
//   final languageCode = prefs.getString('language') ?? 'ja';
//   return Locale(languageCode, '');
// }

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
      ChangeNotifierProvider<SettingModel>(
        create: (context) => settingModel,
        child: Consumer<SettingModel>(
          builder: (context, model, child) {
            return MyApp(locale: model.currentLocale);
          },
        ),
      ),
    );
  });
}

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
  int _counterFront = 0;
  int _counterBehind = 0;
  int _timer = defaultTimerSeconds;
  Timer? _countdownTimer;
  late BannerAd myBanner;

  final TextEditingController _counterFrontController = TextEditingController();
  final TextEditingController _counterBehindController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _counterFrontController.text = '$_counterFront';
    _counterBehindController.text = '$_counterBehind';
  }

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

  void _updateCounterFront(String value) {
    setState(() {
      _counterFront = int.tryParse(value) ?? _counterFront;
      _counterFrontController.text = '$_counterFront';
    });
  }

  void _updateCounterBehind(String value) {
    setState(() {
      _counterBehind = int.tryParse(value) ?? _counterBehind;
      _counterBehindController.text = '$_counterBehind';
    });
  }

  void _incrementCounterFront() {
    setState(() {
      _counterFront++;
    });
  }

  void _decrementCounterFront() {
    setState(() {
      if (_counterFront > 0) _counterFront--;
    });
  }

  void _resetCounterFront() {
    setState(() {
      _counterFront = 0;
    });
  }

  void _incrementCounterBehind() {
    setState(() {
      _counterBehind++;
    });
  }

  void _decrementCounterBehind() {
    setState(() {
      if (_counterBehind > 0) _counterBehind--;
    });
  }

  void _resetCounterBehind() {
    setState(() {
      _counterBehind = 0;
    });
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
    // 現在のロケールを取得
    Locale locale = Localizations.localeOf(context);
    // ロケールに基づいてフォントサイズを設定
    double titleFontSize = getTitleFontSize(locale.languageCode);
    double bodyFontSize = getBodyFontSize(locale.languageCode);
    double dialogFontSize = getDialogFontSize(locale.languageCode);

    // 利用していない可能性あり、一時コメントアウト
    // double calculationFontSize = getCalculationFontSize(locale.languageCode);
    // double SupplementFontSize = getSupplementFontSize(locale.languageCode);
    // double closeFontSize = getCloseFontSize(locale.languageCode);

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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.96,
                    padding: EdgeInsets.all(10.0), // 内側の余白
                    decoration: BoxDecoration(
                      color: containerBackgroundColor, // コンテナの背景色
                      borderRadius: BorderRadius.circular(10), // 角の設定
                    ),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <InlineSpan>[
                              TextSpan(
                                text:
                                    '${AppLocalizations.of(context)!.line_in_front_of}',
                                style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                child: Icon(Icons.replay, size: iconSize),
                              ),
                              onPressed: _resetCounterFront,
                            ),
                            Container(
                              width: iconSize * 2,
                              height: iconSize * 2,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  OverflowBox(
                                    minWidth: 0.0,
                                    maxWidth: double.infinity,
                                    minHeight: 0.0,
                                    maxHeight: double.infinity,
                                    child: GestureDetector(
                                      onTap: () async {
                                        String? newValue =
                                            await showCounterDialog(
                                          context,
                                          _counterFrontController,
                                          AppLocalizations.of(context)!
                                              .line_in_front_of_dialog,
                                          dialogFontSize,
                                        );
                                        if (newValue != null) {
                                          _updateCounterFront(newValue);
                                        }
                                      },
                                      child: Text(
                                        '$_counterFront',
                                        style: TextStyle(
                                          fontSize: counterNumbersSize,
                                          fontFeatures: [
                                            FontFeature.tabularFigures()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width: iconSize * 2, height: iconSize),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: buttonBackgroundColor, // 背景色
                                  border: Border.all(color: buttonColor), // 縁
                                  borderRadius:
                                      BorderRadius.circular(8), // 角の設定
                                ),
                                child: const Icon(Icons.remove, size: iconSize),
                              ),
                              onPressed: _decrementCounterFront,
                            ),
                            const SizedBox(
                                width: iconSize * 2, height: iconSize),
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  border: Border.all(color: buttonColor), // 縁色
                                  borderRadius:
                                      BorderRadius.circular(buttonBorderRadius),
                                ),
                                child: const Icon(Icons.add,
                                    size: iconSize, color: iconColor),
                              ),
                              onPressed: _incrementCounterFront,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.96,
                    padding: EdgeInsets.all(10.0), // 内側の余白
                    decoration: BoxDecoration(
                      color: containerBackgroundColor, // コンテナの背景色
                      borderRadius: BorderRadius.circular(10), // 角の設定
                    ),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <InlineSpan>[
                              TextSpan(
                                text:
                                    '${AppLocalizations.of(context)!.line_behind}',
                                style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                child: Icon(Icons.replay, size: iconSize),
                              ),
                              onPressed: _resetCounterBehind,
                            ),
                            Container(
                              width: iconSize * 2,
                              height: iconSize * 2,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  OverflowBox(
                                    minWidth: 0.0,
                                    maxWidth: double.infinity,
                                    minHeight: 0.0,
                                    maxHeight: double.infinity,
                                    child: GestureDetector(
                                      onTap: () async {
                                        String? newValue =
                                            await showCounterDialog(
                                          context,
                                          _counterBehindController,
                                          AppLocalizations.of(context)!
                                              .line_behind_dialog,
                                          dialogFontSize,
                                        );
                                        if (newValue != null) {
                                          _updateCounterBehind(newValue);
                                        }
                                      },
                                      child: Text(
                                        '$_counterBehind',
                                        style: TextStyle(
                                          fontSize: counterNumbersSize,
                                          fontFeatures: [
                                            FontFeature.tabularFigures()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width: iconSize * 2, height: iconSize),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: containerBackgroundColor, // 背景色
                                  border: Border.all(color: buttonColor), // 縁
                                  borderRadius:
                                      BorderRadius.circular(8), // 角の設定
                                ),
                                child: const Icon(Icons.remove, size: iconSize),
                              ),
                              onPressed: _decrementCounterBehind,
                            ),
                            const SizedBox(
                                width: iconSize * 2, height: iconSize),
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  border: Border.all(color: buttonColor), // 縁色
                                  borderRadius:
                                      BorderRadius.circular(8), // 角の設定
                                ),
                                child: const Icon(Icons.add,
                                    size: iconSize, color: Colors.white),
                              ),
                              onPressed: _incrementCounterBehind,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TimerWidget(
                          timer: _timer,
                          countdownTimer: _countdownTimer,
                          bodyFontSize: bodyFontSize,
                          timerNumbersSize: timerNumbersSize,
                          iconSize: iconSize,
                          containerBackgroundColor: containerBackgroundColor,
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.36,
                          padding:
                              EdgeInsets.fromLTRB(0, 10.0, 0, 30.0), // 内側の余白
                          decoration: BoxDecoration(
                            color: containerBackgroundColor, // コンテナの背景色
                            borderRadius: BorderRadius.circular(10), // 角丸の設定
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.calculate}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 32),
                              IconButton(
                                icon: Icon(FontAwesomeIcons.calculator,
                                    size: iconSize * 1.6),
                                onPressed: () {
                                  // 計算結果を出力
                                  showResultDialog(
                                      context, _counterFront, _counterBehind);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // バナーのスペース
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
  }
}
