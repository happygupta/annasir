import 'dart:async';
import 'dart:convert';

import 'package:annasir/ads.dart';
import 'package:annasir/home/home.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/splash/loader.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../service.dart';

class CheckScreen extends StatefulWidget {
  final int paper;
  CheckScreen(this.paper);
  @override
  _CheckScreenState createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  bool isLoading = true, isStop = false;
  List data;
  var tick = List();
  String title, member;
  int question = 0, selectedRadio;
  int studID, tt = 0, nxt = 0;
  var totalScore;
  bool isInterstitialAdLoaded = false;
  Widget _currentAd = SizedBox(
    width: 0.0,
    height: 0.0,
  );

  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    _loadInterstitialAd();
    start();
  }

  void _loadInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: interstitialID,
      listener: (result, value) {
        print("Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED) {
          setState(() {
            isInterstitialAdLoaded = true;
          });
        }
        if (result == InterstitialAdResult.DISMISSED &&
            value["invalidated"] == true) {
          setState(() {
            isInterstitialAdLoaded = false;
            _loadInterstitialAd();
          });
        }
        if (result == InterstitialAdResult.CLICKED) {}
      },
    );
  }

  _showInterstitialAd() {
    if (isInterstitialAdLoaded == true)
      FacebookInterstitialAd.showInterstitialAd();
  }

  _showBannerAd() {
    setState(() {
      _currentAd = FacebookNativeAd(
        placementId: nativeBannerID,
        adType: NativeAdType.NATIVE_BANNER_AD,
        bannerAdSize: NativeBannerAdSize.HEIGHT_100,
        height: 101,
        width: double.infinity,
        backgroundColor: Colors.white,
        titleColor: Colors.black,
        descriptionColor: Colors.black,
        buttonColor: Color(0xfff83600),
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.black,
        listener: (result, value) {
          print("Native Banner Ad: $result --> $value");
        },
      );
    });
  }

  Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    member = prefs.getString('member');
    studID = prefs.getInt('studid');
    title = prefs.getString('title');
    var response2 = await http.post(Uri.encodeFull(showPaperDetails), body: {
      "paper_code": widget.paper.toString(),
    });
    var resBody2 = json.decode(response2.body);
    data = resBody2['data'];
    _showInterstitialAd();
    end();
  }

  Future<void> end() async {
    _showBannerAd();
    try {
      for (int i = 0; i < data.length; i++) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int ans = prefs.getInt(
            widget.paper.toString() + 'ans' + data[i]['Q_id'].toString());
        tick.add(ans);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Your data Unavailable!!');
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
            appBar: AppBar(
              backgroundColor: Color(0xfff83600),
              title: Text(title + ' Solution'),
              centerTitle: true,
            ),
            body: Container(
              padding: EdgeInsets.only(left: 6, top: 4, right: 6, bottom: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: SizeConfig.heightMultiplier * 68,
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            (question + 1).toString() + '.',
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.7),
                          ),
                          title: Text(
                            data[question]['ques'],
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.7),
                          ),
                          subtitle: Image.network(data[question]['img']),
                        ),
                        Divider(),
                        RadioListTile(
                          value: 1,
                          groupValue: selectedRadio = tick[question],
                          title: Text(
                            data[question]['opt_a'],
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.3),
                          ),
                          activeColor:
                              data[question]['correct_ans'] == tick[question]
                                  ? Colors.green
                                  : Colors.red,
                          selected: tick[question] == 1 ? true : false,
                          onChanged: (val) {},
                          secondary: data[question]['correct_ans'] == 1
                              ? Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: SizeConfig.textMultiplier * 4,
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                        ),
                        Divider(),
                        RadioListTile(
                          value: 2,
                          groupValue: selectedRadio = tick[question],
                          title: Text(
                            data[question]['opt_b'],
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.3),
                          ),
                          activeColor:
                              data[question]['correct_ans'] == tick[question]
                                  ? Colors.green
                                  : Colors.red,
                          selected: tick[question] == 2 ? true : false,
                          onChanged: (val) {},
                          secondary: data[question]['correct_ans'] == 2
                              ? Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: SizeConfig.textMultiplier * 4,
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                        ),
                        Divider(),
                        RadioListTile(
                          value: 3,
                          groupValue: selectedRadio = tick[question],
                          title: Text(
                            data[question]['opt_c'],
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.3),
                          ),
                          activeColor:
                              data[question]['correct_ans'] == tick[question]
                                  ? Colors.green
                                  : Colors.red,
                          selected: tick[question] == 3 ? true : false,
                          onChanged: (val) {},
                          secondary: data[question]['correct_ans'] == 3
                              ? Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: SizeConfig.textMultiplier * 4,
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                        ),
                        Divider(),
                        RadioListTile(
                          value: 4,
                          groupValue: selectedRadio = tick[question],
                          title: Text(
                            data[question]['opt_d'],
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.3),
                          ),
                          activeColor:
                              data[question]['correct_ans'] == tick[question]
                                  ? Colors.green
                                  : Colors.red,
                          selected: tick[question] == 4 ? true : false,
                          onChanged: (val) {},
                          secondary: data[question]['correct_ans'] == 4
                              ? Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: SizeConfig.textMultiplier * 4,
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          clearResponse();
                          if (isInterstitialAdLoaded == false) {
                            _loadInterstitialAd();
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)),
                        height: SizeConfig.heightMultiplier * 5,
                        child: Text(
                          'Previous',
                        ),
                        color: Colors.white,
                        textColor: Colors.red,
                      ),
                      MaterialButton(
                        onPressed: () {
                          _showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)),
                        height: SizeConfig.heightMultiplier * 5,
                        child: Text(
                          'Go Home',
                        ),
                        color: Colors.red,
                        textColor: Colors.white,
                      ),
                      MaterialButton(
                        onPressed: () {
                          saveAns();
                          if (isInterstitialAdLoaded == false) {
                            _loadInterstitialAd();
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)),
                        height: SizeConfig.heightMultiplier * 5,
                        child: Text(
                          'Next',
                        ),
                        color: Colors.white,
                        textColor: Colors.red,
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
            ),
          );
  }

  clearResponse() async {
    setState(() {
      if (question != 0) {
        question -= 1;
      } else {
        question = data.length - 1;
      }
    });
  }

  saveAns() async {
    setState(() {
      if (question != data.length - 1) {
        question += 1;
      } else {
        question = 0;
      }
    });
  }
}
