import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../const.dart';
import 'counter_dialog.dart';

class CounterBehind extends StatelessWidget {
  final int counterBehind;
  final double bodyFontSize;
  final double counterNumbersSize;
  final double iconSize;
  final double dialogFontSize;
  final Color containerBackgroundColor;
  final Color buttonColor;
  final TextEditingController counterBehindController;
  final Function(String) updateCounterBehind;
  final VoidCallback resetCounterBehind;
  final VoidCallback decrementCounterBehind;
  final VoidCallback incrementCounterBehind;

  const CounterBehind({
    Key? key,
    required this.counterBehind,
    required this.bodyFontSize,
    required this.counterNumbersSize,
    required this.iconSize,
    required this.dialogFontSize,
    required this.containerBackgroundColor,
    required this.buttonColor,
    required this.counterBehindController,
    required this.updateCounterBehind,
    required this.resetCounterBehind,
    required this.decrementCounterBehind,
    required this.incrementCounterBehind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.96,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: containerBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <InlineSpan>[
                TextSpan(
                  text: '${AppLocalizations.of(context)!.line_behind}',
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Container(
                  width: iconSize * 2,
                  height: iconSize,
                  child: Icon(Icons.replay, size: iconSize),
                ),
                onPressed: resetCounterBehind,
              ),
              Container(
                width: iconSize * 2,
                height: iconSize * 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    OverflowBox(
                      minWidth: 0.0,
                      maxWidth: double.infinity,
                      minHeight: 0.0,
                      maxHeight: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          String? newValue = await showCounterDialog(
                            context,
                            counterBehindController,
                            AppLocalizations.of(context)!.line_behind_dialog,
                            dialogFontSize,
                          );
                          if (newValue != null) {
                            updateCounterBehind(newValue);
                          }
                        },
                        child: Text(
                          '$counterBehind',
                          style: TextStyle(
                            fontSize: counterNumbersSize,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: iconSize * 2, height: iconSize),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Container(
                  width: iconSize * 2,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: containerBackgroundColor,
                    border: Border.all(color: buttonColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.remove, size: iconSize),
                ),
                onPressed: decrementCounterBehind,
              ),
              SizedBox(width: iconSize * 2, height: iconSize),
              IconButton(
                icon: Container(
                  width: iconSize * 2,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    border: Border.all(color: buttonColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
                onPressed: incrementCounterBehind,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
