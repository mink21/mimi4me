import 'dart:async';
import 'dart:convert';
import 'package:record/record.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  final void Function() onStop;

  const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isMicon = false;
  bool _isSaved = false;
  bool _isPosted = false;
  bool _isFetched = false;
  bool _isRecording = false;

  int _decibels = 0;
  int _recordDuration = 0;

  Color _color = Colors.blue;

  String _cause = "";

  late Uri _uri;
  late Timer _timer;
  late String _path;

  final _recordTime = 5;
  final _audioRecorder = Record();

  void get _apiUrl async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['apiUrl']!;
    setState(() => _uri = Uri.parse(url));
  }

  void get _localPath async {
    final directory = await getExternalCacheDirectories();
    setState(() => _path = directory![0].path + "/audio.mp4");
  }

  void get _micPermission async {
    final serviceStatus = await Permission.microphone.status;
    setState(() => _isMicon = serviceStatus == ServiceStatus.enabled);
  }

  void _tapFunction() {
    if (_isRecording) {
      _stop();
      setState(() => _isRecording = false);
    } else {
      _start();
      if (_isMicon) {
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  void initState() {
    _localPath;
    _apiUrl;
    _micPermission;

    _isSaved = false;
    _isRecording = false;

    _start();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  LinearGradient get _gradientColor {
    return LinearGradient(
      begin: const Alignment(0, 2),
      end: const Alignment(0, -0.7),
      colors: [
        _color.withOpacity(0.3),
        Colors.white,
      ],
    );
  }

  BoxDecoration get _boxDecoration {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        width: 30.0,
        color: _color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) _restart();
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: _gradientColor,
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: _buildDecibel(_decibels),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: _buildRecord(),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: _buildCauses(_cause),
          ),
        ],
      ),
    );
  }

  Widget _buildDecibel(int noiseValue) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.bounceOut,
          margin: const EdgeInsets.only(top: 60.0),
          padding: const EdgeInsets.all(10.0),
          width: 270.0,
          height: 270.0,
          decoration: _boxDecoration,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                    ),
                  ),
                  const TextSpan(text: 'db'),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 10),
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
    if (!_isRecording) return Container();

    Widget _loadingCircle = SpinKitCircle(
      color: _color.withOpacity(1.0),
      size: 50.0,
    );
    if (cause == "") return _loadingCircle;
    if (!_isRecording) _loadingCircle = Container();

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 60),
          child: Stack(
            children: [
              const Text(
                'Possible Cause',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    child: child,
                    scale: animation,
                    alignment: Alignment.centerLeft,
                  );
                },
                child: Text(
                  '\n$cause',
                  key: ValueKey<String>(cause),
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: _loadingCircle,
        ),
      ],
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
          child: SizedBox(
            width: 56,
            height: 56,
            child: icon,
          ),
          onTap: _tapFunction,
        ),
      ),
    );
  }

  Future<void> _start() async {
    if (_isMicon || await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(
        path: _path,
        bitRate: 1280,
      );

      setState(() {
        _isMicon = true;
        _isSaved = false;
        _isFetched = false;
        _recordDuration = 0;
      });

      _startTimer();
    }
  }

  Future<void> _stop() async {
    await _audioRecorder.stop();
    widget.onStop();

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
    if (_decibels >= 100) {
      setState(() => _color = Colors.red);
      await _vibrate();
    } else if (_decibels > 60) {
      setState(() => _color = Colors.orange);
    } else if (_decibels > 35) {
      setState(() => _color = Colors.yellow);
    } else if (_decibels > 30) {
      setState(() => _color = Colors.green);
    } else {
      setState(() => _color = Colors.blue);
    }
  }

  Future<void> _postResult() async {
    var request = http.MultipartRequest("POST", _uri);
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      _path,
      contentType: MediaType('audio', 'mp4'),
    ));

    final response = await request.send();
    setState(() => _isPosted = response.statusCode == 200);
  }

  Future<void> _fetchResult() async {
    if (!_isPosted) return;
    final response = await http.get(_uri);
    var data = jsonDecode(response.body);
    setState(() {
      _decibels = data["decibels"];
      _cause = _decibels > 0 ? data["cause"] : "None";
      _isFetched = true;
    });

    _changeColor();
  }

  void _restart() async {
    if (!_isSaved && _recordDuration >= _recordTime) {
      await _stop();
      await _postResult();
      await _fetchResult();
    } else if (_isSaved && _isFetched) {
      await _start();
    }
  }

  void _startTimer() {
    _timer.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
