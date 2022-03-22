import 'audio_recorder.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioRecorder(
            onStop: (path) {
              setState(() {
                print(path);
              });
            },
          ),
        ),
      ),
    );
  }
}
