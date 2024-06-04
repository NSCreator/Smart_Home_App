// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'HomePage/home_page.dart';
import 'auth/logIn_page.dart';
import 'functions.dart';
import 'message/messaging_page.dart';



Future<void> backgroundHandler(RemoteMessage message) async {
  handler(message);
}

Future<void> handler(RemoteMessage message) async {
  final notificationData = message.notification;
  if (notificationData != null) {
    await LocalNotifications.showSimpleNotification(
      title: notificationData.title ?? '',
      body: notificationData.body ?? '',
      payload: message.data.toString(),
    );
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();

  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  // if (initialNotification?.didNotificationLaunchApp == true) {
  //   // LocalNotifications.onClickNotification.stream.listen((event) {
  //   Future.delayed(Duration(seconds: 1), () {});
  // }
  // MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handler(message);
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null) {
        handler(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handler(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(
          textScaleFactor:
              data.textScaleFactor > 1.1 ? 1.1 : data.textScaleFactor),
      child: MaterialApp(
        title: 'NS Ideas',
        theme: ThemeData(
            useMaterial3: true,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            textTheme: GoogleFonts.muktaTextTheme(),
            splashFactory: NoSplash.splashFactory,
            scaffoldBackgroundColor: Color.fromARGB(255, 27, 32, 35)),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MyHomePage();
            } else {
              return LoginPage();
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();

    listenToNotifications();
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return dialog
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade900,
          title: Text('Update Available',
              style: TextStyle(
                color: Colors.white,
              )),
          content: Text(
              'A new update for this app is available on the Play Store. Please update to enjoy the latest features and improvements.',
              style: TextStyle(
                color: Colors.white70,
              )),
          actions: [
            TextButton(
              onPressed: () {
                launch(
                    'https://play.google.com/store/apps/details?id=com.nimmalasujith.esrkr');
              },
              child: Text('Open Play Store',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 20)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
            ),
          ],
        );
      },
    );
  }

  listenToNotifications() {
    print("Listening to notification");
    LocalNotifications.onClickNotification.stream.listen((payload) {
      print("Notification payload: $payload");
      var someData = jsonDecode(payload);
      if (someData['navigation'] == 'message') {

      } else if (someData['navigation'] == 'notification') {

      } else if (someData['navigation'] == 'all_orders') {

      }
      showToastText("Notification payload: $payload");
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

      return Scaffold(
        body: Stack(
          children: [
            <Widget>[
              HomePage()
            ][currentPageIndex],
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.blueGrey.shade900,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0,right: 5,top: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          bottomIcon(index: 0, text: 'Home', icon: Icons.home_filled),

                          bottomIcon(index: 4, text: 'Settings', icon: Icons.manage_accounts),
                        ],
                      ),
                    ),
                  ),
                ))
          ],
        ),
      );

  }
   bottomIcon({required int index,required String text,required IconData icon}){
    return InkWell(
      onTap: () {
        setState(() {
          currentPageIndex = index;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white54,
            size: 25,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white54,fontSize: 12),
          )
        ],
      ),
    );
  }

  int currentPageIndex = 0;
}
