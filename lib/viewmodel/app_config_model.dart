import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../const.dart';

class AppConfig {
  static MaterialApp initializeApp({
    required Locale currentLocale,
    required Widget home,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ja', ''),
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null && supportedLocales.contains(deviceLocale)) {
          return deviceLocale;
        }
        return const Locale('en', '');
      },
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: backgroundColor,
        ),
      ),
      home: home,
    );
  }
}
