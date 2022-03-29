import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';
//import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isSaved = false;
  String _cause = "";
  String _decibels = "";
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  final _path = "/data/user/0/com.example.mimi4me/cache/audio.mp4";
  //final dio = Dio();
  List<String> _causeList = [];

  Color _color = Colors.green;
  int _noiseValue = 0;

  final _audioRecorder = Record();
  final _recordTime = 3;
  final _sleepTime = 3;

  @override
  void initState() {

    _isSaved = false;
    _isRecording = true;
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
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0, 2),
            end: const Alignment(0, -0.7),
            colors: [
              _color.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: Stack(children: [
          Align(alignment: Alignment.center, child: _buildRecord()),
          Align(
              alignment: Alignment.topCenter,
              child: _buildDecibel(_noiseValue)),
          Positioned(top: 400, child: _buildCauses(_causeList))
        ]));
  }

  Widget _buildDecibel(int noiseValue) {
    return Stack(
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
                color: _color,
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: RichText(
                maxLines: 1,
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: _color,
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
    );
  }

  Widget _buildCauses(List<String> causesList) {
    const _style = TextStyle(
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.bold,
        fontSize: 30);

    var _list = causesList
        .map((String cause) => TextSpan(text: cause, style: _style))
        .toList();
    if (_noiseValue > 0) {
      _list.insert(
          0,
          const TextSpan(
              text: 'Possible Cause\n',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)));
    }
    return Container(
      padding: const EdgeInsets.only(left: 60.0, top: 30.0),
      child: RichText(
        softWrap: true,
        text: TextSpan(
          text: _cause,
          style: TextStyle(
            fontSize: 14.0,
            color: _color,
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
    }
    // else {
    //   final theme = Theme.of(context);
    //   icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
    //   color = theme.primaryColor.withOpacity(0.1);
    // }

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
        await _audioRecorder.start(
          path: _path,
          bitRate: 1280,
          //sampleRate: 44100,
        );

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
    //print(path);
    widget.onStop(path!);

    setState(() {
      _isSaved = true;
      _recordDuration = 0;
    });
  }

  void _vibrate() async {
    bool? _hasVibrator = await Vibration.hasVibrator();
    print(_hasVibrator);
    if (_hasVibrator != null && _hasVibrator) {
      Vibration.vibrate(duration: 2000);
    }
  }

  void _changeColor() {
    if (_noiseValue >= 140) {
      _color = Colors.red;
    } else if (_noiseValue > 100) {
      _color = Colors.orange;
    } else if (_noiseValue > 60) {
      _color = Colors.yellow;
    } else {
      _color = Colors.green;
    }
    _vibrate;
  }

  void _fetchResult() async{
    const url = 'http://10.0.2.2:5000/';
    final uri = Uri.parse(url);

    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      _path,
      contentType: MediaType('audio', 'mp4'),
    ));

    request.send();
    final response = await http.get(uri);
    var data = jsonDecode(response.body);

    setState(() {
      _cause = data["cause"];
      _decibels = data["decibels"];
    });
    final _random = Random();
    int nextNoiseValue(int min, int max) => min + _random.nextInt(max - min);
    _noiseValue = nextNoiseValue(0, 200);


    _changeColor();
  }

  void _restart() async{
    if (!_isSaved && _recordDuration >= _recordTime) {
      await _stop();
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
