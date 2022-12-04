import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundPlayer {
  late final BytesSource _sound;
  final AudioPlayer _player = AudioPlayer();

  SoundPlayer(String soundPath) {
    _load(soundPath);
  }

  _load(soundPath) async {
    ByteData bytes = await rootBundle.load(soundPath);
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    _sound = BytesSource(soundbytes);
  }

  play() async {
    await _player.play(_sound);
  }
}
