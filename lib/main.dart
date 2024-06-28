import 'package:flutter/material.dart';
import 'dart:async';
import 'view/settings.dart';
import 'viewmodel/setting_model.dart';
import 'view/update_prompt_dialog.dart';
import 'function/version_check_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

const double iconSize = 36;
const double counterNumbersSize = 52;
const double timerNumbersSize = 36;
const double resultNumbersSize = 44;
const double noResultFontSize = 32;
const buttonColor = Color(0xFF5C5862);

Future<Locale> _fetchLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language') ?? 'ja';
  return Locale(languageCode, '');
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
          locale: settings.currentLocale, // 現在のロケールを使用
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
            scaffoldBackgroundColor: Color(0xFFE8E2D7), // 背景色
            appBarTheme: AppBarTheme(
              color: Color(0xFFE8E2D7), // タイトルバー背景色
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ホーム'),
      ),
      body: Center(
        child: Text('ホーム画面'),
      ),
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
  int _timer = 60;
  Timer? _countdownTimer;

  final TextEditingController _counterFrontController = TextEditingController();
  final TextEditingController _counterBehindController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    _counterFrontController.text = '$_counterFront';
    _counterBehindController.text = '$_counterBehind';
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
        _timer = 60; // タイマーが0秒の場合、60秒にリセット
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

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _timer = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          if (Provider.of<SettingModel>(context, listen: false).soundEnabled) {
            // スイッチがONの場合のみアラームを鳴らす
            _startRepeatedVibration();
            _countdownTimer?.cancel();
            final player = AudioPlayer();
            player.setSource(AssetSource('alarm.mp3'));
            player.play(AssetSource('alarm.mp3'));
            // Android alarm time
            Future.delayed(const Duration(seconds: 2), () {
              player.stop();
            });
          }
        }
      });
    });
  }

  void _playAlarm() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    final player = AudioPlayer();
    await player.setSource(AssetSource('alarm.mp3'));
    await player.play(AssetSource('alarm.mp3'));
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
    double titleFontSize = locale.languageCode == 'ja' ? 22.0 : 20.0;
    double bodyFontSize = locale.languageCode == 'ja' ? 20.0 : 16.0;
    double dialogFontSize = locale.languageCode == 'ja' ? 18.0 : 16.0;
    double calculationFontSize = locale.languageCode == 'ja' ? 20.0 : 18.0;
    double SupplementFontSize = locale.languageCode == 'ja' ? 16.0 : 16.0;
    double closeFontSize = locale.languageCode == 'ja' ? 20.0 : 18.0;

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
                      color: Colors.white, // コンテナの背景色
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
                                            await showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            _counterFrontController.text =
                                                '$_counterFront'; // 現在のカウントを反映
                                            return AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(context)!
                                                    .line_in_front_of_dialog,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: dialogFontSize),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _counterFrontController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 34),
                                                    onChanged: (value) {
                                                      if (value.isNotEmpty &&
                                                          value != '0') {
                                                        _counterFrontController
                                                                .text =
                                                            value.replaceFirst(
                                                                RegExp(r'^0+'),
                                                                '');
                                                        _counterFrontController
                                                                .selection =
                                                            TextSelection
                                                                .fromPosition(
                                                          TextPosition(
                                                              offset:
                                                                  _counterFrontController
                                                                      .text
                                                                      .length),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .dialog_cancel),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .dialog_decision),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        _counterFrontController
                                                            .text);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
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
                                  color: Colors.white, // 背景色
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
                                      BorderRadius.circular(8), // 角の設定
                                ),
                                child: const Icon(Icons.add,
                                    size: iconSize, color: Colors.white),
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
                      color: Colors.white, // コンテナの背景色
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
                                            await showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            _counterBehindController.text =
                                                '$_counterBehind'; // 現在のカウントを反映
                                            return AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(context)!
                                                    .line_behind_dialog,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: dialogFontSize),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _counterBehindController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 34),
                                                    onChanged: (value) {
                                                      if (value.isNotEmpty &&
                                                          value != '0') {
                                                        _counterBehindController
                                                                .text =
                                                            value.replaceFirst(
                                                                RegExp(r'^0+'),
                                                                '');
                                                        _counterBehindController
                                                                .selection =
                                                            TextSelection
                                                                .fromPosition(
                                                          TextPosition(
                                                              offset:
                                                                  _counterBehindController
                                                                      .text
                                                                      .length),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .dialog_cancel),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .dialog_decision),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        _counterBehindController
                                                            .text);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
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
                                  color: Colors.white, // 背景色
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.56,
                          padding:
                              EdgeInsets.fromLTRB(0, 10.0, 0, 16.0), // 内側の余白
                          decoration: BoxDecoration(
                            color: Colors.white, // コンテナの背景色
                            borderRadius: BorderRadius.circular(10), // 角丸の設定
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text:
                                          '${AppLocalizations.of(context)!.minute_timer} \n',
                                      style: TextStyle(
                                          fontSize: bodyFontSize,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    WidgetSpan(
                                      child: SizedBox(height: 60),
                                    ),
                                    WidgetSpan(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AutoSizeText(
                                            '$_timer', // タイマーの値
                                            style: TextStyle(
                                              fontSize: timerNumbersSize,
                                              fontFeatures: [
                                                FontFeature.tabularFigures()
                                              ],
                                            ),
                                            maxLines: 1,
                                            minFontSize: 10,
                                            maxFontSize: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: Transform.translate(
                                        offset: Offset(0, -6),
                                        child: Container(
                                          width: 30,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                ' ${AppLocalizations.of(context)!.heading_seconds}',
                                                style: TextStyle(
                                                    fontSize: bodyFontSize),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                    offset: Offset(-1, 0),
                                    child: IconButton(
                                      icon: Icon(
                                          _countdownTimer == null
                                              ? Icons.play_arrow
                                              : Icons.pause,
                                          size: iconSize * 1.2),
                                      onPressed: _toggleTimer,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Transform.translate(
                                    offset: Offset(-1, 0),
                                    child: IconButton(
                                      icon: const Icon(Icons.replay,
                                          size: iconSize * 1.2),
                                      onPressed: () {
                                        _countdownTimer?.cancel();
                                        setState(() {
                                          _timer = 60;
                                          _countdownTimer = null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 0),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.36,
                          padding:
                              EdgeInsets.fromLTRB(0, 10.0, 0, 30.0), // 内側の余白
                          decoration: BoxDecoration(
                            color: Colors.white, // コンテナの背景色
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
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      double result = 0;
                                      if (_counterBehind != 0) {
                                        result = _counterFront / _counterBehind;
                                      } else {
                                        // line_behindが0の場合
                                        return AlertDialog(
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .estimated_waiting_time,
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .incomputable,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: noResultFontSize),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .close,
                                                style:
                                                    TextStyle(fontSize: 20.0),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                      int minutes = result.floor();
                                      int seconds =
                                          ((result - minutes) * 60).round();
                                      // 30秒単位に切り上げる処理
                                      if (seconds > 0 && seconds < 30) {
                                        seconds = 30;
                                      } else if (seconds > 30) {
                                        seconds = 0;
                                        minutes += 1;
                                      }
                                      return AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(context)!
                                              .estimated_waiting_time,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${minutes}',
                                                style: TextStyle(
                                                    fontSize: resultNumbersSize,
                                                    color: Colors.black),
                                              ),
                                              TextSpan(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .minute,
                                                style: TextStyle(
                                                    fontSize:
                                                        calculationFontSize,
                                                    color: Colors.black),
                                              ),
                                              if (seconds > 0) ...[
                                                TextSpan(
                                                  text: '${seconds}',
                                                  style: TextStyle(
                                                      fontSize:
                                                          resultNumbersSize,
                                                      color: Colors.black),
                                                ),
                                                TextSpan(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .seconds,
                                                  style: TextStyle(
                                                      fontSize:
                                                          calculationFontSize,
                                                      color: Colors.black),
                                                ),
                                              ],
                                              TextSpan(
                                                text:
                                                    '\n\n\n${AppLocalizations.of(context)!.calculation_supplement}',
                                                style: TextStyle(
                                                    fontSize:
                                                        SupplementFontSize,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .close,
                                              style: TextStyle(
                                                  fontSize: closeFontSize),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
