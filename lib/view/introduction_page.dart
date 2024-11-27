import 'package:flutter/material.dart';
import '../const.dart';
import '../main.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CounterPage(), // 背景としてメイン画面を表示
        Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'アプリの使い方',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'このアプリでは、列に並んでいる人数を簡単にカウントできます。\n'
                    '前列と後列の人数を別々に管理することができます。',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const CounterPage(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: const Text('始める'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
