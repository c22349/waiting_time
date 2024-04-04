import 'package:flutter/material.dart';
import 'dart:async';
import 'view/settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '待ち時間予想アプリ',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CounterPage(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('ja', ''), // Japanese
      ],
    );
  }
}

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counterA = 0;
  int _counterB = 0;
  int _timer = 60;
  Timer? _countdownTimer;

  void _incrementCounterA() {
    setState(() {
      _counterA++;
    });
  }

  void _decrementCounterA() {
    setState(() {
      if (_counterA > 0) _counterA--;
    });
  }

  void _resetCounterA() {
    setState(() {
      _counterA = 0;
    });
  }

  void _incrementCounterB() {
    setState(() {
      _counterB++;
    });
  }

  void _decrementCounterB() {
    setState(() {
      if (_counterB > 0) _counterB--;
    });
  }

  void _resetCounterB() {
    setState(() {
      _counterB = 0;
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
        title: const Text('待ち時間予想(リトルの法則)'),
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
            Text('前に並んでいる行列の人数 ${_counterA}人'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementCounterA,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementCounterA,
                ),
                IconButton(
                  icon: const Icon(Icons.replay), // リセットマーク
                  onPressed: _resetCounterA,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text('1分間で後ろに並んだ人数 ${_counterB}人'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementCounterB,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementCounterB,
                ),
                IconButton(
                  icon: const Icon(Icons.replay), // リセットマーク
                  onPressed: _resetCounterB,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1分間タイマー
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('1分間タイマー $_timer s'),
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
                    Text('計算'),
                    IconButton(
                      icon: const Icon(Icons.calculate),
                      onPressed: () {
                        // 計算結果を出力
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // 計算方式
                            double result = 0;
                            if (_counterB != 0) {
                              result = _counterA / _counterB;
                            }
                            return AlertDialog(
                              title: const Text('予想待ち時間'),
                              content: Text('$result分です'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('閉じる'),
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
