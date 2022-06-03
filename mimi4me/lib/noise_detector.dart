import 'package:flutter/material.dart';
import 'dart:async';
import 'noise.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'settings.dart';

NoiseDetector noiseDetectorPageMain = NoiseDetector(
  onStop: (cause, decibel) {
    if (settingPageMain.notifFlag &&
        settingPageMain.selectedSounds.contains(cause)) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Sound Check',
        notificationText: 'Causes: $cause, SoundLevel: $decibel',
      );
    }
    print("APP-MAIN: $cause,$decibel");
  },
);

class NoiseDetector extends StatefulWidget {
  final void Function(String cause, int decibel) onStop;

  const NoiseDetector({required this.onStop, Key? key}) : super(key: key);

  @override
  _NoiseDetectorState createState() => _NoiseDetectorState();
}

class _NoiseDetectorState extends State<NoiseDetector>
    with WidgetsBindingObserver {
  bool _isMicon = false;
  bool _isSaved = false;
  bool _isPosted = false;
  bool _isFetched = false;
  bool _isRecording = false;

  int _decibels = 0;
  int _recordDuration = 0;

  Color _color = Colors.blue;

  String _cause = "";
  String _path = "";

  int index = 0;
  List<double> _decibelList = [60, 80, 120];
  List<String> _causeList = ["1", "2", "3", "4"];

  Timer _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {});

  late Uri _uri;

  int _intervals = 4;

  Widget _causeWidget = Container();

  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  final List<double> totalVolumes = [];

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
      stop();
      setState(() => _isRecording = false);
    } else {
      start();
      if (_isMicon) setState(() => _isRecording = true);
    }
  }

  void updateCauseWidget(String cause) {
    setState(() => _causeWidget = Column(
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
              child: (_isRecording)
                  ? SpinKitCircle(
                      color: _color.withOpacity(1.0),
                      size: 50.0,
                    )
                  : Container(),
            ),
          ],
        ));
  }

  AppLifecycleState _notification = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  void initState() {
    _localPath;
    _apiUrl;
    _micPermission;

    _isSaved = false;
    _isRecording = false;

    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _noiseMeter = NoiseMeter(onError);
  }

  @override
  void dispose() {
    _timer.cancel();
    _noiseSubscription?.cancel();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (!_isRecording) {
        _isRecording = true;
      }
      _decibels = noiseReading.meanDecibel.round();
      _changeColor();
    });
    //_restart();
    if (_recordDuration >= _intervals) {
      setState(() {
        _recordDuration = 0;
        if (index >= _causeList.length) index = 0;
        _cause = _causeList[index++];
        //_decibels = _decibelList[index];
      });

      print(_cause);
      if (_notification != AppLifecycleState.resumed &&
          !settingPageMain.bgFlag) {
        stop();
      }
      print("CURRENT STATE: $_notification");

      /*
      print("CURRENT STATE: $_notification");
      alertPageMain.updateCause(_cause);
      stop();
      if (_notification != AppLifecycleState.resumed) {
        FlutterForegroundTask.launchApp('/');
      }
      Navigator.of(context).pushNamed('/alert');*/
      _postResult();
      _fetchResult();
      widget.onStop(_cause, _decibels.toInt());
      _changeColor();
    }
    //print(noiseReading.toString());
    //print(totalVolumes.length);
    if (totalVolumes.length > 100000) totalVolumes.clear();
    //totalVolumes.addAll(noiseReading.volumes);
  }

  void onError(Object error) {
    print(error.toString());
    _isRecording = false;
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
      _startTimer();
      setState(() {
        _isFetched = false;
        _isSaved = false;
      });
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
        totalVolumes.clear();
      }
      setState(() {
        _isRecording = false;
        _isSaved = true;
        _recordDuration = 0;
        if (++index > _causeList.length) index = 0;
        _cause = "Not Checked";
        _decibels = 0;
      });
      widget.onStop(_cause, _decibels.toInt());
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "CURRENT STATE: $_notification, SOUND: ${settingPageMain.selectedSounds}");
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.center,
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: const Text("HOME"),
            ),
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
    (cause != "") ? updateCauseWidget(cause) : updateCauseWidget("None");

    return _causeWidget;
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
    /*var request = http.MultipartRequest("POST", _uri);
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      _path,
      contentType: MediaType('audio', 'mp4'),
    ));

    final response = await request.send();
    setState(() => _isPosted = response.statusCode == 200);*/
    setState(() => _isPosted = true);
  }

  Future<void> _fetchResult() async {
    if (!_isPosted) return;
    final response = await http.get(_uri);
    var data = jsonDecode(response.body);
    setState(() {
      /*_decibels = data["decibels"];
      _cause = _decibels > 0 ? data["cause"] : "None";*/
      _recordDuration = 0;
      _isFetched = true;
    });

    _changeColor();
  }

  void _startTimer() {
    _timer.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (_isRecording) _recordDuration++;
      });
    });
  }
}
