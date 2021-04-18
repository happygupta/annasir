import 'dart:async';
import 'dart:convert';

import 'package:annasir/ads.dart';
import 'package:annasir/paper/scorboardstop.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/splash/loader.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service.dart';

class TestScreenNonStop extends StatefulWidget {
  final int paper;
  final String time;
  TestScreenNonStop(this.paper, this.time);
  @override
  _TestScreenNonStopState createState() => _TestScreenNonStopState();
}

class _TestScreenNonStopState extends State<TestScreenNonStop>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Widget _currentAd = SizedBox(
    width: 0.0,
    height: 0.0,
  );
  int yy = 0;
  AnimationController controller;
  bool isLoading = true, isStop = false, tim = false, check = false;
  List data, data2;
  String title, negative, member;
  var coco = List(150);
  int question = 0, selectedRadio, mnt, dia = 0, timerValue = 0, endPaper;
  int correctAns = 0, wrongAns = 0, notVisited = 0, skipped = 0, studID;
  var totalScore;

  isSelected(item) {}
  void initState() {
    super.initState();
    Screen.keepOn(true);
    loadFirst();
    FacebookAudienceNetwork.init(testingId: testID);
    _showBannerAd();
    WidgetsBinding.instance.addObserver(this);
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future _showNotificationWithSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        playSound: true, importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "onday");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'AnnaSir Warning!!',
      'Do not switch to other application.',
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  _showBannerAd() {
    setState(() {
      _currentAd = FacebookNativeAd(
        placementId: nativeBannerID,
        adType: NativeAdType.NATIVE_BANNER_AD,
        bannerAdSize: NativeBannerAdSize.HEIGHT_50,
        width: double.infinity,
        height: 51,
        backgroundColor: Colors.white,
        titleColor: Colors.black,
        descriptionColor: Colors.black,
        buttonColor: Color(0xfff83600),
        buttonTitleColor: Colors.black,
        buttonBorderColor: Colors.black,
        listener: (result, value) {
          print("Native Banner Ad: $result --> $value");
          if (NativeAdResult.ERROR == result) {
            _showBannerAd();
          }
        },
      );
    });
  }

  closeTimer() {
    if (dia == 1 || dia == 2) {
      Timer.periodic(Duration(seconds: 30), (timer) {
        if (tim) {
          setState(() {
            timer.cancel();
            finalSubmit();
          });
        } else {
          timer.cancel();
        }
      });
    } else {
      setState(() {
        finalSubmit();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        dia++;
        tim = true;
        closeTimer();
        _showNotificationWithSound();
        break;
      case AppLifecycleState.resumed:
        tim = dia == 1 || dia == 2 ? false : true;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        print('stop');
        finalSubmit();
        break;
    }
  }

  @override
  void dispose() {
    Screen.keepOn(false);
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  Future<void> loadFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    member = prefs.getString('member');
    studID = prefs.getInt('studid');
    title = prefs.getString('title');
    negative = prefs.getString('negative');
    mnt = prefs.getInt(widget.paper.toString() + 'time' + studID.toString());
    endPaper =
        prefs.getInt(widget.paper.toString() + 'endpaper' + studID.toString());
    if (mnt == null) {
      mnt = int.parse(widget.time) * 60;
    }
    if (endPaper == null) {
      endPaper = 0;
    }
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: mnt),
    );
    paperTime();
    start();
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
  }

  paperTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerValue == 0) {
        if (mnt != 0) {
          prefs.setInt(
              widget.paper.toString() + 'time' + studID.toString(), --mnt);
          prefs.setInt(widget.paper.toString() + 'endpaper' + studID.toString(),
              ++endPaper);
          yy++;
          if (yy == 50) {
            _showBannerAd();
            yy = 0;
          }
        } else {
          timer.cancel();
        }
      }
    });
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    member = prefs.getString('member');
    studID = prefs.getInt('studid');
    title = prefs.getString('title');
    negative = prefs.getString('negative');
    var response2 = await http.post(Uri.encodeFull(showPaperDetails), body: {
      "paper_code": widget.paper.toString(),
    });
    var resBody2 = json.decode(response2.body);
    data2 = resBody2['data'];
    data = data2..shuffle();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> finalSubmit() async {
    if (check == false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < data.length; i++) {
        int ans = prefs.getInt(
            widget.paper.toString() + 'ans' + data[i]['Q_id'].toString());
        int crctAns = data[i]['correct_ans'];
        if (ans == crctAns) {
          correctAns += 1;
        } else if (ans == 0) {
          skipped += 1;
        } else if (ans == null) {
          notVisited += 1;
        } else {
          wrongAns += 1;
        }
      }
      if (negative == 'Y') {
        totalScore = (correctAns * 1) - (wrongAns * 0.33);
        totalScore += 0.001;
      } else {
        totalScore = (correctAns * 1);
        totalScore += 0.001;
      }
      check = true;
      try {
        double doll = (endPaper / 60);
        int dolly = doll.toInt();
        String baad = (endPaper - dolly * 60).toString();
        String dol = (dolly.toString() + ":" + baad);
        var response = await http.post(Uri.encodeFull(addResult), body: {
          "paper_code": widget.paper.toString(),
          "stud_id": studID.toString(),
          "marks": totalScore.toStringAsFixed(3),
          "correct": correctAns.toStringAsFixed(1),
          "wrong": wrongAns.toStringAsFixed(1),
          "notvisit": notVisited.toStringAsFixed(1),
          "skip": skipped.toStringAsFixed(1),
          "time": dol,
        });
        dispose();
        mnt = 0;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnalysisStop(widget.paper)),
        );
      } catch (e) {
        setState(() {
          correctAns = 0;
          wrongAns = 0;
          notVisited = 0;
          skipped = 0;
          totalScore = 0;
          isLoading = false;
          check = false;
        });
        Fluttertoast.showToast(msg: 'Check your internet connection!! & Retry');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: isLoading
          ? Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: ColorLoader()),
            )
          : controller.value == 0.0
              ? Scaffold(
                  backgroundColor: Colors.white,
                  body: Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            member == 'N'
                                ? _currentAd
                                : Container(
                                    height: 0,
                                    width: 0,
                                  ),
                            Text(
                              '"Great!! You have completed your exam." \n\n  Press final submit button. ',
                              style: TextStyle(
                                color: Color(0xfff83600),
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.textMultiplier * 3.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            MaterialButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                  finalSubmit();
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.red)),
                              minWidth: double.infinity,
                              height: 50,
                              child: Text(
                                'Final Submit'.toUpperCase(),
                              ),
                              color: Colors.white,
                              textColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : isStop
                  ? Scaffold(
                      backgroundColor: Colors.deepOrangeAccent,
                      body: Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Continue Your Exam...',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConfig.textMultiplier * 3.8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      isStop = false;
                                      controller.reverse(
                                          from: controller.value == 0.0
                                              ? 1.0
                                              : controller.value);
                                    });
                                  },
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    size: SizeConfig.textMultiplier * 12,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Scaffold(
                      appBar: AppBar(
                        backgroundColor: Color(0xfff83600),
                        title: Text(title),
                        actions: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(12),
                              child: Text("\u{1F9D0}"))
                        ],
                      ),
                      drawer: Drawer(
                          child: Container(
                        padding: EdgeInsets.all(6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      'Answered',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 2),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      'Not Answered',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 2),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Colors.blueAccent,
                                    ),
                                    Text(
                                      'Marked',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 2),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Not Visited',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 2),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              height: SizeConfig.heightMultiplier * 68,
                              child: GridView.count(
                                crossAxisCount: 6,
                                children: List.generate(data.length, (index) {
                                  return InkWell(
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          color: coco[index] == 1
                                              ? Colors.blueAccent
                                              : coco[index] == 2
                                                  ? Colors.red
                                                  : coco[index] == 3
                                                      ? Colors.green
                                                      : Colors.grey),
                                      child: Center(
                                        child: Text((index + 1).toString()),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        question = index;
                                        checkSave(index);
                                        Navigator.of(context).pop();
                                      });
                                    },
                                  );
                                }),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                setState(() {
                                  controller.stop();
                                  controller.value = 0.0;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.red)),
                              minWidth: double.infinity,
                              height: 50,
                              child: Text(
                                'Final Submit'.toUpperCase(),
                              ),
                              color: Colors.white,
                              textColor: Colors.red,
                            ),
                          ],
                        ),
                      )),
                      body: AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) {
                          return Container(
                            padding: EdgeInsets.only(
                                left: 6, top: 4, right: 6, bottom: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      width: controller.value *
                                          SizeConfig.widthMultiplier *
                                          100,
                                      height: SizeConfig.heightMultiplier * 4,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          gradient: LinearGradient(colors: [
                                            Colors.green,
                                            Colors.yellow,
                                            Colors.red
                                          ])),
                                    ),
                                    Container(
                                      height: SizeConfig.heightMultiplier * 3,
                                      child: Center(
                                        child: Text(
                                          timerString,
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier * 3,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: SizeConfig.heightMultiplier * 65,
                                  child: ListView(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Text(
                                          (question + 1).toString() + '.',
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.7),
                                        ),
                                        title: Text(
                                          data[question]['ques'],
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.7),
                                        ),
                                        subtitle: Image.network(
                                            data[question]['img']),
                                      ),
                                      Divider(),
                                      RadioListTile(
                                        value: 1,
                                        groupValue: selectedRadio,
                                        title: Text(
                                          data[question]['opt_a'],
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.3),
                                        ),
                                        onChanged: (val) {
                                          setSelectedRadio(val);
                                        },
                                      ),
                                      Divider(),
                                      RadioListTile(
                                        value: 2,
                                        groupValue: selectedRadio,
                                        title: Text(
                                          data[question]['opt_b'],
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.3),
                                        ),
                                        onChanged: (val) {
                                          setSelectedRadio(val);
                                        },
                                      ),
                                      Divider(),
                                      RadioListTile(
                                        value: 3,
                                        groupValue: selectedRadio,
                                        title: Text(
                                          data[question]['opt_c'],
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.3),
                                        ),
                                        onChanged: (val) {
                                          setSelectedRadio(val);
                                        },
                                      ),
                                      Divider(),
                                      RadioListTile(
                                        value: 4,
                                        groupValue: selectedRadio,
                                        title: Text(
                                          data[question]['opt_d'],
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.3),
                                        ),
                                        onChanged: (val) {
                                          setSelectedRadio(val);
                                        },
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    MaterialButton(
                                      onPressed: () {
                                        setSelectedRadio(null);
                                        clearResponse();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(18.0),
                                          side: BorderSide(color: Colors.red)),
                                      height: SizeConfig.heightMultiplier * 5,
                                      child: Text(
                                        'Clear',
                                      ),
                                      color: Colors.white,
                                      textColor: Colors.red,
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        color(1);
                                        saveAns();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(18.0),
                                          side: BorderSide(color: Colors.red)),
                                      height: SizeConfig.heightMultiplier * 5,
                                      child: Text(
                                        'Mark & next',
                                      ),
                                      color: Colors.white,
                                      textColor: Colors.red,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.widthMultiplier * 3,
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        color(2);
                                        saveAns();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(18.0),
                                          side: BorderSide(color: Colors.red)),
                                      height: SizeConfig.heightMultiplier * 5,
                                      child: Text(
                                        'Save & next',
                                      ),
                                      color: Colors.red,
                                      textColor: Colors.white,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.heightMultiplier,
                                ),
                                member == 'N'
                                    ? _currentAd
                                    : Container(
                                        height: 0,
                                        width: 0,
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  clearResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        widget.paper.toString() + 'ans' + data[question]['Q_id'].toString(),
        selectedRadio);
  }

  color(val) {
    print(selectedRadio);
    if (val == 1) {
      setState(() {
        coco[question] = 1;
      });
    }
    if (val == 2) {
      setState(() {
        if (selectedRadio == null) {
          coco[question] = 2;
        } else {
          coco[question] = 3;
        }
      });
    }
  }

  saveAns() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        widget.paper.toString() + 'ans' + data[question]['Q_id'].toString(),
        selectedRadio == null ? 0 : selectedRadio);
    setState(() {
      if (question != data.length - 1) {
        question += 1;
      } else {
        question = 0;
      }

      checkSave(question);
    });
  }

  checkSave(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int check;
    try {
      check = prefs.getInt(
          widget.paper.toString() + 'ans' + data[value]['Q_id'].toString());
    } catch (e) {
      print(e);
    }
    if (check != 0) {
      setSelectedRadio(check);
    } else {
      setSelectedRadio(0);
    }
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          backgroundColor: Colors.yellow,
          title: Text("Warning !!"),
          content: Text(
              "Do not switch to other application otherwise your exam will be auto-submitted within 30 seconds."),
          actions: <Widget>[
            Icon(
              Icons.warning,
              size: 34,
              color: Colors.red,
            )
          ],
        );
      },
    );
  }
}
