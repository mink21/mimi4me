import 'package:flutter/material.dart';
import 'audio_recorder.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

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
  @override
  void initState() {
    _startTimer();
    _finishStartup = false;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final _startUpTime = 5;
  int _timerSec = 0;
  bool _finishStartup = false;
  Timer? _timer;

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

  Future<bool> get _checkStartUp async {
    setState(() {
      _finishStartup = _timerSec <= _startUpTime;
    });
    return _finishStartup;
  }

  Widget _buildMain() {
    return Scaffold(
      body: AudioRecorder(
        onStop: (path) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkStartUp;
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _finishStartup ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: _buildStartup(),
          ),
          AnimatedOpacity(
            opacity: _finishStartup ? 0.0 : 1.0,
            duration: const Duration(seconds: 1),
            child: _buildMain(),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => {if (_timerSec <= _startUpTime) _timerSec++});
    });
  }
}
