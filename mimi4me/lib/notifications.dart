import 'package:flutter/material.dart';
import 'package:mimi4me/noise_detector.dart';

import 'settings.dart';

NotificationPage notificationPageMain = NotificationPage();

String keyNotifItem = 'notifItem';
String keyNotifLevel = 'notifLevel';
String keyNotifDate = 'notifDate';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key? key}) : super(key: key);
  final List<String> _notificationsItem =
      (box.read(keyNotifItem) ?? []).cast<String>() as List<String>;
  final List<int> _notificationsLevel =
      (box.read(keyNotifLevel) ?? []).cast<int>() as List<int>;
  final List<String> _notificationsDate =
      (box.read(keyNotifDate) ?? []).cast<String>() as List<String>;

  List<String> get notificationsItem => _notificationsItem;
  List<int> get notificationsLevel => _notificationsLevel;
  List<String> get notificationsDate => _notificationsDate;

  void addNotifications(String item, int level, String date) {
    notificationPageMain._notificationsItem.add(item);
    notificationPageMain._notificationsLevel.add(level);
    notificationPageMain._notificationsDate.add(date);

    box.write(keyNotifItem, _notificationsItem);
    box.write(keyNotifLevel, _notificationsLevel);
    box.write(keyNotifDate, _notificationsDate);
  }

  void deleteAllNotifications() {
    _notificationsItem.clear();
    _notificationsLevel.clear();
    _notificationsDate.clear();

    box.remove(keyNotifItem);
    box.remove(keyNotifLevel);
    box.remove(keyNotifDate);
  }

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> _notificationsItem = [];
  List<int> _notificationsLevel = [];
  List<String> _notificationsDate = [];

  @override
  void initState() {
    _notificationsItem = widget.notificationsItem;
    _notificationsLevel = widget.notificationsLevel;
    _notificationsDate = widget.notificationsDate;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget allCard() {
    return Column(
      children: List.generate(
        _notificationsItem.length,
        (int index) => card(
          _notificationsItem[_notificationsItem.length - index - 1],
          _notificationsLevel[_notificationsItem.length - index - 1],
          _notificationsDate[_notificationsItem.length - index - 1],
        ),
      ),
    );
  }

  String getDuration(String date) {
    final durationTime = DateTime.now().difference(DateTime.parse(date));
    if (durationTime.inMinutes.toDouble() <= 0) {
      return "${durationTime.inSeconds}s";
    } else if (durationTime.inHours.toDouble() <= 0) {
      return "${durationTime.inMinutes}m";
    } else if (durationTime.inDays.toDouble() <= 0) {
      return "${durationTime.inHours}h";
    } else {
      return "${durationTime.inDays}d";
    }
  }

  Color getColor(int level) {
    if (level >= 100) {
      return Colors.red;
    } else if (level > 60) {
      return Colors.orange;
    } else if (level > 35) {
      return Colors.yellow;
    } else if (level > 30) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  IconData getIcon(String name) {
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
    return _totalNoise[name]!.icon;
  }

  Widget card(String itemName, int itemLevel, String date) {
    String duration = (date != "") ? getDuration(date) : "-";

    Color _color = getColor(itemLevel);

    IconData _icon = getIcon(itemName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Icon(_icon, color: _color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${itemLevel}db $duration",
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    const TextSpan(
                      text: "There was a ",
                    ),
                    TextSpan(
                      text: itemName,
                      style: TextStyle(
                        color: _color,
                      ),
                    ),
                    const TextSpan(
                      text: "!",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 35),
        child: Stack(
          children: [
            Container(
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
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 15),
                    child: const Text(
                      "Notifications",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 172,
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    child: LimitedBox(
                      child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return allCard();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
