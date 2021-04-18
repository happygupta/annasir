import 'dart:async';
import 'dart:convert';

import 'package:annasir/ads.dart';
import 'package:annasir/paper/papernonstop.dart';
import 'package:annasir/paper/scorboardstop.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/service.dart';
import 'package:annasir/splash/loader.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StarTestPageNonStop extends StatefulWidget {
  final int paper;
  StarTestPageNonStop(this.paper);
  @override
  _StarTestPageNonStopState createState() => _StarTestPageNonStopState();
}

class _StarTestPageNonStopState extends State<StarTestPageNonStop> {
  int paperCode, studID;
  String title, stream, time, status, isLive, quest, member;
  bool isLoading = true, isTest = false;
  List data;

  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    start();
  }

  Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    paperCode = prefs.getInt('paper' + widget.paper.toString());
    studID = prefs.getInt('studid');
    title = prefs.getString('title');
    stream = prefs.getString('stream');
    time = prefs.getString('time');
    status = prefs.getString('status');
    isLive = prefs.getString('isLive');
    quest = prefs.getString('quest');
    member = prefs.getString('member');
    check();
  }

  Future<void> check() async {
    var response2 = await http.post(Uri.encodeFull(showUserResult), body: {
      "paper_code": widget.paper.toString(),
      "stud_id": studID.toString(),
    });
    var resBody2 = json.decode(response2.body);
    data = resBody2['data'];
    if (data.isNotEmpty) {
      setState(() {
        isTest = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: ColorLoader()),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Color(0xfff83600),
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text("Instruction"),
              centerTitle: true,
            ),
            body: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: SizeConfig.heightMultiplier * 10,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xfff83600), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(3.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            title + " Full Mock Test",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.textMultiplier * 2.6,
                                color: Color(0xfff83600)),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Duration : " + time + " mins",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConfig.textMultiplier * 1.8,
                                    color: Colors.grey),
                              ),
                              Text(
                                'Maximum Marks : ' + quest,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConfig.textMultiplier * 1.8,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: SizeConfig.heightMultiplier * 64,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                  "The test contain single section having " +
                                      quest +
                                      " questions.",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                    "Each question has 4 options out of which only one is correct.",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.15)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                    "You have to finish the test in " +
                                        time +
                                        " minutes.",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.15)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          member == 'N'
                              ? Container(
                                  alignment: Alignment(0.5, 1),
                                  child: FacebookNativeAd(
                                    placementId: nativeBannerID,
                                    adType: NativeAdType.NATIVE_BANNER_AD,
                                    bannerAdSize: NativeBannerAdSize.HEIGHT_50,
                                    width: double.infinity,
                                    height: 51,
                                    backgroundColor: Colors.white,
                                    titleColor: Colors.black,
                                    descriptionColor: Colors.grey,
                                    buttonColor: Colors.grey,
                                    buttonTitleColor: Colors.black,
                                    buttonBorderColor: Colors.black,
                                    listener: (result, value) {
                                      print(
                                          "Native Banner Ad: $result --> $value");
                                      if (NativeAdResult.ERROR == result) {}
                                    },
                                  ),
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                    "Try to guess the answer as there is no nagative marking.",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.15)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                    "You will be awarded 1 mark for each correct answer and 0 marks will be deducted for each wrong answer.",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.15)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                    "There is no penalty for the question that you have not attempted.",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.15)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                    "Once you start the test, you will not be allowed to reattempt it. Make sure that you complete the test before you submit the test.",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.15)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("• ",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.textMultiplier * 2.15)),
                              Expanded(
                                child: Text(
                                    "I have real all the instructions carefully and have understood them. I agree not to cheat or use unfair means in this examination. I understand that using unfair means of any sort of my own or someone else's advantage will lead to my immediate disqualification.",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.15)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: SizeConfig.heightMultiplier * 6,
                    child: isTest
                        ? RaisedButton(
                            onPressed: () {
                              if (isLive == 'Live') {
                                if (status == 'Paid') {
                                  if (member == 'Y') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AnalysisStop(widget.paper)),
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'You are not a Prime Member');
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AnalysisStop(widget.paper)),
                                  );
                                }
                              } else {
                                Fluttertoast.showToast(msg: 'Coming Soon!!');
                              }
                            },
                            color: Color(0xfff83600),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Check Score',
                                    style: TextStyle(
                                      fontSize: SizeConfig.textMultiplier * 2.6,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: SizeConfig.textMultiplier * 2.8,
                                  )
                                ],
                              ),
                            ),
                          )
                        : RaisedButton(
                            onPressed: () {
                              if (isLive == 'Live') {
                                if (status == 'Paid') {
                                  if (member == 'Y') {
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                            page: TestScreenNonStop(
                                                paperCode, time)));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'You are not a Prime Member');
                                  }
                                } else {
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                          page: TestScreenNonStop(
                                              paperCode, time)));
                                }
                              } else {
                                Fluttertoast.showToast(msg: 'Coming Soon!!');
                              }
                            },
                            color: Color(0xfff83600),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: SizeConfig.textMultiplier * 2.6,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: SizeConfig.textMultiplier * 2.8,
                                  )
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
  }
}
