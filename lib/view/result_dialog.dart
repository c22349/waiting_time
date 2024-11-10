import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../const.dart';

void showResultDialog(
    BuildContext context, int counterFront, int counterBehind) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      if (counterBehind == 0) {
        return _buildNoResultDialog(context);
      }

      double result = counterFront / counterBehind;
      int minutes = result.floor();
      int seconds = ((result - minutes) * 60).round();

      // 30秒単位に切り上げる処理
      if (seconds > 0 && seconds < 30) {
        seconds = 30;
      } else if (seconds > 30) {
        seconds = 0;
        minutes += 1;
      }

      return _buildResultDialog(context, minutes, seconds);
    },
  );
}

AlertDialog _buildNoResultDialog(BuildContext context) {
  return AlertDialog(
    title: Text(
      AppLocalizations.of(context)!.estimated_waiting_time,
      textAlign: TextAlign.center,
    ),
    content: Text(
      AppLocalizations.of(context)!.incomputable,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: noResultFontSize),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(
          AppLocalizations.of(context)!.close,
          style: TextStyle(
              fontSize: getCloseFontSize(
                  Localizations.localeOf(context).languageCode)),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

AlertDialog _buildResultDialog(BuildContext context, int minutes, int seconds) {
  return AlertDialog(
    title: Text(
      AppLocalizations.of(context)!.estimated_waiting_time,
      textAlign: TextAlign.center,
    ),
    content: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$minutes',
            style: TextStyle(
              fontSize: resultNumbersSize,
              color: textColor,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(context)!.minute,
            style: TextStyle(
              fontSize: getCalculationFontSize(
                  Localizations.localeOf(context).languageCode),
              color: textColor,
            ),
          ),
          if (seconds > 0) ...[
            TextSpan(
              text: '$seconds',
              style: TextStyle(
                fontSize: resultNumbersSize,
                color: textColor,
              ),
            ),
            TextSpan(
              text: AppLocalizations.of(context)!.seconds,
              style: TextStyle(
                fontSize: getCalculationFontSize(
                    Localizations.localeOf(context).languageCode),
                color: textColor,
              ),
            ),
          ],
          TextSpan(
            text:
                '\n\n\n${AppLocalizations.of(context)!.calculation_supplement}',
            style: TextStyle(
              fontSize: getSupplementFontSize(
                  Localizations.localeOf(context).languageCode),
              color: textColor,
            ),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(
          AppLocalizations.of(context)!.close,
          style: TextStyle(
              fontSize: getCloseFontSize(
                  Localizations.localeOf(context).languageCode)),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
