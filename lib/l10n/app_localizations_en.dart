// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get main_title => 'Waiting time forecast';

  @override
  String get line_in_front_of => 'Number of people\nin line in front of you';

  @override
  String get line_behind => 'Number of people\nlined up behind you in 1 minute';

  @override
  String get line_in_front_of_dialog => 'Number of people in front of you';

  @override
  String get line_behind_dialog => 'Number of people behind you';

  @override
  String get dialog_decision => 'OK';

  @override
  String get dialog_cancel => 'Cancel';

  @override
  String get minute_timer => '1 minute timer';

  @override
  String get heading_seconds => 'S';

  @override
  String get calculate => 'calculate';

  @override
  String get estimated_waiting_time => 'Estimated waiting time';

  @override
  String get minute => 'minute';

  @override
  String get seconds => 'seconds';

  @override
  String get incomputable => 'Incomputable';

  @override
  String get calculation_supplement =>
      'Simplified calculations using\nLittle\'s Law';

  @override
  String get close => 'close';

  @override
  String get settings => 'Settings';

  @override
  String get language_settings => 'Language';

  @override
  String get sound_settings => 'Alarm sound';

  @override
  String get update_message =>
      'A new version is available.\n\nPlease update to the latest version.';

  @override
  String get update => 'Update now';

  @override
  String get later => 'Later';

  @override
  String get app_introduction_title => 'How to use this app';

  @override
  String get app_introduction_description =>
      'Use Little\'s Law to predict the wait time.\nCount the number of people in the front row to begin with, and count the number of people in the back row after one minute.';

  @override
  String get start_button => 'Start';
}
