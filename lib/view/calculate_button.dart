import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../const.dart'; // 仮
import 'result_dialog.dart';

class CalculateButton extends StatelessWidget {
  final double bodyFontSize;
  final double iconSize;
  final Color containerBackgroundColor;
  final int counterFront;
  final int counterBehind;

  const CalculateButton({
    Key? key,
    required this.bodyFontSize,
    required this.iconSize,
    required this.containerBackgroundColor,
    required this.counterFront,
    required this.counterBehind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.36,
      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 30.0),
      decoration: BoxDecoration(
        color: containerBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${AppLocalizations.of(context)!.calculate}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodyFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 32),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.calculator,
              size: iconSize * 1.6,
            ),
            onPressed: () {
              showResultDialog(context, counterFront, counterBehind);
            },
          ),
        ],
      ),
    );
  }
}
