import 'dart:async';
import 'dart:math';

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
  bool _isSleeping = false;
  int _recordDuration = 0;
  Timer? _timer;

  int _noiseValue = 60;
  List<String> _causeList = [
    'Conversation\n',
    'Background Music',
  ];

  final _audioRecorder = Record();
  final _recordTime = 3;
  final _sleepTime = 3;

  @override
  void initState() {
    _isSaved = false;
    _isRecording = false;
    _isSleeping = false;
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

    return Stack(children: [
      Align(alignment: Alignment.center, child: _buildRecord()),
      Align(alignment: Alignment.topCenter, child: _buildDecibel(_noiseValue)),
      Positioned(top: 400, child: _buildCauses(_causeList))
    ]);
  }

  Widget _buildDecibel(int noiseValue) {
    return Material(
        child: Stack(
      children: [
        Container(
            margin: const EdgeInsets.only(top: 60.0),
            padding: const EdgeInsets.all(10.0),
            width: 270.0,
            height: 270.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 30.0,
                color: Colors.green,
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: RichText(
                maxLines: 1,
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.green,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: noiseValue.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 60)),
                    const TextSpan(text: 'db'),
                  ],
                ),
              ),
            )),
        Positioned(
          bottom: 5,
          left: 125,
          child: Container(
            margin: const EdgeInsets.only(top: 60.0),
            width: 20.0,
            height: 20.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildCauses(List<String> causesList) {
    const _style = TextStyle(
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.bold,
        fontSize: 30);

    var _list = causesList
        .map((String cause) => TextSpan(text: cause, style: _style))
        .toList();
    _list.insert(
        0,
        const TextSpan(
            text: 'Possible Cause\n',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)));
    return Container(
      padding: const EdgeInsets.only(left: 60.0, top: 30.0),
      child: RichText(
        softWrap: true,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.green,
          ),
          children: _list,
        ),
      ),
    );
  }

  Widget _buildRecord() {
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
          onTap: _tapFunction,
        ),
      ),
    );
  }

  void _tapFunction() {
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
          _isSleeping = false;
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
      _isSleeping = true;
      _recordDuration = 0;
    });
  }

  void _fetchResult() {
    final _random = Random();
    int nextNoiseValue(int min, int max) => min + _random.nextInt(max - min);
    _noiseValue = nextNoiseValue(0, 99);

    final List<String> possibleCauseList = [
      'Conversation\n',
      'Background Music\n',
      'Car Hunks\n',
      'Traffics\n',
    ];
    _causeList = (possibleCauseList..shuffle()).sublist(2);
  }

  void _restart() {
    if (!_isSaved && _recordDuration >= _recordTime) {
      _stop();
      _fetchResult();
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
