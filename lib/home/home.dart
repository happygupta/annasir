import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:annasir/ads.dart';
import 'package:annasir/home/about.dart';
import 'package:annasir/home/codetest.dart';
import 'package:annasir/home/developer.dart';
import 'package:annasir/home/help.dart';
import 'package:annasir/home/hideads.dart';
import 'package:annasir/home/profile.dart';
import 'package:annasir/home/settings.dart';
import 'package:annasir/home/showtest.dart';
import 'package:annasir/paper/startpage.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/service.dart';
import 'package:annasir/splash/loader.dart';
import 'package:annasir/splash/loader3.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'file:///D:/FlutterProjects/annasir/lib/paper/video.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = true, isAds = true;
  bool isLoading = true, isTest = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.8,
  );
  final formKey = GlobalKey<FormState>();
  Razorpay razPay = Razorpay();
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;
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
  String version, _code, deviceID;
  var mobNo;
  List data, data2, data3, data4;
  int _currentPage = 0, f = 0, p = 0, paperCode;
  int selectPage = 2, studId, prize1, prize2, prize3;
  int totalAmount = 0;
  var formatter = new DateFormat('dd-MM-yyyy');
  var today = DateTime.now();
  var days = 0;

  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    start();
    slideView();
    razPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_live_TCPoMQ1oZwrYoW',
      'amount': totalAmount * 100,
      'name': 'ANNA SIR',
      'description': 'Get Prime Membership',
      'prefill': {
        'contact': mobNo,
        'email': name.replaceAll(new RegExp(r"\s+\b|\b\s"), "") + '@yopmail.com'
      },
    };
    try {
      razPay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    buyPrime();
    Fluttertoast.showToast(msg: 'SUCCESS' + response.paymentId);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: 'ERROR: ' + response.code.toString() + ' - ' + response.message);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: 'EXTERNAL WALLET' + response.walletName);
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

  openClose() {
    setState(() {
      if (isCollapsed)
        _controller.forward();
      else
        _controller.reverse();

      isCollapsed = !isCollapsed;
    });
  }

  slideView() {
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (selectPage == 2) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
      } else {
        timer.cancel();
      }

      pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobNo = prefs.getString('mobno');
    var response = await http.post(Uri.encodeFull(showUser), body: {
      "mob_no": mobNo,
    });
    var resBody = json.decode(response.body);
    data = resBody['data'];
    setState(() {
      name = data[0]['s_name'];
      studId = data[0]['stud_id'];
      member = data[0]['is_mem'];
      startDate = data[0]['start_date'];
      endDate = data[0]['end_date'];
      prefs.setString('s_name', name);
      prefs.setInt('studid', studId);
      prefs.setString('s_gender', data[0]['gender']);
      prefs.setString('s_dob', data[0]['dob']);
      prefs.setString('s_member', startDate);
      prefs.setString('e_member', endDate);
      prefs.setString('member', member);
      prefs.setString('coamember', data[0]['in_coa']);
    });
    var response2 = await http.post(Uri.encodeFull(showNotification), body: {});
    var resBody2 = json.decode(response2.body);
    data4 = resBody2['data'];
    prize1 = data4[0]['prize'];
    prize2 = data4[1]['prize'];
    prize3 = data4[2]['prize'];
    updateApp();
    showPaper();
  }

  Future<void> showPaper() async {
    var response2 = await http.post(Uri.encodeFull(showPaperType),
        body: {"is_active": "Y", "status": "Paid", "cat": "exam"});
    var resBody2 = json.decode(response2.body);
    data2 = resBody2['data'];
    setState(() {
      isTest = false;
      isLoading = false;
    });
  }

  Future<void> updateApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var response = await http.post(Uri.encodeFull(updateApplication), body: {});
    var resBody = json.decode(response.body);
    data = resBody['data'];
    version = packageInfo.version;
    setState(() {
      if (data[0]['update_id'] != version) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Update Available'),
                content: Text('New Update available of this Application'),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: Text('Cancel')),
                  FlatButton(
                      onPressed: () {
                        // ignore: unnecessary_statements
                        launchURL();
                        Navigator.pop(context, 'Update Now');
                      },
                      child: Text('Update Now'))
                ],
              );
            });
      }
    });
  }

  launchURL() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.annasir.annasir';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> buyPrime() async {
    setState(() {
      isLoading = true;
    });
    var response = await http.post(Uri.encodeFull(buyMembership), body: {
      "stud_id": studId.toString(),
      "start_date": formatter.format(today).toString(),
      "end_date": formatter.format(today.add(Duration(days: days))).toString(),
      "is_mem": 'Y',
    });
    start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    razPay.clear();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => exit(0),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: isLoading
          ? Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: ColorLoader()),
            )
          : Scaffold(
              resizeToAvoidBottomPadding: false,
              backgroundColor: Colors.white,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      child: Stack(
                        children: <Widget>[
                          menu(context),
                          selectPage == 2
                              ? dashboard(context)
                              : selectPage == 0
                                  ? test(context)
                                  : selectPage == 1
                                      ? prime(context)
                                      : selectPage == 3
                                          ? notification(context)
                                          : notes(context),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              isCollapsed
                                  ? isAds
                                      ? CurvedNavigationBar(
                                          backgroundColor: Colors.transparent,
                                          buttonBackgroundColor:
                                              Color(0xfffe8c00),
                                          color: Color(0xfff83600),
                                          height:
                                              SizeConfig.heightMultiplier * 7,
                                          items: <Widget>[
                                            Icon(
                                              Icons.computer,
                                              size: 26,
                                              color: Colors.black,
                                            ),
                                            Icon(
                                              Icons.bubble_chart,
                                              size: 26,
                                              color: Colors.black,
                                            ),
                                            Icon(
                                              Icons.home,
                                              size: 26,
                                              color: Colors.black,
                                            ),
                                            Icon(
                                              Icons.notifications_active,
                                              size: 26,
                                              color: Colors.black,
                                            ),
                                            Icon(
                                              Icons.filter_none,
                                              size: 26,
                                              color: Colors.black,
                                            ),
                                          ],
                                          animationDuration:
                                              Duration(milliseconds: 200),
                                          index: selectPage,
                                          animationCurve: Curves.bounceInOut,
                                          onTap: (index) {
                                            setState(() {
                                              selectPage = index;
                                              if (selectPage == 2) {
                                                slideView();
                                              }
                                              if (selectPage == 4) {
                                                isAds = false;
                                              }
                                            });
                                          },
                                        )
                                      : Container(
                                          height: 0,
                                          width: 0,
                                        )
                                  : Center(
                                      child: Text('Version ' +
                                          version +
                                          ', Copyright © By Anna Sir')),
                            ],
                          ),
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

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.widthMultiplier * 4,
              right: SizeConfig.widthMultiplier * 29),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ListView(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(context, SlideRightRoute(page: Profile()));
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.widthMultiplier * 2,
                            top: SizeConfig.heightMultiplier * 3),
                        child: CircleAvatar(
                          backgroundColor: Color(0xfff83600),
                          radius: SizeConfig.widthMultiplier * 11,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                size: SizeConfig.widthMultiplier * 19,
                                color: Colors.white,
                              ),
//                    Text("User")
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    name.toUpperCase(),
                    style: new TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xfff83600)),
                  ),
                  onTap: () {
                    Navigator.push(context, SlideRightRoute(page: Profile()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Color(0xfff83600),
                  ),
                  title: Text('Home'),
                  onTap: () {
                    setState(() {
                      openClose();
                      isAds = true;
                      selectPage = 2;
                    });
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.cancel,
                    color: Color(0xfff83600),
                  ),
                  title: Text('Hide Ads'),
                  onTap: () {
                    Navigator.push(context, SlideRightRoute(page: HideAds()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Color(0xfff83600),
                  ),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.push(
                        context, SlideRightRoute(page: MySettingsPage()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.sim_card_alert,
                    color: Color(0xfff83600),
                  ),
                  title: Text('About'),
                  onTap: () {
                    Navigator.push(context, SlideRightRoute(page: AboutPage()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.help,
                    color: Color(0xfff83600),
                  ),
                  title: Text('Help'),
                  onTap: () {
                    Navigator.push(context, SlideRightRoute(page: HelpPage()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.developer_mode,
                    color: Color(0xfff83600),
                  ),
                  title: Text('Developed By'),
                  onTap: () {
                    Navigator.push(
                        context, SlideRightRoute(page: DeveloperPage()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.share,
                    color: Color(0xfff83600),
                  ),
                  title: Text('Share App'),
                  onTap: () {
                    setState(() {
                      Share.share('Download Annasir Application ' +
                          'https://play.google.com/store/apps/details?id=com.annasir.annasir');
                    });
                  },
                ),
                Divider(),
                SizedBox(
                  height: 60,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboard(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        child: Container(
                            width: 40,
                            child: Icon(
                              Icons.menu,
                              color: Colors.black,
                              size: 30,
                            )),
                        onTap: () {
                          openClose();
                        },
                      ),
                      Text("Home",
                          style: TextStyle(fontSize: 24, color: Colors.black)),
                      InkWell(
                        onTap: () {
                          launchURL();
                        },
                        child: Icon(
                          Icons.system_update,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.heightMultiplier),
                  SizedBox(height: SizeConfig.heightMultiplier),
                  Container(
                    height: 205,
                    child: PageView(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      pageSnapping: true,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Image.network(
                            data4[0]['path'],
                            fit: BoxFit.contain,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: ColorLoader3());
                            },
                          ),
                          width: 100,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Image.network(
                            data4[1]['path'],
                            fit: BoxFit.contain,
                          ),
                          width: 100,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Image.network(
                            data4[2]['path'],
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: ColorLoader3());
                            },
                          ),
                          width: 100,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Welcome to Jyotirmay Coaching",
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "It’s so wonderful to see you all here in our Jyotrimay Coaching Classes Mobile Application(Anna Sir)."
                          " A small step taken from us towards your success so that you may get prepared for various competitive exams and hope that you also will happy with this step. "
                          "We wish for your best and bright future. Thank you..!!!",
                          style: TextStyle(
                              fontSize: SizeConfig.textMultiplier * 2.15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Upcoming Features" + ",(" + version + ")",
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  Text(
                      'There are some upcoming features that we will provide you in further updates. Such as.. ',
                      style: TextStyle(
                          fontSize: SizeConfig.textMultiplier * 2.15)),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("• ",
                          style: TextStyle(
                              fontSize: SizeConfig.textMultiplier * 2.15)),
                      Expanded(
                        child: Text(
                          "Competitive exam updates : It will help you in getting information about any exam.",
                          style: TextStyle(
                              fontSize: SizeConfig.textMultiplier * 2.15),
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
                              fontSize: SizeConfig.textMultiplier * 2.15)),
                      Expanded(
                        child: Text(
                            "Dark Mode : It reduce eye strain and improve battery life.",
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.15)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 2,
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget prime(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 34,
                        ),
                        onTap: () {
                          openClose();
                        },
                      ),
                      Text("Prime Member",
                          style: TextStyle(fontSize: 24, color: Colors.black)),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Image.network(
                              'https://hemantgupta.tech/siranna/ic.png'),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Anna Sir\nJyotirmay Coaching Classes',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          member == 'Y'
                              ? Text(
                                  'Congratulation you are a Prime Member',
                                  style: TextStyle(
                                    color: Color(0xfff83600),
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConfig.textMultiplier * 3.5,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  'Become a Prime Member',
                                  style: TextStyle(
                                    color: Color(0xfff83600),
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConfig.textMultiplier * 3.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                          SizedBox(
                            height: 30,
                          ),
                          member == 'Y'
                              ? Text(
                                  'Start Membership',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: SizeConfig.textMultiplier * 3,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  'Prime Membership is a special membership that unlocks all the prime features and other special access.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                          SizedBox(
                            height: 20,
                          ),
                          member == 'Y'
                              ? Text(
                                  startDate,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: SizeConfig.textMultiplier * 3,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      totalAmount = prize1;
                                      days = 30;
                                      openCheckout();
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.red)),
                                  minWidth: double.infinity,
                                  height: 60,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        '1 month - ' +
                                            prize1.toString() +
                                            '/*Rs only '.toUpperCase(),
                                      ),
                                      Text(
                                        '*include taxes',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 11),
                                      )
                                    ],
                                  ),
                                  color: Colors.white,
                                  textColor: Colors.red,
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          member == 'Y'
                              ? Text(
                                  'End Membership',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: SizeConfig.textMultiplier * 3,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      totalAmount = prize2;
                                      days = 60;
                                      openCheckout();
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.red)),
                                  minWidth: double.infinity,
                                  height: 50,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        '2 month - ' +
                                            prize2.toString() +
                                            '/*Rs only'.toUpperCase(),
                                      ),
                                      Text(
                                        '*include taxes',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 11),
                                      )
                                    ],
                                  ),
                                  color: Colors.white,
                                  textColor: Colors.red,
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          member == 'Y'
                              ? Text(
                                  endDate,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: SizeConfig.textMultiplier * 3,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      totalAmount = prize3;
                                      days = 90;
                                      openCheckout();
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.red)),
                                  minWidth: double.infinity,
                                  height: 50,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        '3 month - ' +
                                            prize3.toString() +
                                            '/*Rs only'.toUpperCase(),
                                      ),
                                      Text(
                                        '*include taxes',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 11),
                                      )
                                    ],
                                  ),
                                  color: Colors.white,
                                  textColor: Colors.red,
                                ),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 8,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget test(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomPadding: false,
                body: Container(
                  padding: EdgeInsets.all(4.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: SizeConfig.heightMultiplier * 9,
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        Icons.menu,
                                        size: 30,
                                      ),
                                      onPressed: () => openClose(),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    height: 60,
                                    padding: EdgeInsets.only(top: 5),
                                    child: Form(
                                      key: formKey,
                                      child: Theme(
                                        data: new ThemeData(
                                          primaryColor: Colors.deepOrange,
                                        ),
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: Color(0xfff83600)),
                                          maxLength: 5,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            labelText: 'Enter Key',
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide()),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide()),
                                          ),
                                          validator: (input) => input.length < 5
                                              ? 'Please enter a valid key'
                                              : null,
                                          keyboardType: TextInputType.number,
                                          onChanged: (input) {
                                            _code = input;
                                          },
                                          onFieldSubmitted: (input) {
                                            _code = input;
                                            _submit();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        Icons.check_circle_outline,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        _submit();
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: SizeConfig.heightMultiplier * 17,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemExtent: SizeConfig.widthMultiplier * 69,
                          itemCount: data2.length,
                          itemBuilder: (context, index) {
                            return isTest
                                ? ColorLoader()
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        paperCode = data2[index]['paper_code'];
                                        title = data2[index]['title'];
                                        stream = data2[index]['stream'];
                                        time = data2[index]['time'];
                                        status = data2[index]['status'];
                                        isLive = data2[index]['is_live'];
                                        quest = data2[index]['quest'];
                                        negative =
                                            data2[index]['negative_mark'];
                                        addPaper();
                                      });
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
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
                                                              data2[index]
                                                                  ['title'],
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xfff83600),
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              data2[index]
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
                                                              data2[index]
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
                                              color: data2[index]['is_live'] ==
                                                      'Live'
                                                  ? Colors.red
                                                  : Colors.blue,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                    data2[index]['is_live'],
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
                                  );
                          },
                        ),
                      ),
                      Text(
                        'Exam Category',
                        style: TextStyle(
                            color: Color(0xfff83600),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: Container(
                              child: isCollapsed
                                  ? GridView()
                                  : Text('Category.'))),
                      Container(
                        height: SizeConfig.heightMultiplier * 6,
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Widget notification(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 34,
                        ),
                        onTap: () {
                          openClose();
                        },
                      ),
                      Text("Notification",
                          style: TextStyle(fontSize: 24, color: Colors.black)),
                      Icon(Icons.settings, color: Colors.black),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Image.network(
                      'https://www.konfest.com/wp-content/uploads/2019/05/Konfest-PNG-JPG-Image-Pic-Photo-Free-Download-Royalty-Unlimited-clip-art-sticker-Coming-Soon-Sale-upcoming-Red-3.png',
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: ColorLoader3());
                      },
                    ),
                  ),
                  member == 'N'
                      ? Container(
                          alignment: Alignment(0.5, 1),
                          child: FacebookNativeAd(
                            placementId: nativeBannerID,
                            adType: NativeAdType.NATIVE_BANNER_AD,
                            bannerAdSize: NativeBannerAdSize.HEIGHT_100,
                            width: double.infinity,
                            height: 100,
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
                          height: 0,
                          width: 0,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget notes(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: DefaultTabController(
                length: 8,
                child: Scaffold(
                  appBar: AppBar(
                    leading: GestureDetector(
                        onTap: () {
                          openClose();
                        },
                        child: Icon(Icons.menu)),
                    backgroundColor: Color(0xfff83600),
                    bottom: TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(
                          child: Container(
                            child: Text(
                              'ALL',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Text(
                              'MATHS',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Text(
                              'VARG-3',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Text(
                              'REASONING',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Text(
                              'GENERAL SCIENCE',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Text(
                              'GENERAL AWARENESS',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Text(
                              'HINDI',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Text(
                              'ENGLISH',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text("Study Material"),
                    centerTitle: true,
                  ),
                  body: TabBarView(
                    children: [
                      NestedTabBar(0),
                      NestedTabBar(1),
                      NestedTabBar(2),
                      NestedTabBar(3),
                      NestedTabBar(4),
                      NestedTabBar(5),
                      NestedTabBar(6),
                      NestedTabBar(7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      Navigator.push(context, SlideRightRoute(page: CodeTest(_code)));
    }
  }
}

class GridView extends StatefulWidget {
  @override
  _GridViewState createState() => _GridViewState();
}

class _GridViewState extends State<GridView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: false,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverGrid.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ShowTest('aptitude')));
                },
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Color(0xfff83600),
                      width: 1.0,
                    ),
                  ),
                  elevation: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.calculator,
                          color: Color(0xfff83600),
                          size: SizeConfig.textMultiplier * 6,
                        ),
                        Text(
                          'Aptitude',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.textMultiplier * 2.5,
                              color: Color(0xfff83600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ShowTest('reasoning')));
                },
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Color(0xfff83600),
                      width: 1.0,
                    ),
                  ),
                  elevation: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.cogs,
                          color: Color(0xfff83600),
                          size: SizeConfig.textMultiplier * 6,
                        ),
                        Text(
                          'Reasoning',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.textMultiplier * 2.5,
                              color: Color(0xfff83600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ShowTest('GS')));
                },
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Color(0xfff83600),
                      width: 1.0,
                    ),
                  ),
                  elevation: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.book,
                          color: Color(0xfff83600),
                          size: SizeConfig.textMultiplier * 6,
                        ),
                        Text(
                          'General Studies',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.textMultiplier * 2.5,
                              color: Color(0xfff83600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ShowTest('GA')));
                },
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Color(0xfff83600),
                      width: 1.0,
                    ),
                  ),
                  elevation: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.globeEurope,
                          color: Color(0xfff83600),
                          size: SizeConfig.textMultiplier * 6,
                        ),
                        Text(
                          'General Awareness',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.textMultiplier * 2.5,
                              color: Color(0xfff83600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ShowTest('varg3')));
                },
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Color(0xfff83600),
                      width: 1.0,
                    ),
                  ),
                  elevation: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.chalkboardTeacher,
                          color: Color(0xfff83600),
                          size: SizeConfig.textMultiplier * 6,
                        ),
                        Text(
                          'Varg 3',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.textMultiplier * 2.5,
                              color: Color(0xfff83600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ShowTest('english')));
                },
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Color(0xfff83600),
                      width: 1.0,
                    ),
                  ),
                  elevation: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.at,
                          color: Color(0xfff83600),
                          size: SizeConfig.textMultiplier * 6,
                        ),
                        Text(
                          'English',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.textMultiplier * 2.5,
                              color: Color(0xfff83600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, SlideRightRoute(page: ShowTest('hindi')));
                },
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Color(0xfff83600),
                      width: 1.0,
                    ),
                  ),
                  elevation: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.rupeeSign,
                          color: Color(0xfff83600),
                          size: SizeConfig.textMultiplier * 6,
                        ),
                        Text(
                          'Hindi',
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.textMultiplier * 2.5,
                              color: Color(0xfff83600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NestedTabBar extends StatefulWidget {
  int tap;
  NestedTabBar(this.tap);
  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  TabController _nestedTabController;
  int studID;
  List data;
  String member, mem, site;
  bool isLoading = true, isInterstitialAdLoaded = false;
  Widget _currentAd = SizedBox(
    width: 0.0,
    height: 0.0,
  );

  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    _showNativeAd();
    _loadInterstitialAd();
    start();
    _nestedTabController = new TabController(length: 2, vsync: this);
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
          launchURL(site, mem);
          setState(() {
            isInterstitialAdLoaded = false;
            _loadInterstitialAd();
          });
        }
        if (result == InterstitialAdResult.CLICKED) {
          launchURL(site, mem);
        }
      },
    );
  }

  _showInterstitialAd() {
    if (isInterstitialAdLoaded == true)
      FacebookInterstitialAd.showInterstitialAd();
    else
      launchURL(site, mem);
  }

  Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    member = prefs.getString('member');
    studID = prefs.getInt('studid');
    var response2 = await http.post(Uri.encodeFull(showNotes), body: {
      "stud_id": studID.toString(),
    });
    var resBody2 = json.decode(response2.body);
    data = resBody2['data'];
    setState(() {
      isLoading = false;
    });
  }

  launchURL(String url, String mem) async {
    if (mem == 'Y') {
      if (member == 'Y') {
        if (url.contains('youtu.be') || url.contains('youtube.com')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Video(url)),
          );
        } else {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        }
      } else {
        Fluttertoast.showToast(
            msg: 'You are not a Prime Member !! Please buy Prime.');
      }
    } else {
      if (url.contains('youtu.be') || url.contains('youtube.com')) {
        setState(() {
          Navigator.push(context, SlideRightRoute(page: Video(url)));
        });
      } else {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    }
  }

  _showNativeAd() {
    setState(() {
      _currentAd = FacebookNativeAd(
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
          if (NativeAdResult.ERROR == result) {
            _loadInterstitialAd();
            _showNativeAd();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: ColorLoader())
          : widget.tap == 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    member == 'N'
                        ? _currentAd
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                  leading: Icon(
                                      data[index]['type'] == 'P'
                                          ? FontAwesomeIcons.filePdf
                                          : data[index]['type'] == 'V'
                                              ? FontAwesomeIcons.playCircle
                                              : FontAwesomeIcons.volumeUp,
                                      size: SizeConfig.textMultiplier * 5),
                                  title: Text(data[index]['name']),
                                  subtitle: Text(data[index]['sub_name'] +
                                      " " +
                                      data[index]['teacher']),
                                  trailing: isInterstitialAdLoaded
                                      ? Icon(Icons.play_circle_outline)
                                      : Icon(Icons.pause_circle_outline),
                                  onTap: () {
                                    site = data[index]['url'];
                                    mem = data[index]['prime'];
                                    member == 'N'
                                        ? _showInterstitialAd()
                                        : launchURL(site, mem);
                                  }),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : widget.tap == 1
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        member == 'N'
                            ? _currentAd
                            : Container(
                                height: 0,
                                width: 0,
                              ),
                        TabBar(
                          controller: _nestedTabController,
                          indicatorColor: Color(0xfff83600),
                          labelColor: Color(0xfff83600),
                          unselectedLabelColor: Colors.black54,
                          isScrollable: true,
                          tabs: <Widget>[
                            Tab(
                              text: "PDF",
                            ),
                            Tab(
                              text: "VIDEO",
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: TabBarView(
                              controller: _nestedTabController,
                              children: <Widget>[
                                ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return data[index]['sub'] == 'MATH'
                                        ? data[index]['type'] == 'P'
                                            ? Card(
                                                child: ListTile(
                                                    leading: Icon(
                                                        FontAwesomeIcons
                                                            .filePdf,
                                                        size: SizeConfig
                                                                .textMultiplier *
                                                            5),
                                                    title: Text(
                                                        data[index]['name']),
                                                    subtitle: Text(
                                                        data[index]['teacher']),
                                                    trailing: isInterstitialAdLoaded
                                                        ? Icon(Icons
                                                            .play_circle_outline)
                                                        : Icon(Icons
                                                            .pause_circle_outline),
                                                    onTap: () {
                                                      site = data[index]['url'];
                                                      mem =
                                                          data[index]['prime'];
                                                      member == 'N'
                                                          ? _showInterstitialAd()
                                                          : launchURL(
                                                              site, mem);
                                                    }),
                                              )
                                            : Container(width: 0, height: 0)
                                        : Container(width: 0, height: 0);
                                  },
                                ),
                                ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return data[index]['sub'] == 'MATH'
                                        ? data[index]['type'] == 'V'
                                            ? Card(
                                                child: ListTile(
                                                    leading: Icon(
                                                        FontAwesomeIcons
                                                            .playCircle,
                                                        size: SizeConfig
                                                                .textMultiplier *
                                                            5),
                                                    title: Text(
                                                        data[index]['name']),
                                                    subtitle: Text(
                                                        data[index]['teacher']),
                                                    trailing: isInterstitialAdLoaded
                                                        ? Icon(Icons
                                                            .play_circle_outline)
                                                        : Icon(Icons
                                                            .pause_circle_outline),
                                                    onTap: () {
                                                      site = data[index]['url'];
                                                      mem =
                                                          data[index]['prime'];
                                                      member == 'N'
                                                          ? _showInterstitialAd()
                                                          : launchURL(
                                                              site, mem);
                                                    }),
                                              )
                                            : Container(width: 0, height: 0)
                                        : Container(width: 0, height: 0);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : widget.tap == 2
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            member == 'N'
                                ? _currentAd
                                : Container(
                                    height: 0,
                                    width: 0,
                                  ),
                            TabBar(
                              controller: _nestedTabController,
                              indicatorColor: Color(0xfff83600),
                              labelColor: Color(0xfff83600),
                              unselectedLabelColor: Colors.black54,
                              isScrollable: true,
                              tabs: <Widget>[
                                Tab(
                                  text: "PDF",
                                ),
                                Tab(
                                  text: "VIDEO",
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                child: TabBarView(
                                  controller: _nestedTabController,
                                  children: <Widget>[
                                    ListView.builder(
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        return data[index]['sub'] == 'VARG'
                                            ? data[index]['type'] == 'P'
                                                ? Card(
                                                    child: ListTile(
                                                        leading: Icon(
                                                            FontAwesomeIcons
                                                                .filePdf,
                                                            size: SizeConfig
                                                                    .textMultiplier *
                                                                5),
                                                        title: Text(data[index]
                                                            ['name']),
                                                        subtitle: Text(
                                                            data[index]
                                                                ['teacher']),
                                                        trailing: isInterstitialAdLoaded
                                                            ? Icon(Icons
                                                                .play_circle_outline)
                                                            : Icon(Icons
                                                                .pause_circle_outline),
                                                        onTap: () {
                                                          site = data[index]
                                                              ['url'];
                                                          mem = data[index]
                                                              ['prime'];
                                                          member == 'N'
                                                              ? _showInterstitialAd()
                                                              : launchURL(
                                                                  site, mem);
                                                        }),
                                                  )
                                                : Container(width: 0, height: 0)
                                            : Container(width: 0, height: 0);
                                      },
                                    ),
                                    ListView.builder(
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        return data[index]['sub'] == 'VARG'
                                            ? data[index]['type'] == 'V'
                                                ? Card(
                                                    child: ListTile(
                                                        leading: Icon(
                                                            FontAwesomeIcons
                                                                .playCircle,
                                                            size: SizeConfig
                                                                    .textMultiplier *
                                                                5),
                                                        title: Text(data[index]
                                                            ['name']),
                                                        subtitle: Text(
                                                            data[index]
                                                                ['teacher']),
                                                        trailing: isInterstitialAdLoaded
                                                            ? Icon(Icons
                                                                .play_circle_outline)
                                                            : Icon(Icons
                                                                .pause_circle_outline),
                                                        onTap: () {
                                                          site = data[index]
                                                              ['url'];
                                                          mem = data[index]
                                                              ['prime'];
                                                          member == 'N'
                                                              ? _showInterstitialAd()
                                                              : launchURL(
                                                                  site, mem);
                                                        }),
                                                  )
                                                : Container(width: 0, height: 0)
                                            : Container(width: 0, height: 0);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : widget.tap == 3
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                member == 'N'
                                    ? _currentAd
                                    : Container(
                                        height: 0,
                                        width: 0,
                                      ),
                                TabBar(
                                  controller: _nestedTabController,
                                  indicatorColor: Color(0xfff83600),
                                  labelColor: Color(0xfff83600),
                                  unselectedLabelColor: Colors.black54,
                                  isScrollable: true,
                                  tabs: <Widget>[
                                    Tab(
                                      text: "PDF",
                                    ),
                                    Tab(
                                      text: "VIDEO",
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: TabBarView(
                                      controller: _nestedTabController,
                                      children: <Widget>[
                                        ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, index) {
                                            return data[index]['sub'] ==
                                                    'REASONING'
                                                ? data[index]['type'] == 'P'
                                                    ? Card(
                                                        child: ListTile(
                                                            leading: Icon(
                                                                FontAwesomeIcons
                                                                    .filePdf,
                                                                size: SizeConfig
                                                                        .textMultiplier *
                                                                    5),
                                                            title: Text(
                                                                data[index]
                                                                    ['name']),
                                                            subtitle: Text(data[
                                                                    index]
                                                                ['teacher']),
                                                            trailing: isInterstitialAdLoaded
                                                                ? Icon(Icons
                                                                    .play_circle_outline)
                                                                : Icon(Icons
                                                                    .pause_circle_outline),
                                                            onTap: () {
                                                              site = data[index]
                                                                  ['url'];
                                                              mem = data[index]
                                                                  ['prime'];
                                                              member == 'N'
                                                                  ? _showInterstitialAd()
                                                                  : launchURL(
                                                                      site,
                                                                      mem);
                                                            }),
                                                      )
                                                    : Container(
                                                        width: 0, height: 0)
                                                : Container(
                                                    width: 0, height: 0);
                                          },
                                        ),
                                        ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, index) {
                                            return data[index]['sub'] ==
                                                    'REASONING'
                                                ? data[index]['type'] == 'V'
                                                    ? Card(
                                                        child: ListTile(
                                                            leading: Icon(
                                                                FontAwesomeIcons
                                                                    .playCircle,
                                                                size: SizeConfig
                                                                        .textMultiplier *
                                                                    5),
                                                            title: Text(
                                                                data[index]
                                                                    ['name']),
                                                            subtitle: Text(data[
                                                                    index]
                                                                ['teacher']),
                                                            trailing: isInterstitialAdLoaded
                                                                ? Icon(Icons
                                                                    .play_circle_outline)
                                                                : Icon(Icons
                                                                    .pause_circle_outline),
                                                            onTap: () {
                                                              site = data[index]
                                                                  ['url'];
                                                              mem = data[index]
                                                                  ['prime'];
                                                              member == 'N'
                                                                  ? _showInterstitialAd()
                                                                  : launchURL(
                                                                      site,
                                                                      mem);
                                                            }),
                                                      )
                                                    : Container(
                                                        width: 0, height: 0)
                                                : Container(
                                                    width: 0, height: 0);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : widget.tap == 4
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    member == 'N'
                                        ? _currentAd
                                        : Container(
                                            height: 0,
                                            width: 0,
                                          ),
                                    TabBar(
                                      controller: _nestedTabController,
                                      indicatorColor: Color(0xfff83600),
                                      labelColor: Color(0xfff83600),
                                      unselectedLabelColor: Colors.black54,
                                      isScrollable: true,
                                      tabs: <Widget>[
                                        Tab(
                                          text: "PDF",
                                        ),
                                        Tab(
                                          text: "VIDEO",
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: TabBarView(
                                          controller: _nestedTabController,
                                          children: <Widget>[
                                            ListView.builder(
                                              itemCount: data.length,
                                              itemBuilder: (context, index) {
                                                return data[index]['sub'] ==
                                                        'GS'
                                                    ? data[index]['type'] == 'P'
                                                        ? Card(
                                                            child: ListTile(
                                                                leading: Icon(
                                                                    FontAwesomeIcons
                                                                        .filePdf,
                                                                    size: SizeConfig
                                                                            .textMultiplier *
                                                                        5),
                                                                title: Text(data[
                                                                        index]
                                                                    ['name']),
                                                                subtitle: Text(
                                                                    data[index][
                                                                        'teacher']),
                                                                trailing: isInterstitialAdLoaded
                                                                    ? Icon(Icons
                                                                        .play_circle_outline)
                                                                    : Icon(Icons
                                                                        .pause_circle_outline),
                                                                onTap: () {
                                                                  site = data[
                                                                          index]
                                                                      ['url'];
                                                                  mem = data[
                                                                          index]
                                                                      ['prime'];
                                                                  member == 'N'
                                                                      ? _showInterstitialAd()
                                                                      : launchURL(
                                                                          site,
                                                                          mem);
                                                                }),
                                                          )
                                                        : Container(
                                                            width: 0, height: 0)
                                                    : Container(
                                                        width: 0, height: 0);
                                              },
                                            ),
                                            ListView.builder(
                                              itemCount: data.length,
                                              itemBuilder: (context, index) {
                                                return data[index]['sub'] ==
                                                        'GS'
                                                    ? data[index]['type'] == 'V'
                                                        ? Card(
                                                            child: ListTile(
                                                                leading: Icon(
                                                                    FontAwesomeIcons
                                                                        .playCircle,
                                                                    size: SizeConfig
                                                                            .textMultiplier *
                                                                        5),
                                                                title: Text(data[
                                                                        index]
                                                                    ['name']),
                                                                subtitle: Text(
                                                                    data[index][
                                                                        'teacher']),
                                                                trailing: isInterstitialAdLoaded
                                                                    ? Icon(Icons
                                                                        .play_circle_outline)
                                                                    : Icon(Icons
                                                                        .pause_circle_outline),
                                                                onTap: () {
                                                                  site = data[
                                                                          index]
                                                                      ['url'];
                                                                  mem = data[
                                                                          index]
                                                                      ['prime'];
                                                                  member == 'N'
                                                                      ? _showInterstitialAd()
                                                                      : launchURL(
                                                                          site,
                                                                          mem);
                                                                }),
                                                          )
                                                        : Container(
                                                            width: 0, height: 0)
                                                    : Container(
                                                        width: 0, height: 0);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : widget.tap == 5
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        member == 'N'
                                            ? _currentAd
                                            : Container(
                                                height: 0,
                                                width: 0,
                                              ),
                                        TabBar(
                                          controller: _nestedTabController,
                                          indicatorColor: Color(0xfff83600),
                                          labelColor: Color(0xfff83600),
                                          unselectedLabelColor: Colors.black54,
                                          isScrollable: true,
                                          tabs: <Widget>[
                                            Tab(
                                              text: "PDF",
                                            ),
                                            Tab(
                                              text: "VIDEO",
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: TabBarView(
                                              controller: _nestedTabController,
                                              children: <Widget>[
                                                ListView.builder(
                                                  itemCount: data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return data[index]['sub'] ==
                                                            'GA'
                                                        ? data[index]['type'] ==
                                                                'P'
                                                            ? Card(
                                                                child: ListTile(
                                                                    leading: Icon(
                                                                        FontAwesomeIcons
                                                                            .filePdf,
                                                                        size: SizeConfig.textMultiplier *
                                                                            5),
                                                                    title: Text(
                                                                        data[index]
                                                                            [
                                                                            'name']),
                                                                    subtitle: Text(
                                                                        data[index]
                                                                            [
                                                                            'teacher']),
                                                                    trailing: isInterstitialAdLoaded
                                                                        ? Icon(Icons
                                                                            .play_circle_outline)
                                                                        : Icon(Icons
                                                                            .pause_circle_outline),
                                                                    onTap: () {
                                                                      site = data[
                                                                              index]
                                                                          [
                                                                          'url'];
                                                                      mem = data[
                                                                              index]
                                                                          [
                                                                          'prime'];
                                                                      member ==
                                                                              'N'
                                                                          ? _showInterstitialAd()
                                                                          : launchURL(
                                                                              site,
                                                                              mem);
                                                                    }),
                                                              )
                                                            : Container(
                                                                width: 0,
                                                                height: 0)
                                                        : Container(
                                                            width: 0,
                                                            height: 0);
                                                  },
                                                ),
                                                ListView.builder(
                                                  itemCount: data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return data[index]['sub'] ==
                                                            'GA'
                                                        ? data[index]['type'] ==
                                                                'V'
                                                            ? Card(
                                                                child: ListTile(
                                                                    leading: Icon(
                                                                        FontAwesomeIcons
                                                                            .volumeUp,
                                                                        size: SizeConfig.textMultiplier *
                                                                            5),
                                                                    title: Text(
                                                                        data[index]
                                                                            [
                                                                            'name']),
                                                                    subtitle: Text(
                                                                        data[index]
                                                                            [
                                                                            'teacher']),
                                                                    trailing: isInterstitialAdLoaded
                                                                        ? Icon(Icons
                                                                            .play_circle_outline)
                                                                        : Icon(Icons
                                                                            .pause_circle_outline),
                                                                    onTap: () {
                                                                      site = data[
                                                                              index]
                                                                          [
                                                                          'url'];
                                                                      mem = data[
                                                                              index]
                                                                          [
                                                                          'prime'];
                                                                      member ==
                                                                              'N'
                                                                          ? _showInterstitialAd()
                                                                          : launchURL(
                                                                              site,
                                                                              mem);
                                                                    }),
                                                              )
                                                            : Container(
                                                                width: 0,
                                                                height: 0)
                                                        : Container(
                                                            width: 0,
                                                            height: 0);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : widget.tap == 6
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            member == 'N'
                                                ? _currentAd
                                                : Container(
                                                    height: 0,
                                                    width: 0,
                                                  ),
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: ListView.builder(
                                                  itemCount: data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return data[index]['sub'] ==
                                                            'HINDI'
                                                        ? Card(
                                                            child: ListTile(
                                                                leading: Icon(
                                                                    data[index]['type'] == 'P'
                                                                        ? FontAwesomeIcons
                                                                            .filePdf
                                                                        : data[index]['type'] ==
                                                                                'V'
                                                                            ? FontAwesomeIcons
                                                                                .playCircle
                                                                            : FontAwesomeIcons
                                                                                .volumeUp,
                                                                    size: SizeConfig
                                                                            .textMultiplier *
                                                                        5),
                                                                title: Text(data[index]
                                                                    ['name']),
                                                                subtitle: Text(
                                                                    data[index][
                                                                        'teacher']),
                                                                trailing: isInterstitialAdLoaded
                                                                    ? Icon(Icons.play_circle_outline)
                                                                    : Icon(Icons.pause_circle_outline),
                                                                onTap: () {
                                                                  site = data[
                                                                          index]
                                                                      ['url'];
                                                                  mem = data[
                                                                          index]
                                                                      ['prime'];
                                                                  member == 'N'
                                                                      ? _showInterstitialAd()
                                                                      : launchURL(
                                                                          site,
                                                                          mem);
                                                                }),
                                                          )
                                                        : Container(
                                                            width: 0,
                                                            height: 0);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            member == 'N'
                                                ? _currentAd
                                                : Container(
                                                    height: 0,
                                                    width: 0,
                                                  ),
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: ListView.builder(
                                                  itemCount: data.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return data[index]['sub'] ==
                                                            'ENGLISH'
                                                        ? Card(
                                                            child: ListTile(
                                                                leading: Icon(
                                                                    data[index]['type'] == 'P'
                                                                        ? FontAwesomeIcons
                                                                            .filePdf
                                                                        : data[index]['type'] ==
                                                                                'V'
                                                                            ? FontAwesomeIcons
                                                                                .playCircle
                                                                            : FontAwesomeIcons
                                                                                .volumeUp,
                                                                    size: SizeConfig
                                                                            .textMultiplier *
                                                                        5),
                                                                title: Text(data[index]
                                                                    ['name']),
                                                                subtitle: Text(
                                                                    data[index][
                                                                        'teacher']),
                                                                trailing: isInterstitialAdLoaded
                                                                    ? Icon(Icons.play_circle_outline)
                                                                    : Icon(Icons.pause_circle_outline),
                                                                onTap: () {
                                                                  site = data[
                                                                          index]
                                                                      ['url'];
                                                                  mem = data[
                                                                          index]
                                                                      ['prime'];
                                                                  member == 'N'
                                                                      ? _showInterstitialAd()
                                                                      : launchURL(
                                                                          site,
                                                                          mem);
                                                                }),
                                                          )
                                                        : Container(
                                                            width: 0,
                                                            height: 0);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
    );
  }
}
