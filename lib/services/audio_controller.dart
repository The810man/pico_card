import 'package:audioplayers/audioplayers.dart';

enum AudioType { music, fx, ui }

class AudioRepository {
  static final AudioRepository _instance = AudioRepository._internal();
  factory AudioRepository() => _instance;
  AudioRepository._internal();

  final _players = <AudioType, AudioPlayer>{
    AudioType.music: AudioPlayer()..setReleaseMode(ReleaseMode.loop),
    AudioType.fx: AudioPlayer(),
    AudioType.ui: AudioPlayer(),
  };

  double musicVolume = 1.0;
  double fxVolume = 1.0;
  double uiVolume = 1.0;
  bool musicMute = false;
  bool fxMute = false;
  bool uiMute = false;

  double _getVolume(AudioType t) {
    if (t == AudioType.music) return musicMute ? 0.0 : musicVolume;
    if (t == AudioType.fx) return fxMute ? 0.0 : fxVolume;
    return uiMute ? 0.0 : uiVolume;
  }

  void setVolume(AudioType t, double val) {
    if (t == AudioType.music) musicVolume = val;
    if (t == AudioType.fx) fxVolume = val;
    if (t == AudioType.ui) uiVolume = val;
  }

  void setMute(AudioType t, bool m) {
    if (t == AudioType.music) musicMute = m;
    if (t == AudioType.fx) fxMute = m;
    if (t == AudioType.ui) uiMute = m;
  }

  Future<void> play({
    required String assetPath,
    required AudioType type,
    double speed = 1.0,
    bool repeating = false,
  }) async {
    final player = _players[type]!;
    await player.setSource(AssetSource(assetPath));
    await player.setVolume(_getVolume(type));
    await player.setPlaybackRate(speed);
    await player.setReleaseMode(
      repeating ? ReleaseMode.loop : ReleaseMode.stop,
    );
    await player.resume();
  }

  Future<void> stop(AudioType type) async {
    await _players[type]?.stop();
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
  }
}
