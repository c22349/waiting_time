import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

class TimerWidget extends StatelessWidget {
  final int timer;
  final Timer? countdownTimer;
  final double bodyFontSize;
  final double timerNumbersSize;
  final double iconSize;
  final Color containerBackgroundColor;
  final VoidCallback toggleTimer;
  final VoidCallback resetTimer;

  const TimerWidget({
    Key? key,
    required this.timer,
    required this.countdownTimer,
    required this.bodyFontSize,
    required this.timerNumbersSize,
    required this.iconSize,
    required this.containerBackgroundColor,
    required this.toggleTimer,
    required this.resetTimer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.56,
      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 16.0),
      decoration: BoxDecoration(
        color: containerBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '${AppLocalizations.of(context)!.minute_timer} \n',
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                WidgetSpan(child: SizedBox(height: 60)),
                WidgetSpan(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        '$timer',
                        style: TextStyle(
                          fontSize: timerNumbersSize,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                        maxFontSize: 30,
                      ),
                    ],
                  ),
                ),
                WidgetSpan(
                  child: Transform.translate(
                    offset: Offset(0, -6),
                    child: Container(
                      width: 30,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ' ${AppLocalizations.of(context)!.heading_seconds}',
                            style: TextStyle(fontSize: bodyFontSize),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(-1, 0),
                child: IconButton(
                  icon: Icon(
                    countdownTimer == null ? Icons.play_arrow : Icons.pause,
                    size: iconSize * 1.2,
                  ),
                  onPressed: toggleTimer,
                ),
              ),
              SizedBox(width: 3),
              Transform.translate(
                offset: Offset(-1, 0),
                child: IconButton(
                  icon: Icon(Icons.replay, size: iconSize * 1.2),
                  onPressed: resetTimer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
