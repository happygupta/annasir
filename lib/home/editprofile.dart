import 'dart:convert';

import 'package:annasir/ads.dart';
import 'package:annasir/home/home.dart';
import 'package:annasir/home/profile.dart';
import 'package:annasir/screen.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../service.dart';

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  bool isLoading = true;
  String name, gender, member;
  int selectedRadio, studID;
  var data, msg;
  var mobNo;

  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(testingId: testID);
    loadFirst();
  }

  Future<void> loadFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    member = prefs.getString('member');
    mobNo = prefs.getString('mobno');
    name = sName;
    var response = await http.post(Uri.encodeFull(checkMobile), body: {
      "mob_no": mobNo,
    });
    var resBody = json.decode(response.body);
    data = resBody['data'];
    if (data.isNotEmpty) {
      studID = data[0]['stud_id'];
      prefs.setInt('studid', studID);
      setState(() {
        selectedRadio = (sGender == 'M') ? 0 : 1;
        isLoading = false;
      });
    }
  }

  Future<void> submit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sname', name);
    prefs.setString('gender', selectedRadio == 0 ? 'M' : 'F');
    await http.post(Uri.encodeFull(updateUser), body: {
      "mob_no": mobNo,
      "s_name": name,
      "gender": selectedRadio == 0 ? 'M' : 'F',
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Update Profile',
                  style: new TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 10.0,
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 45.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        size: 80.0,
                        color: Color(0xfff83600),
                      ),
//                    Text("User")
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                  child: Divider(),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Name',
                        hintText: name,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              color: Colors.white,
                            )),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              color: Colors.white,
                            )),
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      }),
                ),
                SizedBox(
                  height: 20,
                ),
                new Text(
                  'Select Gender',
                  style: new TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Radio(
                      value: 0,
                      groupValue: selectedRadio,
                      activeColor: Colors.black38,
                      onChanged: (val) {
                        setSelectedRadio(val);
                      },
                    ),
                    new Text(
                      'Male',
                      style: new TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    new Radio(
                      value: 1,
                      groupValue: selectedRadio,
                      activeColor: Colors.black38,
                      onChanged: (val) {
                        setSelectedRadio(val);
                      },
                    ),
                    new Text(
                      'Female',
                      style: new TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: isLoading
                      ? Text('Loading...\n Please Wait...')
                      : MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Update',
                            style: TextStyle(
                                color: Color(0xfff83600), fontSize: 22),
                          ),
                          color: Colors.white,
                          onPressed: () {
                            if (name != null) {
                              if (selectedRadio == 0 || selectedRadio == 1) {
                                setState(() {
                                  isLoading = true;
                                  submit();
                                });
                              } else {
                                Fluttertoast.showToast(msg: 'Select Gender');
                              }
                            } else {
                              Fluttertoast.showToast(msg: 'Enter Your Name');
                            }
                          }),
                ),
                SizedBox(
                  height: SizeConfig.heightMultiplier * 4,
                ),
                member == 'N'
                    ? Container(
                        alignment: Alignment(0.5, 1),
                        child: FacebookNativeAd(
                          placementId: nativeFullID,
                          adType: NativeAdType.NATIVE_AD,
                          width: double.infinity,
                          height: 300,
                          backgroundColor: Color(0xfff86300),
                          titleColor: Colors.white,
                          descriptionColor: Colors.white,
                          buttonColor: Colors.white,
                          buttonTitleColor: Colors.deepOrange,
                          buttonBorderColor: Colors.white,
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
