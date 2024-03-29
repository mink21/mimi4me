import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'main.dart';
import 'noise_detector.dart';

SettingsPage settingPageMain = SettingsPage();

final box = GetStorage();

String keySoundList = 'sounds';

String keyBgSetting = 'background';
String keyNotifSetting = 'notification';

String keyAcFlag = "AC";
String keyKidsFlag = "Kids Playing";
String keyDogBarkFlag = "Dog Bark";
String keyDrilling = "Drilling";

class Sound {
  final Color color;
  final Color lighColor;
  final IconData icon;
  Sound({
    required this.color,
    required this.lighColor,
    required this.icon,
  });
}

final Map<String, Sound> _totalNoise = {
  'AC': Sound(
      color: Colors.blue,
      lighColor: Colors.blue.shade100,
      icon: Icons.air_outlined),
  'Car Honks': Sound(
      color: Colors.red,
      lighColor: Colors.red.shade100,
      icon: Icons.bus_alert_sharp),
  'Kids Playing': Sound(
      color: Colors.blue,
      lighColor: Colors.blue.shade100,
      icon: Icons.add_reaction_rounded),
  'Dog Bark': Sound(
    color: Colors.orange,
    lighColor: Colors.orange.shade100,
    icon: const IconData(0xf479),
  ),
  'Drilling': Sound(
      color: Colors.orange,
      lighColor: Colors.orange.shade100,
      icon: Icons.construction_rounded),
  'Engine Idling': Sound(
      color: Colors.green,
      lighColor: Colors.green.shade100,
      icon: Icons.car_rental_outlined),
  'Gun Shot': Sound(
      color: Colors.red,
      lighColor: Colors.red.shade100,
      icon: Icons.question_mark),
  'Jackhammer': Sound(
      color: Colors.red,
      lighColor: Colors.red.shade100,
      icon: Icons.question_answer),
  'Siren': Sound(
      color: Colors.red,
      lighColor: Colors.red.shade100,
      icon: Icons.campaign_rounded),
  'Street Music': Sound(
      color: Colors.green,
      lighColor: Colors.green.shade100,
      icon: Icons.music_note),
};

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  List<String> get totalNoise => _totalNoise.keys.toList();

  bool _bgFlag = box.read(keyBgSetting) ?? false;
  bool _notifFlag = box.read(keyNotifSetting) ?? false;

  Map<String, bool> _flags = Map.fromIterables(
      _totalNoise.keys.toList(),
      List.generate(_totalNoise.length,
          (index) => box.read(_totalNoise.keys.toList()[index]) ?? true));

  List<String> _selectedSounds =
      (box.read(keySoundList) ?? _totalNoise.keys.toList()).cast<String>()
          as List<String>;

  SettingsPage({Key? key}) : super(key: key);

  bool get bgFlag => _bgFlag;
  bool get notifFlag => _notifFlag;
  List<String> get selectedSounds => _selectedSounds;
  Map<String, bool> get flags => _flags;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ReceivePort? _receivePort;

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'mimi_notfication',
        channelName: 'Mimi4me Notification',
        channelImportance: NotificationChannelImportance.HIGH,
        enableVibration: true,
        playSound: true,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.white,
        ),
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000,
        autoRunOnBoot: false,
        allowWifiLock: false,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) return false;
    }

    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Mimi4me',
        notificationText: 'Notifcations is On',
        callback: startCallback,
      );
    }
    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {});

      return true;
    }

    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    box.write(keySoundList, widget._selectedSounds);
    super.dispose();
  }

  Widget card(String name, bool state, Sound sound, Function(String) update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 25),
            decoration: BoxDecoration(
              color: sound.lighColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
              ),
            ),
            child: Icon(
              sound.icon,
              color: sound.color,
            ),
          ),
          InkWell(
            onTap: () => update(name),
            child: Row(
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                    left: 8,
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 5),
                  child: (state)
                      ? const Icon(
                          Icons.star_outlined,
                          color: Colors.blue,
                        )
                      : const Icon(
                          Icons.star_outline,
                          color: Colors.grey,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateFlag(String val) {
    setState(() => widget._flags[val] = !widget.flags[val]!);
    box.write(val, widget.flags[val]);
  }

  void checkAllState() {
    final List<String> currentState = [];
    widget.flags.forEach((i, v) {
      if (v) currentState.add(i);
    });

    setState(() => widget._selectedSounds = currentState);
    box.write(keySoundList, widget._selectedSounds);
  }

  @override
  Widget build(BuildContext context) {
    checkAllState();
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
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
        ),
        child: ListView(
          children: [
            Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(top: 15),
              child: const Text(
                "Settings",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w300),
              ),
            ),
            CheckboxListTile(
              activeColor: Colors.blue,
              title: const Text(
                'Run On Background',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "Turn on to run mimi4me on background. This will allow the app to alert you even if you close the app. Learn more.",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10,
                    fontWeight: FontWeight.w400),
              ),
              value: widget.bgFlag,
              onChanged: (e) {
                setState(() => widget._bgFlag = e!);
                box.write(keyBgSetting, widget.bgFlag);
              },
            ),
            CheckboxListTile(
              activeColor: Colors.blue,
              title: const Text(
                'Allow Notifications',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "Get notifications when there is a sound you selected. You can turn them off when they’re not needed. Learn more.",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10,
                    fontWeight: FontWeight.w400),
              ),
              value: widget.notifFlag,
              onChanged: (e) {
                setState(() {
                  widget._notifFlag = e!;
                  widget.notifFlag
                      ? _startForegroundTask()
                      : _stopForegroundTask();
                });
                box.write(keyNotifSetting, widget.notifFlag);
              },
            ),
            const ListTile(
              title: Text(
                'Select Sounds',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                "Select sounds you want to be notified for. You can change your preferences anytime. Learn more.",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() => widget._flags = Map.fromIterables(
                            _totalNoise.keys.toList(),
                            List.generate(
                                _totalNoise.length, (index) => true)));
                      },
                      child: const Text("Select All")),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() => widget._flags = Map.fromIterables(
                            _totalNoise.keys.toList(),
                            List.generate(
                                _totalNoise.length, (index) => false)));
                      },
                      child: const Text("Remove All")),
                ),
              ],
            ),
            Container(
              height: (MediaQuery.of(context).size.height - 100) * 50 / 100,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: LimitedBox(
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 10.0,
                            children: List.generate(
                              widget.totalNoise.length,
                              (index) => card(
                                widget.totalNoise[index],
                                widget.flags[widget.totalNoise[index]]!,
                                _totalNoise[widget.totalNoise[index]]!,
                                _updateFlag,
                              ),
                            ),
                          ),
                        ]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
