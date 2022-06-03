// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:smart_select/smart_select.dart';
import 'package:get_storage/get_storage.dart';

SettingsPage settings = SettingsPage();

class SettingsPage extends StatefulWidget {
  int intervals = 4;
  List<String> sounds = ["1", "2", "3", "4"];
  SettingsPage({Key? key}) : super(key: key);

  int get intervalValue => intervals;
  List<String> get soundList => sounds;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String keyInterval = 'interval';
  String keySoundList = 'sounds';
  final box = GetStorage();
  void getInterval() {
    final val = box.read(keyInterval);
    widget.intervals = val ?? widget.intervals;
  }

  void getSound() {
    var val = box.read(keySoundList) ?? widget.soundList;
    widget.sounds = val.cast<String>() as List<String>;
  }

  @override
  void initState() {
    getInterval();
    getSound();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget noiseSelectMenu() {
    List<String> _sounds = ["1", "2", "3", "4"];
    return SmartSelect<String>.multiple(
      title: 'Sound Notifications',
      placeholder: 'Select Sound',
      value: widget.sounds,
      onChange: (state) {
        setState(() => widget.sounds = state.value);
        box.write(keySoundList, widget.sounds);
      },
      modalValidation: (value) =>
          (value.isEmpty) ? "Choose atleast one sound" : null,
      choiceItems:
          _sounds.map((v) => S2Choice<String>(value: v, title: v)).toList(),
    );
  }

  Widget intervalSelectMenu() {
    final List<int> _intervals = [2, 3, 4, 5, 6];
    return SmartSelect<int>.single(
      title: 'Interval Options',
      value: widget.intervals,
      onChange: (state) {
        setState(() => widget.intervals = state.value);
        box.write(keyInterval, widget.intervals);
      },
      choiceItems:
          _intervals.map((v) => S2Choice<int>(value: v, title: '$v')).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          noiseSelectMenu(),
          intervalSelectMenu(),
        ],
      ),
    );
  }
}
