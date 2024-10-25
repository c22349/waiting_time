import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<String?> showCounterDialog(
  BuildContext context,
  TextEditingController controller,
  String title,
  double dialogFontSize,
) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      controller.text = controller.text; // 現在のカウントを反映
      return AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: dialogFontSize),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34),
              onChanged: (value) {
                if (value.isNotEmpty && value != '0') {
                  controller.text = value.replaceFirst(RegExp(r'^0+'), '');
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                } else if (value.isEmpty) {
                  controller.text = '0';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: 1),
                  );
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.dialog_cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.dialog_decision),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ],
      );
    },
  );
}
