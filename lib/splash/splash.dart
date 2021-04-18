import 'dart:async';

import 'package:annasir/home/home.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/splash/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  String mobNo;

  @override
  initState() {
    super.initState();
    fireBase();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    route();
  }

  fireBase() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(
                message['notification']['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                message['notification']['body'],
                style: TextStyle(fontSize: 18),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  Future<Timer> loadData() async {
    return Timer(Duration(seconds: 4), onDone);
  }

  onDone() async {
    mobNo == null
        ? Navigator.push(
            context,
            PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 1400),
                pageBuilder: (_, __, ___) => Login()))
        : Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
  }

  Future<void> route() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobNo = prefs.getString('mobno');
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Color(0xfff83600),
                gradient: LinearGradient(colors: [
                  Color(0xfff83600),
                  Color(0xfffe8c00),
                  Color(0xfff83600)
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          Container(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                    tag: "spls",
                    child: Image.asset(
                      'assets/anna.png',
                      height: SizeConfig.heightMultiplier * 55,
                      width: SizeConfig.widthMultiplier * 55,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
