import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  int _timerSec = 0;
  bool _finishStartup = false;

  Timer _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {});

  final _startUpTime = 5;

  void _startTimer() {
    _timer.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => {if (_timerSec < _startUpTime) _timerSec++});
    });
  }

  void get _startUpStatus {
    if (_finishStartup) Navigator.of(context).pop();
    print(_timerSec);
    setState(() => _finishStartup = _timerSec >= _startUpTime);
  }

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

  @override
  Widget build(BuildContext context) {
    _startUpStatus;
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
}
