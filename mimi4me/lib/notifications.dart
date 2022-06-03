import 'package:flutter/material.dart';

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
          Icons.upcoming,
          Colors.amber,
          _notificationsItem[index],
          _notificationsLevel[index],
          _notificationsDate[index],
        ),
      ),
    );
  }

  Widget card(
      IconData icon, Color color, String itemName, int itemLevel, String date) {
    String duration = "-";
    if (date != "") {
      final durationTime = DateTime.now().difference(DateTime.parse(date));
      print(durationTime.inHours);
      if (durationTime.inMinutes.toDouble() <= 0) {
        duration = "${durationTime.inSeconds}s";
      } else if (durationTime.inHours.toDouble() <= 0) {
        duration = "${durationTime.inMinutes}m";
      } else if (durationTime.inDays.toDouble() <= 0) {
        duration = "${durationTime.inHours}h";
      } else {
        duration = "${durationTime.inDays}d";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Icon(icon, color: color),
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
                        color: color,
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
    return SafeArea(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: () {
                widget.deleteAllNotifications();
                setState(() {
                  _notificationsItem.clear();
                  _notificationsLevel.clear();
                  _notificationsDate.clear();
                });
              },
              child: const Text("clear"),
            ),
          ),
          Container(
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
                  height: MediaQuery.of(context).size.height - 140, //最大の高さを指定,
                  margin: const EdgeInsets.only(top: 5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: LimitedBox(
                    //maxHeight: MediaQuery.of(context).size.height - 200, //最大の高さを指定
                    child: ListView.builder(
                      itemCount: 1,
                      //TODO: Set to 1 , currently set as 5 to show scroll feature
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
    );
  }
}
