import 'dart:async';
import 'package:flutter/material.dart';

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
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image/new_logo_sm.png'),
            const Text(
              "M I M I 4 M E",
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w300,
                color: Colors.black,
                fontSize: 36,
                fontFamily: "Roboto",
              ),
            ),
            const Text(
              "S O U N D  A L E R T  A P P",
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 12,
                fontFamily: "Roboto",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
