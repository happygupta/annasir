import 'package:annasir/ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperPage extends StatefulWidget {
  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
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
    return SafeArea(
      child: Scaffold(
          body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfff83600),
              Color(0xfffe8c00),
              Color(0xfff83600),
            ],
          ),
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 25,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          "Developer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            size: 25,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 50, horizontal: 25),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: new Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 10,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 5,
                                  offset: Offset(1, 0))
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                heightFactor: 0.50,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xfff83600),
                                              blurRadius: 10,
                                              offset: Offset(0, 0))
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xfff83600),
                                        radius: 45.0,
                                        backgroundImage: NetworkImage(
                                            'https://hemantgupta.tech/img/banner/mini.jpeg'),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 25,
                                          ),
                                          Text(
                                            "Hemant kumar Gupta",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "I'm Software Developer for Android & IOS Mobile App, WEB App. And also work for Server Side Pogramming. Better knowledge of API's, Frontend and Backend Programming.",
                                  overflow: TextOverflow.fade,
                                  maxLines: 8,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: new Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 10,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 5,
                                  offset: Offset(1, 0))
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                heightFactor: 0.50,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xfff83600),
                                              blurRadius: 10,
                                              offset: Offset(0, 0))
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xfff83600),
                                        radius: 45.0,
                                        backgroundImage: NetworkImage(
                                            'https://i.pinimg.com/originals/ad/46/c6/ad46c60fc691b25561ff83f57d1b22dc.jpg'),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 25,
                                          ),
                                          Text(
                                            "Om Prakash Osle ",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "I'm Software UI Designer for Mobile App & WEB App. also work for Graphics Designing. And Mobile Application Developer for Android.",
                                  overflow: TextOverflow.fade,
                                  maxLines: 8,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 50),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: new Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 10,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 5,
                                  offset: Offset(1, 0))
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                heightFactor: 0.50,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xfff83600),
                                              blurRadius: 10,
                                              offset: Offset(0, 0))
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xfff83600),
                                        radius: 45.0,
                                        backgroundImage: NetworkImage(
                                            'https://scontent-bom1-1.xx.fbcdn.net/v/t1.0-9/40135101_1727620100697065_5315154081864482816_n.jpg?_nc_cat=104&_nc_ohc=18Vt8Z-KmVMAX9isw_V&_nc_ht=scontent-bom1-1.xx&oh=b9937c15b7e67f630480eb7f4e63a9b3&oe=5ED5AD97'),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 25,
                                          ),
                                          Text(
                                            "Adarsh Gupta ",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "I'm Java Software Developer, Worked in Database Management System and Application Support team. ",
                                  overflow: TextOverflow.fade,
                                  maxLines: 8,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox.fromSize(
                  size: Size(56, 56), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: () => _launchURL(), // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.call), // icon
                            Text("Call"), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
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
      )),
    );
  }

  _launchURL() async {
    const url = 'tel:+919993529230';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
