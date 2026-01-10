import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class MetronomeService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _metronomeTimer;
  bool _isActive = false;

  void start({required Function(int) onTick, required Function onPause}) {
    if (_isActive) return;
    _isActive = true;
    _runCycle(onTick, onPause);
  }

  void _runCycle(Function(int) onTick, Function onPause) {
    int count = 0;
    _metronomeTimer = Timer.periodic(const Duration(milliseconds: 545), (timer) async {
      if (count < 30) {
        count++;
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/metronome.mp3'), mode: PlayerMode.lowLatency);
        onTick(count);
      } else {
        timer.cancel();
        onPause();
        Future.delayed(const Duration(seconds: 5), () {
          if (_isActive) _runCycle(onTick, onPause);
        });
      }
    });
  }

  void stop() {
    _isActive = false;
    _metronomeTimer?.cancel();
  }
}