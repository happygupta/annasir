import 'package:annasir/ads.dart';
import 'package:annasir/home/editprofile.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/splash/login.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String sName, sGender, mobNo, sDob, startMember, endMember, member, coaMember;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    start();
//    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mobNo = prefs.getString('mobno');
      sName = prefs.getString('s_name');
      sGender = prefs.getString('s_gender');
      sDob = prefs.getString('s_dob');
      startMember = prefs.getString('s_member');
      endMember = prefs.getString('e_member');
      member = prefs.getString('member');
      coaMember = prefs.getString('coamember');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage();
  }
}

class ProfilePage extends StatelessWidget {
  Future<void> logBye() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  TextStyle _style() {
    return TextStyle(fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Name",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(sName.toUpperCase()),
            SizedBox(
              height: 16,
            ),
            Text(
              "Gender",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(sGender == 'M' ? 'Male' : 'Female'),
            SizedBox(
              height: 16,
            ),
            Text(
              "Date of Birth",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(sDob),
            SizedBox(
              height: 16,
            ),
            Text(
              "Phone Number",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text("+91" + mobNo),
            SizedBox(
              height: 16,
            ),
            Text(
              "Language",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text("Hindi"),
            SizedBox(
              height: 16,
            ),
            Divider(
              color: Colors.grey,
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  logBye();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: Container(
                    width: 210,
                    height: 42,
                    child: Center(
                        child: Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )),
                    decoration: BoxDecoration(
                        color: Color(0xfff83600),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 20)
                        ]),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: SizeConfig.heightMultiplier * 4,
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
}

final String url = "https://hemantgupta.tech/siranna/ic.png";

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize =>
      Size(double.infinity, SizeConfig.heightMultiplier * 40);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(top: 4),
        decoration: BoxDecoration(color: Color(0xffF83600), boxShadow: [
          BoxShadow(color: Colors.red, blurRadius: 20, offset: Offset(0, 0))
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            fit: BoxFit.cover, image: NetworkImage(url)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      "Coaching Student",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      coaMember == 'N' ? 'NOT' : 'YES',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  ],
                ),
                SizedBox(
                  width: 32,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Prime Member",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(member == 'N' ? 'NOT' : 'YES',
                        style: TextStyle(color: Colors.white, fontSize: 24))
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdateProfile()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: Container(
                    width: 110,
                    height: 32,
                    child: Center(
                      child: Text("Edit Profile"),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 20)
                        ]),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();

    p.lineTo(0, size.height - 40);
//  p.lineTo(size.width, size.height);
    p.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height);
    p.quadraticBezierTo(size.width - (size.width / 4), size.height, size.width,
        size.height - 40);

    p.lineTo(size.width, 0);

    p.close();

    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
