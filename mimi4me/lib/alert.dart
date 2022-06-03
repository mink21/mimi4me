import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings.dart';

AlertPage alertPageMain = AlertPage();

// ignore: must_be_immutable
class AlertPage extends StatefulWidget {
  AlertPage({Key? key}) : super(key: key);

  String cause = "None";

  void updateCause(String val) => cause = val;
  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  void parseUri(String method, String val) {
    switch (method) {
      case 'call':
        _launchCaller('tel:$val');
        break;
      case 'browse':
        _launchCaller('https:$val');
        break;
    }
  }

  void _launchCaller(String val) async {
    final Uri url = Uri.parse(val);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ALERT WINDOW"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ARE YOU SAFE?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 50,
                fontWeight: FontWeight.w900,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/'),
                    child: const Text(
                      "YES - Go Back to App",
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                ),
                const Text(
                  "When not",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () =>
                            parseUri('call', settingPageMain.emergencyPolice),
                        child: const Text(
                          "Call Police",
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () =>
                            parseUri('call', settingPageMain.emergencyFirstAid),
                        child: const Text(
                          "Call Ambulance",
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () => parseUri('call', '110'),
                        child: const Text(
                          "Call name",
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 20),
              child: Text(
                "CAUSE: ${widget.cause}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
