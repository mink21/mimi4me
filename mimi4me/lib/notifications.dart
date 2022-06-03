import 'dart:async';
import 'package:flutter/material.dart';

NotificationPage notificationPageMain = const NotificationPage();

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 15),
        child: const Text(
          "Notifications",
        ),
      ),
    );
  }
}
