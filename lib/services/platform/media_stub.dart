import 'media_iface.dart';

VoiceRecorderHandle createVoiceRecorder() => _StubVoiceRecorder();
AudioPlayerHandle createAudioPlayer() => _StubAudioPlayer();

class _StubVoiceRecorder implements VoiceRecorderHandle {
  @override
  bool get isSupported => false;
  @override
  Future<bool> start() async => false;
  @override
  Future<List<int>?> stop() async => null;
}

class _StubAudioPlayer implements AudioPlayerHandle {
  @override
  bool get isSupported => false;
  @override
  void load(String url) {}
  @override
  void play() {}
  @override
  void pause() {}
  @override
  void seek(double seconds) {}
  @override
  double get currentTime => 0.0;
  @override
  double get duration => 0.0;
  @override
  set onLoaded(void Function(double)? cb) {}
  @override
  set onEnded(void Function()? cb) {}
  @override
  void dispose() {}
}
