import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../const.dart';
import 'counter_dialog.dart';

class CounterFront extends StatelessWidget {
  final int counterFront;
  final double bodyFontSize;
  final double counterNumbersSize;
  final double iconSize;
  final double dialogFontSize;
  final Color containerBackgroundColor;
  final Color buttonColor;
  final TextEditingController counterFrontController;
  final Function(String) updateCounterFront;
  final VoidCallback resetCounterFront;
  final VoidCallback decrementCounterFront;
  final VoidCallback incrementCounterFront;

  const CounterFront({
    Key? key,
    required this.counterFront,
    required this.bodyFontSize,
    required this.counterNumbersSize,
    required this.iconSize,
    required this.dialogFontSize,
    required this.containerBackgroundColor,
    required this.buttonColor,
    required this.counterFrontController,
    required this.updateCounterFront,
    required this.resetCounterFront,
    required this.decrementCounterFront,
    required this.incrementCounterFront,
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
                  text: '${AppLocalizations.of(context)!.line_in_front_of}',
                  style: TextStyle(
                      fontSize: bodyFontSize, fontWeight: FontWeight.normal),
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
                onPressed: resetCounterFront,
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
                            counterFrontController,
                            AppLocalizations.of(context)!
                                .line_in_front_of_dialog,
                            dialogFontSize,
                          );
                          if (newValue != null) {
                            updateCounterFront(newValue);
                          }
                        },
                        child: Text(
                          '$counterFront',
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
                    color: buttonBackgroundColor,
                    border: Border.all(color: buttonColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.remove, size: iconSize),
                ),
                onPressed: decrementCounterFront,
              ),
              SizedBox(width: iconSize * 2, height: iconSize),
              IconButton(
                icon: Container(
                  width: iconSize * 2,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    border: Border.all(color: buttonColor),
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                  child: Icon(Icons.add, size: iconSize, color: iconColor),
                ),
                onPressed: incrementCounterFront,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
