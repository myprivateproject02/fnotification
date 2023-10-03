import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notification/services/notification_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home View'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermissions();
    notificationService.firebaseInit();
    notificationService.getDeviceToken().then((value) {
      print("Device token: $value");
    });
  }
}
