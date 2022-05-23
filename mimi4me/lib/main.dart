import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'audio_recorder.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'mimi4me';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _timerSec = 0;
  bool _finishStartup = false;

  Timer _timer = Timer.periodic(const Duration(seconds: 1),(Timer t) {});

  final _startUpTime = 5;

  @override
  void initState() {
    _startTimer();
    _finishStartup = false;
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildStartup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Image.asset('assets/image/logo.PNG')),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: SpinKitWave(
            color: Colors.lightBlue.shade400,
            type: SpinKitWaveType.start,
          ),
        ),
      ],
    );
  }

  void get _startUpStatus {
    if (_finishStartup) return;
    setState(() => _finishStartup = _timerSec <= _startUpTime);
  }

  Widget _buildMain() {
    return Scaffold(
      body: AudioRecorder(
        onStop: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_finishStartup) {
      _startUpStatus;
      return Container(
        color: Colors.white,
        child: AnimatedOpacity(
            opacity: _finishStartup ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: _buildStartup(),
          ),
      );
    }
    return _buildMain();
  }

  void _startTimer() {
    _timer.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => {if (_timerSec < _startUpTime) _timerSec++});
    });
  }
}
