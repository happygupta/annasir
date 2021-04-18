import 'package:annasir/ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HideAds extends StatefulWidget {
  @override
  _HideAdsState createState() => _HideAdsState();
}

class _HideAdsState extends State<HideAds> {
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
        title: Text('Hide Ads for some time'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            MaterialButton(
              onPressed: () {},
              child: Text(
                'Hide Ads \nThis feature is upcoming..',
                textAlign: TextAlign.center,
              ),
            ),
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
                      height: 300,
                      backgroundColor: Colors.white,
                      titleColor: Colors.black,
                      descriptionColor: Colors.black,
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
    );
  }
}
