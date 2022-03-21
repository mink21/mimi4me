import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key, required this.pannelColor, required this.title})
      : super(key: key);

  final Color pannelColor;
  final String title;

  String getTitle() {
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
          top: 320,
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
    ]);
  }
}

class SettingTab extends StatelessWidget {
  const SettingTab({Key? key, required this.pannelColor, required this.title})
      : super(key: key);

  final Color pannelColor;
  final String title;

  String getTitle() {
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text('これは$titleのページです'),
    ));
  }
}

class SearchTab extends StatelessWidget {
  const SearchTab({Key? key, required this.pannelColor, required this.title})
      : super(key: key);

  final Color pannelColor;
  final String title;

  String getTitle() {
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text('これは$titleのページです'),
    ));
  }
}
