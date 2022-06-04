import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'main.dart';

SettingsPage settingPageMain = SettingsPage();

final box = GetStorage();
/*
String keyInterval = 'interval';
String keyCountry = 'country';
*/
String keySoundList = 'sounds';

String keyBgSetting = 'background';
String keyNotifSetting = 'notification';

String keyAcFlag = "AC";
String keyKidsFlag = "Kids Playing";
String keyDogBarkFlag = "Dog Bark";
//TODO: Add other Sound key

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  final List<String> _totalNoise = [
    keyAcFlag,
    keyKidsFlag,
    keyDogBarkFlag,
    //TODO: Add other Sound flag
  ];
  bool _bgFlag = box.read(keyBgSetting) ?? false;
  bool _notifFlag = box.read(keyNotifSetting) ?? false;

  bool _acFlag = box.read(keyAcFlag) ?? false;
  bool _kidsFlag = box.read(keyKidsFlag) ?? false;
  bool _dogFlag = box.read(keyDogBarkFlag) ?? false;

  //TODO: Add other Sound flag

  List<String> _selectedSounds = (box.read(keySoundList) ??
          [
            keyAcFlag,
            keyKidsFlag,
            keyDogBarkFlag,
            //TODO: Add other Sound flag
          ])
      .cast<String>() as List<String>;

  bool get bgFlag => _bgFlag;
  bool get notifFlag => _notifFlag;
  List<String> get selectedSounds => _selectedSounds;

  List<String> get totalNoise => _totalNoise;

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
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.DEFAULT,
        enableVibration: true,
        playSound: true,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.blue,
        ),
        buttons: [
          const NotificationButton(id: 'stop', text: 'Stop'),
        ],
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
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
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
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
      _receivePort?.listen((message) {
        print("Received: $message");
      });

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
    box.write(keyBgSetting, widget.bgFlag);
    box.write(keyNotifSetting, widget.notifFlag);
    super.dispose();
  }

  Widget card(String name, bool state, Color lightColor, Color boldColor,
      Function update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
              ),
            ),
            child: Icon(
              Icons.hourglass_empty,
              color: boldColor,
            ),
          ),
          InkWell(
            onTap: () => update(),
            child: Row(
              children: [
                Container(
                  width: 90,
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 8,
                  ),
                  child: Text(name),
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

  void _updateAcState() {
    setState(() => widget._acFlag = !widget._acFlag);
    box.write(keyAcFlag, widget._acFlag);
  }

  void _updateKidsPlayingState() {
    setState(() => widget._kidsFlag = !widget._kidsFlag);
    box.write(keyKidsFlag, widget._kidsFlag);
  }

  void _updateDogState() {
    setState(() => widget._dogFlag = !widget._dogFlag);
    box.write(keyDogBarkFlag, widget._dogFlag);
  }

  //TODO: Implement Other Sounds
  /* [] change according to other sound
  void _update[SoundName]() {
    setState(() => widget.[_soundFlag] = !widget.[_soundFlag]);
    box.write([soundKey], widget.[_soundFlag]);
  }
  */

  void checkAllState() {
    Map<String, bool> _allState = {
      keyAcFlag: widget._acFlag,
      keyKidsFlag: widget._kidsFlag,
      keyDogBarkFlag: widget._dogFlag,
      //TODO: Add other Sound flag
    };

    List<String> _currentState = [];
    _allState.forEach((i, v) {
      if (v) _currentState.add(i);
    });

    setState(() => widget._selectedSounds = _currentState);
  }

  @override
  Widget build(BuildContext context) {
    checkAllState();
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(5),
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
            Container(
              margin: const EdgeInsets.only(top: 5),
              height: 340,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: LimitedBox(
                maxHeight: 300, //最大の高さを指定
                child: ListView.builder(
                  itemCount: 5,
                  //TODO: Set to 1 , currently set as 5 to show scroll feature
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 10.0,
                            children: [
                              card(
                                "AC",
                                widget._acFlag,
                                Colors.lightBlue.shade100,
                                Colors.lightBlue,
                                _updateAcState,
                              ),
                              card(
                                  "KidsPlaying",
                                  widget._kidsFlag,
                                  Colors.lightBlue.shade100,
                                  Colors.lightBlue,
                                  _updateKidsPlayingState),
                              card(
                                "Dog Bark",
                                widget._dogFlag,
                                Colors.yellow.shade200,
                                Colors.orange,
                                _updateDogState,
                              )
                              //TODO: Implement Other Sounds
                              /*
                              card(
                                [Sound Name],
                                widget.[Sound Flag],
                                [Sound light Color],
                                [Sound bold Color],
                                [Sound flag update Function],
                              )
                              */
                            ],
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
