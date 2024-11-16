import 'package:flutter/material.dart';

class CounterModel extends ChangeNotifier {
  int _counterFront = 0;
  int _counterBehind = 0;
  final TextEditingController _counterFrontController = TextEditingController();
  final TextEditingController _counterBehindController =
      TextEditingController();

  int get counterFront => _counterFront;
  int get counterBehind => _counterBehind;
  TextEditingController get counterFrontController => _counterFrontController;
  TextEditingController get counterBehindController => _counterBehindController;

  CounterModel() {
    _counterFrontController.text = '$_counterFront';
    _counterBehindController.text = '$_counterBehind';
  }

  void updateCounterFront(String value) {
    _counterFront = int.tryParse(value) ?? _counterFront;
    _counterFrontController.text = '$_counterFront';
    notifyListeners();
  }

  void updateCounterBehind(String value) {
    _counterBehind = int.tryParse(value) ?? _counterBehind;
    _counterBehindController.text = '$_counterBehind';
    notifyListeners();
  }

  void incrementFront() {
    _counterFront++;
    _counterFrontController.text = '$_counterFront';
    notifyListeners();
  }

  void decrementFront() {
    if (_counterFront > 0) {
      _counterFront--;
      _counterFrontController.text = '$_counterFront';
      notifyListeners();
    }
  }

  void resetFront() {
    _counterFront = 0;
    _counterFrontController.text = '0';
    notifyListeners();
  }

  void incrementBehind() {
    _counterBehind++;
    _counterBehindController.text = '$_counterBehind';
    notifyListeners();
  }

  void decrementBehind() {
    if (_counterBehind > 0) {
      _counterBehind--;
      _counterBehindController.text = '$_counterBehind';
      notifyListeners();
    }
  }

  void resetBehind() {
    _counterBehind = 0;
    _counterBehindController.text = '0';
    notifyListeners();
  }

  @override
  void dispose() {
    _counterFrontController.dispose();
    _counterBehindController.dispose();
    super.dispose();
  }
}
