import 'package:flutter/material.dart';
import 'dart:async';
import 'view/settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'viewmodel/setting_model.dart';

Future<Locale> _fetchLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language') ?? 'ja';
  return Locale(languageCode, '');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.main_title),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                '${AppLocalizations.of(context)!.line_in_front_of}: ${_counterFront}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementCounterFront,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementCounterFront,
                ),
                IconButton(
                  icon: const Icon(Icons.replay), // リセットマーク
                  onPressed: _resetCounterFront,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
                '${AppLocalizations.of(context)!.line_behind}: ${_counterBehind}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementCounterBehind,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementCounterBehind,
                ),
                IconButton(
                  icon: const Icon(Icons.replay), // リセットマーク
                  onPressed: _resetCounterBehind,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        '${AppLocalizations.of(context)!.minute_timer} $_timer ${AppLocalizations.of(context)!.seconds}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(_countdownTimer == null
                              ? Icons.play_arrow
                              : Icons.stop),
                          onPressed: () {
                            if (_countdownTimer == null) {
                              _startTimer();
                            } else {
                              _countdownTimer?.cancel();
                              setState(() {
                                _countdownTimer = null;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.replay),
                          onPressed: () {
                            _countdownTimer?.cancel();
                            setState(() {
                              _timer = 60;
                              _countdownTimer = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.calculate),
                    IconButton(
                      icon: const Icon(Icons.calculate),
                      onPressed: () {
                        // 計算結果を出力
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // 計算方式
                            double result = 0;
                            if (_counterBehind != 0) {
                              result = _counterFront / _counterBehind;
                            }
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!
                                  .estimated_waiting_time),
                              content: Text(
                                  '$result ${AppLocalizations.of(context)!.minute}'),
                              actions: <Widget>[
                                TextButton(
                                  child:
                                      Text(AppLocalizations.of(context)!.close),
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
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
