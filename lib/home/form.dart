import 'dart:convert';

import 'package:annasir/home/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service.dart';

class Formless extends StatefulWidget {
  @override
  _FormlessState createState() => _FormlessState();
}

class _FormlessState extends State<Formless> {
  DateTime _dateTime;

  bool isLoading = true;
  String name;
  String dob;
  var formatter = new DateFormat('dd-MM-yyyy');
  int selectedRadio, studID;
  var data, msg;
  var mobNo;

  @override
  void initState() {
    super.initState();
    loadFirst();
  }

  Future<void> loadFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mobNo = prefs.getString('mobno');
    var response = await http.post(Uri.encodeFull(checkMobile), body: {
      "mob_no": mobNo,
    });
    var resBody = json.decode(response.body);
    data = resBody['data'];
    studID = data[0]['stud_id'];
    prefs.setInt('studid', studID);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> submit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sname', name);
    prefs.setString('gender', selectedRadio == 0 ? 'M' : 'F');
    prefs.setString('dob', dob);
    await http.post(Uri.encodeFull(addUser), body: {
      "stud_id": studID.toString(),
      "mob_no": mobNo,
      "s_name": name,
      "gender": selectedRadio == 0 ? 'M' : 'F',
      "dob": dob,
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
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Registration',
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
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Divider(),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Name',
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                              )),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
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
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                                labelText: dob == null ? 'Date of Birth' : dob,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    )),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          RaisedButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Icon(
                              Icons.date_range,
                              size: 28,
                            ),
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: _dateTime == null
                                          ? DateTime.now()
                                          : _dateTime,
                                      firstDate: DateTime(1980),
                                      lastDate: DateTime(2021))
                                  .then((date) {
                                setState(() {
                                  _dateTime = date;
                                  dob = formatter.format(date).toString();
                                });
                              });
                            },
                          ),
                        ],
                      )),
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
                    height: 20,
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
                              'Register',
                              style: TextStyle(
                                  color: Color(0xfff83600), fontSize: 22),
                            ),
                            color: Colors.white,
                            onPressed: () {
                              if (name != null && dob != null) {
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
                ],
              ),
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
//      resizeToAvoidBottomPadding: false,
      ),
    );
  }
}
