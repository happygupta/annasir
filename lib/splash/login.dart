import 'dart:convert';

import 'package:annasir/home/form.dart';
import 'package:annasir/home/home.dart';
import 'package:annasir/service.dart';
import 'package:annasir/splash/loader3.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _authForm = GlobalKey<FormState>();
  final _smsForm = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isVerified = false;
  bool validation = false, otpVerify = false;
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  String _verificationId;
  FirebaseAuth auth;
  var data;
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');

  @override
  initState() {
    super.initState();
    getFireBase();
  }

  getFireBase() async {
    final String name = 'Anna Sir';
    final FirebaseOptions options = const FirebaseOptions(
        googleAppID: '1:147894380946:android:e723e754413d2cf268f94b',
        apiKey: 'AIzaSyC8-6buT4lBlDnRF6xtIPsm3aa3QcRNxsU',
        projectID: 'anna-c6eda');

    final FirebaseApp _fireBase =
        await FirebaseApp.configure(name: name, options: options);
    auth = FirebaseAuth.fromApp(_fireBase);
  }

  Future<void> check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response = await http.post(Uri.encodeFull(checkMobile), body: {
      "mob_no": _phoneController.text,
    });

    var resBody = json.decode(response.body);
    data = resBody['data'];
    if (data.isEmpty) {
      response = await http.post(Uri.encodeFull(addMobile), body: {
        "mob_no": _phoneController.text,
        "token": 'mzw6NFKU',
        "date": formatter.format(now).toString(),
      });
      resBody = json.decode(response.body);
      data = resBody['data'];
      if (data.isNotEmpty) {
        prefs.setString('mobno', _phoneController.text);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Formless()));
      }
    } else {
      response = await http.post(Uri.encodeFull(updateToken), body: {
        "mob_no": _phoneController.text,
        "token": 'mzw6NFKU',
      });
      resBody = json.decode(response.body);
      data = resBody['data'];
      if (data.isNotEmpty) {
        prefs.setString('mobno', _phoneController.text);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  Future<void> _sigIn(String otp) async {
    if (_smsForm.currentState.validate()) {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      final FirebaseUser user =
          (await auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);

      if (user != null) {
        setState(() {
          isVerified = true;
          check();
        });
        print('Successfully signed in, uid: ' + user.uid);
      } else {
        print('Sign in failed');
      }
    }
  }

  Future<void> _verify() async {
    if (_authForm.currentState.validate()) {
      try {
        final PhoneVerificationCompleted verificationCompleted =
            (AuthCredential phoneAuthCredential) {
          auth.signInWithCredential(phoneAuthCredential);
          print(phoneAuthCredential);
          Fluttertoast.showToast(msg: 'SUCCESS');
          check();
        };

        final PhoneVerificationFailed verificationFailed =
            (AuthException authException) {
          print(authException);
          Fluttertoast.showToast(msg: 'Too Much Attempt. Try Later!');
          setState(() {
            isLoading = false;
          });
        };
        final PhoneCodeSent codeSent =
            (String verificationId, [int forceResendingToken]) async {
          _verificationId = verificationId;
          setState(() {
            otpVerify = true;
          });
        };

        final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
            (String verificationId) {
          _verificationId = verificationId;
        };

        await auth.verifyPhoneNumber(
            phoneNumber: "+91" + _phoneController.text,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      } catch (_) {
        setState(() {
          this.isLoading = false;
        });
        print("AUTH FAILED: $_");
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isVerified
        ? WillPopScope(
            onWillPop: () async {
              return Future.value(false);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: ColorLoader3()),
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            body: WillPopScope(
              onWillPop: () async {
                return Future.value(false);
              },
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xfff83600),
                        gradient: LinearGradient(
                            colors: [
                              Color(0xfff83600),
                              Color(0xfffe8c00),
                              Color(0xfff83600)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                  ),
                  SingleChildScrollView(
                    child: otpVerify
                        ? Form(
                            key: _smsForm,
                            autovalidate: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  height: 40,
                                ),
                                Hero(
                                    tag: "spls",
                                    child: Image.asset(
                                      'assets/anna.png',
                                      height: SizeConfig.heightMultiplier * 40,
                                      width: SizeConfig.widthMultiplier * 55,
                                    )),
                                Container(
                                  padding: EdgeInsets.only(left: 40, right: 40),
                                  child: TextFormField(
                                    controller: _smsController,
                                    maxLength: 6,
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    onSaved: (val) {
                                      return _sigIn(val);
                                    },
                                    validator: (val) =>
                                        val.length != 6 ? "Invalid OTP!" : null,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      prefixIcon: Icon(Icons.phone_android),
                                      labelText: "Enter Your OTP",
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 190,
                                  ),
                                  child: Material(
                                      borderRadius: BorderRadius.circular(15),
                                      shadowColor: Color(0xcc000000),
                                      elevation: 7,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 42,
                                        onPressed: () {
                                          setState(() {
                                            _sigIn(_smsController.text);
                                          });
                                        },
                                        child: Text(
                                          "Verify",
                                          style: TextStyle(
                                              color: Color(0xfff83600),
                                              fontSize: 21),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 30,
                                  ),
                                  child: Material(
                                      borderRadius: BorderRadius.circular(15),
                                      shadowColor: Color(0xcc000000),
                                      elevation: 7,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 42,
                                        onPressed: () {
                                          setState(() {
                                            otpVerify = false;
                                          });
                                        },
                                        child: Text(
                                          "Change Mobile Number",
                                          style: TextStyle(
                                              color: Color(0xfff83600),
                                              fontSize: 21),
                                        ),
                                      )),
                                )
                              ],
                            ),
                          )
                        : Form(
                            key: _authForm,
                            autovalidate: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: 40,
                                ),
                                Hero(
                                    tag: "spls",
                                    child: Image.asset(
                                      'assets/anna.png',
                                      height: SizeConfig.heightMultiplier * 40,
                                      width: SizeConfig.widthMultiplier * 55,
                                    )),
                                Container(
                                  padding: EdgeInsets.only(left: 40, right: 40),
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    autofocus: false,
                                    controller: _phoneController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      prefixText: '+91',
                                      prefixIcon: Icon(Icons.phone_android),
                                      labelText: "Enter Your Mobile Number",
                                      errorText: validation
                                          ? "Enter a valid number"
                                          : null,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    padding: EdgeInsets.only(
                                      left: 190,
                                    ),
                                    child: Material(
                                        borderRadius: BorderRadius.circular(15),
                                        shadowColor: Color(0xcc000000),
                                        elevation: 7,
                                        child: MaterialButton(
                                          minWidth: 120,
                                          height: 42,
                                          onPressed: () {
                                            setState(() {
                                              validation = false;
                                              isLoading = true;
                                              if (_phoneController
                                                      .text.isNotEmpty &&
                                                  _phoneController.text.length >
                                                      9) {
                                                _verify();
                                              } else {
                                                validation = true;
                                              }
                                            });
                                          },
                                          child: isLoading
                                              ? CircularProgressIndicator()
                                              : Text(
                                                  "LOGIN",
                                                  style: TextStyle(
                                                      color: Color(0xfff83600),
                                                      fontSize: 21),
                                                ),
                                        )))
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
  }
}
