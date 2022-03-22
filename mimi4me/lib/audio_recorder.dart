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
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;

  final _audioRecorder = Record();
  final _recordTime = 3;
  final _sleepTime = 3;

  @override
  void initState() {
    _isSaved = false;
    _isRecording = false;
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
    if (_isRecording) _restart();
    return Align(
      alignment: Alignment.center,
      child: _buildRecordStopControl(),
    );
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_isRecording) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: tapFunction,
        ),
      ),
    );
  }

  void tapFunction() {
    if (_isRecording) {
      print("Force Stop");
      _stop();
      _isRecording = false;
    } else {
      print("Force Start");
      _start();
      _isRecording = true;
    }
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
