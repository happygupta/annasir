import 'dart:async';

import 'package:annasir/ads.dart';
import 'package:annasir/screen.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySettingsPage extends StatefulWidget {
  MySettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  String member;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    load();
  }

  Future<void> load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      member = pref.getString('member');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xfff83600),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.notifications,
                        size: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      Text(
                        "Notifications",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  CrazySwitch(),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Divider(color: Colors.grey),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.lightbulb_outline,
                        size: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      Text(
                        "Night Mode",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  CrazySwitch(),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Divider(color: Colors.grey),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.smartphone,
                        size: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      Text(
                        "Stay Awake",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  CrazySwitch(),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Divider(color: Colors.grey),
              SizedBox(
                height: 50,
              ),
              member == 'N'
                  ? Container(
                      alignment: Alignment(0.5, 1),
                      child: FacebookNativeAd(
                        placementId: nativeFullID,
                        adType: NativeAdType.NATIVE_AD,
                        width: double.infinity,
                        height: SizeConfig.heightMultiplier * 50,
                        backgroundColor: Colors.white,
                        titleColor: Colors.black,
                        descriptionColor: Colors.grey,
                        buttonColor: Color(0xfff83600),
                        buttonTitleColor: Colors.white,
                        buttonBorderColor: Colors.black,
                        listener: (result, value) {
                          print("Native Ad: $result --> $value");
                        },
                      ))
                  : Container(
                      height: 0,
                      width: 0,
                    ),
            ],
          ),
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}

class CrazySwitch extends StatefulWidget {
  @override
  _CrazySwitchState createState() => _CrazySwitchState();
}

class _CrazySwitchState extends State<CrazySwitch>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  bool _condition = true;
  Duration _duration = Duration(milliseconds: 370);
  Animation<Alignment> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: _duration);

    _animation =
        AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerRight)
            .animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Curves.bounceOut,
          reverseCurve: Curves.bounceIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _condition
              ? () {
                  setState(() => _condition = false);
                  Timer(Duration(milliseconds: 500),
                      () => setState(() => _condition = true));
                  {
                    if (_animationController.isCompleted) {
                      _animationController.reverse();
                    } else {
                      _animationController.forward();
                    }

                    isChecked = !isChecked;
                  }
                }
              : null,
          child: Container(
            width: 68,
            height: 30,
            padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
            decoration: BoxDecoration(
                color: isChecked ? Color(0xfff83600) : Colors.grey,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                      color: isChecked ? Color(0xfff83600) : Colors.grey,
                      blurRadius: 12,
                      offset: Offset(0, 8))
                ]),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: _animation.value,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
