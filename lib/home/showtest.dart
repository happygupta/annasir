import 'dart:convert';

import 'package:annasir/ads.dart';
import 'package:annasir/paper/startpage.dart';
import 'package:annasir/splash/loader.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screen.dart';
import '../service.dart';

class ShowTest extends StatefulWidget {
  String type;
  ShowTest(this.type);
  @override
  _ShowTestState createState() => _ShowTestState();
}

class _ShowTestState extends State<ShowTest> {
  List data2, data3;
  bool isTest = true;
  PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.8,
  );
  String name,
      title,
      stream,
      time,
      status,
      isLive,
      quest,
      member,
      startDate,
      endDate,
      negative;
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
    var response2 = await http.post(Uri.encodeFull(showPaperType),
        body: {"is_active": "Y", "status": "Free", "cat": widget.type});
    var resBody2 = json.decode(response2.body);
    data2 = resBody2['data'];
    response2 = await http.post(Uri.encodeFull(showPaperType),
        body: {"is_active": "Y", "status": "Paid", "cat": widget.type});
    resBody2 = json.decode(response2.body);
    data3 = resBody2['data'];
    if (data2.isNotEmpty || data3.isNotEmpty) {
      setState(() {
        isTest = false;
        Fluttertoast.showToast(msg: 'Success..');
      });
    } else {
      setState(() {
        isTest = false;
        Fluttertoast.showToast(msg: 'No Test Available!!');
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
      Navigator.push(context, SlideRightRoute(page: StarTestPage(paperCode)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40,
                  child: InkWell(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 30,
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Text("Tests",
                    style: TextStyle(fontSize: 24, color: Colors.black)),
                Icon(
                  Icons.shutter_speed,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Free Tests",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            SizedBox(height: 10),
            isTest
                ? Center(child: ColorLoader())
                : Container(
                    height: SizeConfig.heightMultiplier * 19,
                    child: PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      pageSnapping: true,
                      itemCount: data2.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              paperCode = data2[index]['paper_code'];
                              title = data2[index]['title'];
                              stream = data2[index]['stream'];
                              time = data2[index]['time'];
                              status = data2[index]['status'];
                              isLive = data2[index]['is_live'];
                              quest = data2[index]['quest'];
                              negative = data2[index]['negative_mark'];
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
                                                    data2[index]['title'],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    data2[index]['stream'],
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
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.45),
                                                  blurRadius: 20,
                                                  offset: Offset(10, 10))
                                            ],
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    data2[index]['image']))),
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
                                    color: data2[index]['is_live'] == 'Live'
                                        ? Colors.red
                                        : Colors.blue,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(data2[index]['is_live'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 5),
            SizedBox(height: 5),
            Text(
              "Paid Tests",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            isTest
                ? Center(child: ColorLoader())
                : Container(
                    height: SizeConfig.heightMultiplier * 48,
                    child: ListView.builder(
                        itemCount: data3.length + 1,
                        itemBuilder: (context, index) {
                          return index < data3.length
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      paperCode = data3[index]['paper_code'];
                                      title = data3[index]['title'];
                                      stream = data3[index]['stream'];
                                      time = data3[index]['time'];
                                      status = data3[index]['status'];
                                      isLive = data3[index]['is_live'];
                                      quest = data3[index]['quest'];
                                      negative = data3[index]['negative_mark'];
                                      addPaper();
                                    });
                                  },
                                  child: Stack(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 10),
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          shadowColor: Color(0xcc000000),
                                          elevation: 7,
                                          child: Container(
                                            margin: EdgeInsets.all(5),
                                            color: Colors.white,
                                            height: 140,
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                    flex: 3,
                                                    child: Container()),
                                                Expanded(
                                                    flex: 5,
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            data3[index]
                                                                ['title'],
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            data3[index]
                                                                ['stream'],
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 18,
                                          ),
                                          Container(
                                            height: 160,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                height: 90,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.45),
                                                          blurRadius: 20,
                                                          offset:
                                                              Offset(10, 10))
                                                    ],
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            data3[index]
                                                                ['image']))),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.all(15),
                                            color: data3[index]['is_live'] !=
                                                    'Live'
                                                ? Colors.blue
                                                : Colors.red,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                  data3[index]['is_live'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                );
                        })),
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
                      descriptionColor: Colors.black,
                      buttonColor: Color(0xfff83600),
                      buttonTitleColor: Colors.black,
                      buttonBorderColor: Colors.black,
                      listener: (result, value) {
                        print("Native Banner Ad: $result --> $value");
                        if (NativeAdResult.ERROR == result) {}
                      },
                    ),
                  )
                : Container(
                    height: 0,
                    width: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
