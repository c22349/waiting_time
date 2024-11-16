import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:vibration/vibration.dart';
import '../const.dart';

class TimerModel extends ChangeNotifier {
  int _timer = defaultTimerSeconds;
  Timer? _countdownTimer;
  final AudioPlayer _player = AudioPlayer();

  int get timer => _timer;
  Timer? get countdownTimer => _countdownTimer;
  bool get isRunning => _countdownTimer != null;

  void toggleTimer(BuildContext context, bool soundEnabled) {
    if (_timer == 0) {
      _timer = defaultTimerSeconds;
      notifyListeners();
    }

    if (_countdownTimer == null) {
      _startTimer(context, soundEnabled);
    } else {
      _stopTimer();
    }
  }

  void _startTimer(BuildContext context, bool soundEnabled) {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        _timer--;
        notifyListeners();
      } else {
        _stopTimer();
        if (soundEnabled) {
          _playAlarm();
        }
        _startRepeatedVibration();
      }
    });
    notifyListeners();
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    notifyListeners();
  }

  void resetTimer() {
    _stopTimer();
    _timer = defaultTimerSeconds;
    notifyListeners();
  }

  Future<void> _playAlarm() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    await _player.setSource(AssetSource(alarmAudioPath));
    await _player.play(AssetSource(alarmAudioPath));

    Future.delayed(const Duration(seconds: 2), () {
      _player.stop();
    });
  }

  void _startRepeatedVibration() {
    Vibration.vibrate(duration: 250);
    Timer.periodic(const Duration(seconds: 1), (Timer vibrationOrder) {
      if (vibrationOrder.tick < 2) {
        Vibration.vibrate(duration: 250);
      } else {
        vibrationOrder.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}

// Androidで利用している可能性あり
// void _startTimer() {
//   _countdownTimer?.cancel();
//   setState(() {
//     _timer = defaultTimerSeconds;
//   });
//   _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//     setState(() {
//       if (_timer > 0) {
//         _timer--;
//       } else {
//         if (Provider.of<SettingModel>(context, listen: false).soundEnabled) {
//           // スイッチがONの場合のみアラームを鳴らす
//           _startRepeatedVibration();
//           _countdownTimer?.cancel();
//           final player = AudioPlayer();
//           player.setSource(AssetSource(alarmAudioPath));
//           player.play(AssetSource(alarmAudioPath));
//           // Android alarm time
//           Future.delayed(const Duration(seconds: 2), () {
//             player.stop();
//           });
//         }
//       }
//     });
//   });
// }
