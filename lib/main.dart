import 'package:flutter/material.dart';
import 'dart:async';
import 'view/settings.dart';
import 'viewmodel/setting_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

const double iconSize = 36;
const buttonColor = Color(0xFF5C5862);

Future<Locale> _fetchLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language') ?? 'ja';
  return Locale(languageCode, '');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          home: const CounterPage(),
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
  int _timer = 60;
  Timer? _countdownTimer;

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

  void _startTimer() {
    _countdownTimer?.cancel(); // 既存のタイマーをキャンセル
    setState(() {
      _timer = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          _countdownTimer?.cancel();
          // タイマーが0になった時の処理
        }
      });
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
                  SizedBox(height: 20), // 上部のスペースを調整
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
                                    '${AppLocalizations.of(context)!.line_in_front_of}\n',
                                style: TextStyle(fontSize: bodyFontSize),
                              ),
                              WidgetSpan(child: const SizedBox(height: 46)),
                              TextSpan(
                                text: '$_counterFront',
                                style: TextStyle(fontSize: 34.0),
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
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                child: Icon(Icons.replay, size: iconSize),
                              ),
                              onPressed: _resetCounterFront,
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
                                    '${AppLocalizations.of(context)!.line_behind}\n',
                                style: TextStyle(fontSize: bodyFontSize),
                              ),
                              WidgetSpan(child: const SizedBox(height: 46)),
                              TextSpan(
                                text: '$_counterBehind',
                                style: TextStyle(fontSize: 34.0),
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
                            IconButton(
                              icon: Container(
                                width: iconSize * 2,
                                height: iconSize,
                                child: Icon(Icons.replay, size: iconSize),
                              ),
                              onPressed: _resetCounterBehind,
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
                                      style: TextStyle(fontSize: bodyFontSize),
                                    ),
                                    WidgetSpan(
                                      child: SizedBox(height: 60),
                                    ),
                                    WidgetSpan(
                                      child: Container(
                                        width: 50,
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$_timer', // タイマーの値
                                              style: TextStyle(
                                                  fontSize:
                                                      36), // $_timerのフォントサイズ
                                            ),
                                          ],
                                        ),
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
                                style: TextStyle(fontSize: bodyFontSize),
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
                                            style: TextStyle(fontSize: 20.0),
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
                                                    fontSize: 30.0,
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
                                                      fontSize: 30.0,
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
