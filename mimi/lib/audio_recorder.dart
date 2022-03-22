import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isSaved = false;
  int _recordDuration = 0;
  Timer? _timer;

  final _audioRecorder = Record();
  final _recordTime = 3;
  final _sleepTime = 3;

  @override
  void initState() {
    _isSaved = false;
    _start();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _restart();
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildRecordStopControl(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordStopControl() {
    final theme = Theme.of(context);
    final Icon icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
    final Color color = theme.primaryColor.withOpacity(0.1);

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
        ),
      ),
    );
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        setState(() {
          _isSaved = false;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
    
    widget.onStop(path!);

    setState(() {
      _isSaved = true;
      _recordDuration = 0;
    });
  }

  void _restart() {
    if (!_isSaved && _recordDuration >= _recordTime) {
      _stop();
    } else if (_isSaved && _recordDuration >= _sleepTime) {
      _start();
    }
    print(_recordDuration);
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
