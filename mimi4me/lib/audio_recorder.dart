import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isSaved = false;
  bool _isfetched = false;
  bool _isRecording = false;

  int _decibels = 0;
  int _recordDuration = 0;

  Timer? _timer;
  Color _color = Colors.green;

  String _cause = "";
  late String _path;
  late Uri _uri;

  final _audioRecorder = Record();
  final _recordTime = 3;

  void get _apiUrl async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['apiUrl']!;
    setState(() {
      _uri = Uri.parse(url);
    });
  }

  void get _localPath async {
    final directory = await getExternalCacheDirectories();
    setState(() {
      _path = directory![0].path + "/audio.mp4";
    });
  }

  void _tapFunction() {
    if (_isRecording) {
      _stop();
      _isRecording = false;
    } else {
      _start();
      _isRecording = true;
    }
  }

  @override
  void initState() {
    _isSaved = false;
    _isRecording = false;
    _localPath;
    _apiUrl;
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
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: _buildRecord(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildDecibel(_decibels),
          ),
          Positioned(
            top: 400,
            child: _buildCauses(_cause),
          )
        ],
      ),
    );
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

  Widget _buildCauses(String cause) {
    if (cause == "") {
      return Container();
    }

    const _style = TextStyle(
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.bold,
        fontSize: 30);

    return Container(
      padding: const EdgeInsets.only(left: 60.0, top: 30.0),
      child: RichText(
        softWrap: true,
        text: TextSpan(
          text: 'Possible Cause\n',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          children: [
            TextSpan(
              text: cause,
              style: _style,
            ),
          ],
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

  Future<void> _start() async {
    if (await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(
        path: _path,
        bitRate: 1280,
      );

      setState(() {
        _isSaved = false;
        _isfetched = false;
        _recordDuration = 0;
      });

      _startTimer();
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

  Future<void> _vibrate() async {
    bool? _hasVibrator = await Vibration.hasVibrator();
    if (_hasVibrator != null && _hasVibrator) {
      Vibration.vibrate(duration: 2000);
    }
  }

  Future<void> _changeColor() async {
    if (_decibels >= 120) {
      _color = Colors.red;
    } else if (_decibels > 90) {
      _color = Colors.yellow;
    } else if (_decibels > 60) {
      _color = Colors.green;
    } else {
      _color = Colors.blue;
    }
    await _vibrate();
  }

  Future<void> _postResult() async {
    var request = http.MultipartRequest("POST", _uri);
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      _path,
      contentType: MediaType('audio', 'mp4'),
    ));

    await request.send();
  }

  Future<void> _fetchResult() async {
    final response = await http.get(_uri);
    var data = jsonDecode(response.body);
    setState(() {
      _decibels = data["decibels"];
      if (_decibels > 0) _cause = data["cause"];
      _isfetched = true;
    });

    _changeColor();
  }

  void _restart() async {
    if (!_isSaved && _recordDuration >= _recordTime) {
      await _stop();
      await _postResult();
      await _fetchResult();
    } else if (_isSaved && _isfetched) {
      await _start();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
