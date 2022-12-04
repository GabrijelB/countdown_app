import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:countdown_app/providers/soundPlayer.dart';
import 'package:flutter/foundation.dart';
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
  final String soundPath = "assets/audio/beep.mp3";
  late SoundPlayer soundPlayer = SoundPlayer(soundPath);
  late FlutterTts flutterTts;
  late Timer _timer;
  int time = 0;
  int delayInSec = 5;
  bool isTimerRunning = false;
  String? language;
  String? engine;
  bool isCurrentLanguageInstalled = false;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      await flutterTts.setEngine(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      await flutterTts.setLanguage(voice["locale"]);
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _speak(text) async {
    await flutterTts.setVolume(1);
    // await flutterTts.setLanguage(language!);
    if (text != null) {
      await flutterTts.speak(text);
    }
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
                if (time > delayInSec || timer.tick > delayInSec)
                  {
                    setState(() {
                      time++;
                      if (time % 10 == 0) {
                        _speak(time.toString());
                        return;
                      }
                      soundPlayer.play();
                    }),
                  }
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
