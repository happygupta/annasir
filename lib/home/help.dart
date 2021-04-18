import 'package:annasir/ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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
          icon: new Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Help"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(4.0),
//            decoration: BoxDecoration(color: Colors.white, boxShadow: [
//              BoxShadow(color: Colors.red, blurRadius: 20, offset: Offset(0, 0))
//            ]),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Home",
                  style: TextStyle(fontSize: 20.0, color: Color(0xfff83600)),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Home gives you access to Updates, Tests, Notes and many other updates will be notified here.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Wallet",
                  style: TextStyle(fontSize: 20.0, color: Color(0xfff83600)),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "It help you to pay money instantly to buy a subscription or test in this app. If you're not able to add or pay money online, you have another option available here to pay the required amount offline : Contact Developer.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Prime Membership",
                  style: TextStyle(fontSize: 20.0, color: Color(0xfff83600)),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Prime Membership is a special membership that unlocks all the prime features and other special access.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Free Tests",
                  style: TextStyle(fontSize: 20.0, color: Color(0xfff83600)),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Free online test to practice for Competitive exams. Aptitude, Logical Reasoning, Computer Questions will help you to prepare for Online Exam. These free tests you can attempt without any prime membership for your practice to sharpen your skills.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Notes",
                  style: TextStyle(fontSize: 20.0, color: Color(0xfff83600)),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "It gives you all the notes provided by the teachers. You can download them and browse, even when you are offline.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Updates",
                  style: TextStyle(fontSize: 20.0, color: Color(0xfff83600)),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Get any Exam Updates - Entrance Test Notifications, Time Table/Exam Date Sheet, Admit Card, Results, Study Material. We also update all the latest news there also. Hence you will not miss any of the important information that can make your future bright.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                member == 'N'
                    ? Container(
                        alignment: Alignment(0.5, 1),
                        child: FacebookNativeAd(
                          placementId: nativeFullID,
                          adType: NativeAdType.NATIVE_AD,
                          width: double.infinity,
                          height: 300,
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
      ),
    );
  }
}
