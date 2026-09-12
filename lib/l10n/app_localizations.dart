import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// title label
  ///
  /// In en, this message translates to:
  /// **'Waiting time forecast'**
  String get main_title;

  /// line in front label
  ///
  /// In en, this message translates to:
  /// **'Number of people\nin line in front of you'**
  String get line_in_front_of;

  /// lined up behind you label
  ///
  /// In en, this message translates to:
  /// **'Number of people\nlined up behind you in 1 minute'**
  String get line_behind;

  /// line in front dialog
  ///
  /// In en, this message translates to:
  /// **'Number of people in front of you'**
  String get line_in_front_of_dialog;

  /// lined up behind you dialog
  ///
  /// In en, this message translates to:
  /// **'Number of people behind you'**
  String get line_behind_dialog;

  /// dialog decision
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialog_decision;

  /// dialog cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;

  /// 1 minute timer label
  ///
  /// In en, this message translates to:
  /// **'1 minute timer'**
  String get minute_timer;

  /// heading seconds label
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get heading_seconds;

  /// calculate label
  ///
  /// In en, this message translates to:
  /// **'calculate'**
  String get calculate;

  /// Estimated waiting time label
  ///
  /// In en, this message translates to:
  /// **'Estimated waiting time'**
  String get estimated_waiting_time;

  /// minute label
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// seconds label
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Incomputable
  ///
  /// In en, this message translates to:
  /// **'Incomputable'**
  String get incomputable;

  /// Calculation Supplement
  ///
  /// In en, this message translates to:
  /// **'Simplified calculations using\nLittle\'s Law'**
  String get calculation_supplement;

  /// close label
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get close;

  /// settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_settings;

  /// Update dialog message
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get sound_settings;

  /// No description provided for @update_message.
  ///
  /// In en, this message translates to:
  /// **'A new version is available.\n\nPlease update to the latest version.'**
  String get update_message;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get update;

  /// Later button
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Introduction page title
  ///
  /// In en, this message translates to:
  /// **'How to use this app'**
  String get app_introduction_title;

  /// Introduction page description
  ///
  /// In en, this message translates to:
  /// **'Use Little\'s Law to predict the wait time.\nCount the number of people in the front row to begin with, and count the number of people in the back row after one minute.'**
  String get app_introduction_description;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start_button;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
