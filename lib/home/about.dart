import 'package:annasir/ads.dart';
import 'package:annasir/screen.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

List<CustomPopupMenu> choices = <CustomPopupMenu>[
  CustomPopupMenu(
      title: 'Privacy Policy',
      urls:
          'https://docs.google.com/document/d/e/2PACX-1vQKST6HUqwnUZMp0hjJlcfzef19qRWWiI6WhKNdSHPW-c_n-MmqOaJ4yAecFuQbuywFKDW3DPcGpzgt/pub'),
  CustomPopupMenu(
      title: 'Terms & Conditions',
      urls:
          'https://docs.google.com/document/d/e/2PACX-1vRkHKbvgzd5likOAAwsoFXKc1gAOXed6VL6c7s_ZpbqbCuk5dbgkJG6kYpnkUw994OgMv9SGya4FQmE/pub'),
  CustomPopupMenu(
      title: 'Cancellation/Refund Policies',
      urls:
          'https://docs.google.com/document/d/e/2PACX-1vTUaFyeW1UKTBhRBNgODdjmP8Z-RlAjl20CeDrEgHXzT8seF2aTZg8Hbme_bqlVfZihn4gu38O_d1SZ/pub'),
];

class _AboutPageState extends State<AboutPage> {
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

  final String url =
      "https://images-na.ssl-images-amazon.com/images/I/71%2BN8YiVIPL._SX466_.jpg";

  void _select(CustomPopupMenu choice) {
    setState(() {
      _launchURL(choice.urls);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff83600),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("About"),
        actions: <Widget>[
          PopupMenuButton<CustomPopupMenu>(
            elevation: 3.2,
            onCanceled: () {
              print('You have not chossed anything');
            },
            tooltip: 'More Options',
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.map((CustomPopupMenu choice) {
                return PopupMenuItem<CustomPopupMenu>(
                  height: 50,
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          )
        ],
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: SizeConfig.widthMultiplier * 65,
                    height: SizeConfig.heightMultiplier * 35,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Color(0xfff83600),
                              blurRadius: 10,
                              offset: Offset(0, 0))
                        ],
                        image: DecorationImage(
                            fit: BoxFit.cover, image: NetworkImage(url))),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Thankyou for expressing your interest in Jyotirmay Coaching Classes Mobile Application. We regularly update our app to improve performance & fuctionalities to help you.",
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Divider(color: Colors.grey),
              SizedBox(
                height: 20,
              ),
              Text(
                "Jyotirmay Coaching Classes",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Color(0xfff83600)),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "By Anna Sir",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Contact Details",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text("Mobile No.",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      Text("8109186547",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "For Query",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text("Hemant Gupta",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      Text("9993529230",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      Text("OmPrakash Osle",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      Text("9993539272",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.heightMultiplier,
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
      ),
    );
  }
}

class CustomPopupMenu {
  CustomPopupMenu({this.title, this.urls});

  String title;
  String urls;
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
