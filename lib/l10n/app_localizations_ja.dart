// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get main_title => '待ち時間予想';

  @override
  String get line_in_front_of => '前に並んでいる行列の人数';

  @override
  String get line_behind => '1分間で後ろに並んだ人数';

  @override
  String get line_in_front_of_dialog => '前の人数';

  @override
  String get line_behind_dialog => '後ろの人数';

  @override
  String get dialog_decision => 'OK';

  @override
  String get dialog_cancel => 'キャンセル';

  @override
  String get minute_timer => '1分間タイマー';

  @override
  String get heading_seconds => '秒';

  @override
  String get calculate => '計算';

  @override
  String get estimated_waiting_time => '予想待ち時間';

  @override
  String get minute => '分';

  @override
  String get seconds => '秒';

  @override
  String get incomputable => '計算不可';

  @override
  String get calculation_supplement => 'リトルの法則での簡易的な計算';

  @override
  String get close => '閉じる';

  @override
  String get settings => '設定';

  @override
  String get language_settings => '言語';

  @override
  String get sound_settings => 'アラーム音';

  @override
  String get update_message => '新しいバージョンが出ました。\n\n最新版のアップデートをお願いいたします。';

  @override
  String get update => '今すぐ更新';

  @override
  String get later => 'あとで';

  @override
  String get app_introduction_title => 'アプリの使い方';

  @override
  String get app_introduction_description =>
      'リトルの法則を使って待ち時間を予想します。\n始めに前列に並んでいる人数をカウントして、1分間後に後列に並んだ人数をカウントしてください。';

  @override
  String get start_button => '始める';
}
