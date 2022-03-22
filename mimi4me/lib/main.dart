import 'package:flutter/material.dart';
import 'audio_recorder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Stack(children: [
        Align(
            alignment: Alignment.topCenter,
            child: Material(
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
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.green,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: '60',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 60)),
                            TextSpan(text: 'db'),
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
            ))),
        Positioned(
            top: 400,
            child: Container(
              padding: const EdgeInsets.only(left: 60.0, top: 30.0),
              child: RichText(
                softWrap: true,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.green,
                  ),
                  children: [
                    TextSpan(
                        text: 'Possible Cause\n',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    TextSpan(
                        text: 'Conversation\n',
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            fontSize: 30)),
                    TextSpan(
                        text: 'Background Music',
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            fontSize: 30)),
                  ],
                ),
              ),
            )),
        AudioRecorder(
          onStop: (path) {},
        )
      ]),
    );
  }
}
