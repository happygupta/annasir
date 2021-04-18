import 'dart:convert';

import 'package:annasir/ads.dart';
import 'package:annasir/paper/startpagenonstop.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/service.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CodeTest extends StatefulWidget {
  String code;
  CodeTest(this.code);
  @override
  _CodeTestState createState() => _CodeTestState();
}

class _CodeTestState extends State<CodeTest> {
  bool isTest = true;
  List data2;
  String name, title, stream, time, status, isLive, quest, member, negative;
  int paperCode;
  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    shoPaper();
  }

  Future<void> shoPaper() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      member = pref.getString('member');
    });
    var response2 = await http.post(Uri.encodeFull(showLatestPaper),
        body: {"is_active": "N", "code": widget.code});
    var resBody2 = json.decode(response2.body);
    data2 = resBody2['data'];
    if (data2.isNotEmpty) {
      setState(() {
        isTest = false;
        Fluttertoast.showToast(msg: 'Success..');
      });
    } else {
      setState(() {
        isTest = true;
        Fluttertoast.showToast(msg: 'Enter a Valid Code!!!');
      });
    }
  }

  Future<void> addPaper() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('paper' + paperCode.toString(), paperCode);
    prefs.setString('title', title);
    prefs.setString('stream', stream);
    prefs.setString('time', time);
    prefs.setString('status', status);
    prefs.setString('isLive', isLive);
    prefs.setString('quest', quest);
    prefs.setString('negative', negative);
    setState(() {
      Navigator.push(
          context, SlideRightRoute(page: StarTestPageNonStop(paperCode)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff83600),
        title: Text('Live Test'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Center(
            child: isTest
                ? CircularProgressIndicator()
                : InkWell(
                    onTap: () {
                      setState(() {
                        paperCode = data2[0]['paper_code'];
                        title = data2[0]['title'];
                        stream = data2[0]['stream'];
                        time = data2[0]['time'];
                        status = data2[0]['status'];
                        isLive = data2[0]['is_live'];
                        quest = data2[0]['quest'];
                        negative = data2[0]['negative_mark'];
                        addPaper();
                      });
                    },
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Material(
                            borderRadius: BorderRadius.circular(12),
                            shadowColor: Color(0xcc000000),
                            elevation: 7,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              color: Colors.white,
                              height: 140,
                              child: Row(
                                children: <Widget>[
                                  Expanded(flex: 3, child: Container()),
                                  Expanded(
                                      flex: 5,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              data2[0]['title'],
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data2[0]['stream'],
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 2,
                            ),
                            Container(
                              height: 160,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.45),
                                            blurRadius: 20,
                                            offset: Offset(10, 10))
                                      ],
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image:
                                              NetworkImage(data2[0]['image']))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(15),
                              color: data2[0]['is_live'] == 'Live'
                                  ? Colors.red
                                  : Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(data2[0]['is_live'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
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
                      print("Native Banner Ad: $result --> $value");
                      if (NativeAdResult.ERROR == result) {}
                    },
                  ),
                )
              : Container(
                  height: 10,
                  width: 0,
                ),
        ],
      ),
    );
  }
}
