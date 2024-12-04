import 'package:flutter/material.dart';

const int defaultTimerSeconds = 60; // タイマーの初期値・最大値(秒)
const double buttonBorderRadius = 8.0;
const double iconSize = 36;
const double counterNumbersSize = 52;
const double timerNumbersSize = 36;
const double resultNumbersSize = 44;
const double noResultFontSize = 32;
const Color backgroundColor = Color(0xFFE8E2D7); // アプリの背景色
const Color buttonColor = Color(0xFF5C5862);
const Color buttonBackgroundColor = Colors.white; // ボタンの背景色
const Color containerBackgroundColor = Colors.white; // コンテナの背景色
const Color iconColor = Colors.white; // アイコンの色
const Color overlayBackgroundColor = Color(0x99000000); // オーバーレイの背景色
const Color textColor = Colors.black; // テキストの色
const String alarmAudioPath = 'alarm.mp3'; // オーディオファイルのパス

// 日本語のフォントサイズ
const double jaTitleFontSize = 22.0;
const double jaBodyFontSize = 20.0;
const double jaDialogFontSize = 18.0;
const double jaCalculationFontSize = 20.0;
const double jaSupplementFontSize = 16.0;
const double jaCloseFontSize = 20.0;

// 英語のフォントサイズ
const double enTitleFontSize = 20.0;
const double enBodyFontSize = 16.0;
const double enDialogFontSize = 16.0;
const double enCalculationFontSize = 18.0;
const double enSupplementFontSize = 16.0;
const double enCloseFontSize = 18.0;

// フォントサイズを取得する関数
double getTitleFontSize(String languageCode) =>
    languageCode == 'ja' ? jaTitleFontSize : enTitleFontSize;
double getBodyFontSize(String languageCode) =>
    languageCode == 'ja' ? jaBodyFontSize : enBodyFontSize;
double getDialogFontSize(String languageCode) =>
    languageCode == 'ja' ? jaDialogFontSize : enDialogFontSize;
double getCalculationFontSize(String languageCode) =>
    languageCode == 'ja' ? jaCalculationFontSize : enCalculationFontSize;
double getSupplementFontSize(String languageCode) =>
    languageCode == 'ja' ? jaSupplementFontSize : enSupplementFontSize;
double getCloseFontSize(String languageCode) =>
    languageCode == 'ja' ? jaCloseFontSize : enCloseFontSize;
