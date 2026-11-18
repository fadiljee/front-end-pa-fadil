import 'package:audioplayers/audioplayers.dart';

/// Mengelola pemutaran musik latar pada layar permainan.
class GameAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = true;

  bool get isMusicPlaying => _isMusicPlaying;

  Future<void> playBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.play(AssetSource('music/song.mp3'));
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> toggle() async {
    _isMusicPlaying = !_isMusicPlaying;
    if (_isMusicPlaying) {
      await _audioPlayer.resume();
    } else {
      await _audioPlayer.pause();
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
