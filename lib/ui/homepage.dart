import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TimerSignalApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _timer;
  int time = 0;
  bool isTimerRunning = false;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _playSound() async {
    final AudioPlayer player = AudioPlayer();
    const beepAudioPath = "assets/audio/beep.mp3";
    ByteData bytes = await rootBundle.load(beepAudioPath);
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    await player.play(BytesSource(soundbytes));
  }

  _speak(text) async {
    final flutterTts = FlutterTts();
    await flutterTts.speak(text);
  }

  _showToast(msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  _onLongPress() {
    setState(() {
      time = 0;
      _timer.cancel();
      isTimerRunning = false;
      _showToast("Stopwatch reset");
    });
  }

  _onClick() {
    if (!isTimerRunning) {
      _showToast("Stopwatch started");
      isTimerRunning = true;
      _timer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) => {
                setState(() {
                  time++;
                  if (time % 10 == 0) {
                    _speak(time.toString());
                    return;
                  }
                  _playSound();
                }),
              });
      return;
    }
    _timer.cancel();
    isTimerRunning = false;
    _showToast("Stopwatch paused at $time");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: _onClick,
                onLongPress: _onLongPress,
                child: Center(
                  child: Text(
                    '$time',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
