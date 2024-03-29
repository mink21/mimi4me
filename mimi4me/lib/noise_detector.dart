// ignore_for_file: use_full_hex_values_for_flutter_colors
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'noise.dart';
import 'settings.dart';
import 'notifications.dart';

NoiseDetector noiseDetectorPageMain = NoiseDetector(
  onStop: (cause, decibel) {
    if (settingPageMain.notifFlag &&
        settingPageMain.selectedSounds.contains(cause)) {
      notificationPageMain.addNotifications(
          cause, decibel, DateTime.now().toString());
    }
  },
);

// ignore: must_be_immutable
class NoiseDetector extends StatefulWidget {
  final void Function(String cause, int decibel) onStop;

  NoiseDetector({required this.onStop, Key? key}) : super(key: key);

  Color _color = Colors.blue;

  Color get color => _color;

  @override
  _NoiseDetectorState createState() => _NoiseDetectorState();
}

class _NoiseDetectorState extends State<NoiseDetector>
    with WidgetsBindingObserver {
  bool _isMicon = false;
  bool _isRecording = false;
  bool _showAlert = false;
  final List<String> _showAlertList = [
    'Car Honks',
    'Gun Shot',
    'Jackhammer',
    'Siren',
  ];

  late tfl.Interpreter model;

  final causes = settingPageMain.totalNoise.asMap();

  int _decibels = 0;
  int _recordDuration = 0;

  String _cause = "";

  Timer _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {});

  final int _intervals = 4;

  Widget _causeWidget = Container();

  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  final List<double> totalVolumes = [];

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

  BoxDecoration backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        noiseDetectorPageMain.color.withOpacity(0.0),
        noiseDetectorPageMain.color.withOpacity(0.05),
        noiseDetectorPageMain.color.withOpacity(0.1),
        noiseDetectorPageMain.color.withOpacity(0.15),
        noiseDetectorPageMain.color.withOpacity(0.2),
      ],
    ),
  );

  void updateCauseWidget(String cause) {
    setState(
      () => _causeWidget = Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 60),
            child: Stack(
              children: [
                Text(
                  'Possible Sounds',
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      alignment: Alignment.centerLeft,
                      child: child,
                    );
                  },
                  child: Text(
                    '\n$cause',
                    key: ValueKey<String>(cause),
                    style: TextStyle(
                      color: widget.color,
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
                    color: widget.color.withOpacity(1.0),
                    size: 50.0,
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  AppLifecycleState _notification = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _notification = state);
  }

  @override
  void initState() {
    _micPermission;
    _isRecording = false;

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _noiseMeter = NoiseMeter(onError);
  }

  @override
  void dispose() {
    _timer.cancel();
    _noiseSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (!_isRecording) {
        _isRecording = true;
      }
      _decibels = noiseReading.meanDecibel.round();
      totalVolumes.addAll(noiseReading.volumes);
      _changeColor();
      if (_notification != AppLifecycleState.resumed &&
          !settingPageMain.bgFlag) {
        stop();
      }
    });
    if (_recordDuration >= _intervals) {
      _decibels = noiseReading.meanDecibel.round();
      _fetchResult();
      setState(() {
        _recordDuration = 0;
      });

      if (_notification != AppLifecycleState.resumed &&
          !settingPageMain.bgFlag) {
        stop();
      }
      widget.onStop(_cause, _decibels.toInt());
      _changeColor();
    }
  }

  void onError(Object error) {
    _isRecording = false;
  }

  void start() async {
    _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    _startTimer();
  }

  void stop() async {
    if (_noiseSubscription != null) {
      _noiseSubscription!.cancel();
      _noiseSubscription = null;
      totalVolumes.clear();
    }
    setState(() {
      _isRecording = false;
      _recordDuration = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color.withOpacity(0.0),
              widget.color.withOpacity(0.05),
              widget.color.withOpacity(0.1),
              widget.color.withOpacity(0.15),
              widget.color.withOpacity(0.2),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 30),
          padding: const EdgeInsets.all(5),
          decoration: backgroundDecoration,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(top: 15),
                    child: const Text(
                      "HOME",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w300),
                    ),
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
              (_showAlert)
                  ? AlertDialog(
                      title: Container(),
                      content: RichText(
                        text: TextSpan(
                          text: "There was a ",
                          style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w300),
                          children: [
                            TextSpan(
                              text: "$_cause ",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const TextSpan(text: "which has "),
                            TextSpan(
                              text: "$_decibels",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const TextSpan(text: "db!"),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child: const Text(
                            "Call Emergency",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            final Uri url = Uri.parse('tel:119');
                            launchUrl(url);
                          },
                        ),
                        TextButton(
                          child: const Text("OK"),
                          onPressed: () => setState(() => _showAlert = false),
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
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
              color: widget.color,
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: RichText(
              maxLines: 2,
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: widget.color,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: noiseValue.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                      color: widget.color,
                    ),
                  ),
                  const TextSpan(
                    text: '\ndB',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      color: Color(0xffbacb3bf),
                    ),
                  ),
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
          onTap: _tapFunction,
          child: SizedBox(
            width: 56,
            height: 56,
            child: icon,
          ),
        ),
      ),
    );
  }

  Future<void> _vibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate(duration: 2000);
    }
  }

  Future<void> _changeColor() async {
    if (_decibels >= 100) {
      setState(() => noiseDetectorPageMain._color = Colors.red);
      await _vibrate();
    } else if (_decibels > 60) {
      setState(() => noiseDetectorPageMain._color = Colors.orange);
    } else if (_decibels > 40) {
      setState(() => noiseDetectorPageMain._color =
          const Color.fromARGB(255, 251, 228, 22));
    } else if (_decibels > 30) {
      setState(() => noiseDetectorPageMain._color = Colors.green);
    } else {
      setState(() => noiseDetectorPageMain._color = Colors.blue);
    }
  }

  int getIndex(List<dynamic> output) {
    int index = 0;
    double max = 0.0;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > max) {
        max = output[0][i];
        index = i;
      }
    }
    return index;
  }

  Future<void> _fetchResult() async {
    model = await tfl.Interpreter.fromAsset('saved_model.tflite');
    if (totalVolumes.length >= 44100) {
      var output = List.filled(1 * 10, 0).reshape([1, 10]);
      var use = totalVolumes.sublist(0, 44100).reshape([1, 44100]);
      model.run(use, output);
      final indexResult = getIndex(output);
      setState(() => _cause = causes[indexResult].toString());
      totalVolumes.clear();
      FlutterForegroundTask.updateService(
        notificationTitle: 'Sound Alert',
        notificationText: 'There was a $_cause! SoundLevel: $_decibels',
      );
      if (_showAlertList.contains(_cause)) {
        _vibrate();
        setState(() => _showAlert = true);
        stop();
        if (_notification != AppLifecycleState.resumed) {
          FlutterForegroundTask.launchApp('/');
        }
        widget.onStop(_cause, _decibels.toInt());
      }
    }
    _changeColor();
  }

  void _startTimer() {
    _timer.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => (_isRecording) ? _recordDuration++ : null);
    });
  }
}
