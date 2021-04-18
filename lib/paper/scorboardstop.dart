import 'dart:convert';

import 'package:annasir/ads.dart';
import 'package:annasir/home/home.dart';
import 'package:annasir/screen.dart';
import 'package:annasir/service.dart';
import 'package:annasir/splash/loader.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisStop extends StatefulWidget {
  final int paper;
  AnalysisStop(this.paper);

  _AnalysisStopState createState() => _AnalysisStopState();
}

class _AnalysisStopState extends State<AnalysisStop> {
  List<charts.Series<Task, String>> _seriesPieData;
  List<charts.Series<Score, String>> _seriesData;
  List data, data3;
  int studID;
  String quest, correctAns, wrongAns, notVisited, skipped, member;
  var totalScore, topper = 0.0, average = 0.0;
  bool isLoading = true;

  Future<void> start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    member = prefs.getString('member');
    studID = prefs.getInt('studid');
    quest = prefs.getString('quest');
    var response2 = await http.post(Uri.encodeFull(showUserResult), body: {
      "paper_code": widget.paper.toString(),
      "stud_id": studID.toString(),
    });
    var resBody2 = json.decode(response2.body);
    data = resBody2['data'];
    setState(() {
      correctAns = data[0]['correct'].toString();
      wrongAns = data[0]['wrong'].toString();
      notVisited = data[0]['notvisit'].toString();
      skipped = data[0]['skip'].toString();
      totalScore = data[0]['marks'].toString();
    });
    var response = await http.post(Uri.encodeFull(showResult), body: {
      "paper_code": widget.paper.toString(),
    });
    var resBody = json.decode(response.body);
    data = resBody['data'];
    setState(() {
      for (int i = 0; i < data.length; i++) {
        average = average + data[i]['marks'];
        if (topper < data[i]['marks']) {
          topper = data[i]['marks'];
        }
      }
      average = average / data.length;
    });
    var response3 = await http.post(Uri.encodeFull(showAllResult), body: {
      "paper_code": widget.paper.toString(),
    });
    var resBody3 = json.decode(response3.body);
    data3 = resBody3['data'];
    setState(() {
      _generateData();
      isLoading = false;
    });
  }

  Future<void> refresh() async {
    var response3 = await http.post(Uri.encodeFull(showAllResult), body: {
      "paper_code": widget.paper.toString(),
    });
    var resBody3 = json.decode(response3.body);
    data3 = resBody3['data'];
    setState(() {
      isLoading = false;
    });
  }

  _generateData() {
    var data1 = [
      new Score('Total', double.parse(quest), Colors.blue),
      new Score('Topper', topper, Colors.green),
      new Score('You', double.parse(totalScore), Colors.yellow),
      new Score('Average', average, Colors.teal),
    ];

    var pieData = [
      new Task('Correct', double.parse(correctAns), Colors.green),
      new Task('Incorrect', double.parse(wrongAns), Colors.red),
      new Task('Skipped', double.parse(skipped), Colors.yellow),
      new Task('Not Visited', double.parse(notVisited), Colors.grey),
    ];

    _seriesData.add(
      charts.Series(
        domainFn: (Score score, _) => score.stnam,
        measureFn: (Score score, _) => score.marks,
        id: '2017',
        data: data1,
        labelAccessorFn: (Score score, _) => ('${score.marks.toString()}'),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (Score score, _) =>
            charts.ColorUtil.fromDartColor(score.omee),
      ),
    );

    _seriesPieData.add(
      charts.Series(
        domainFn: (Task task, _) => task.task,
        measureFn: (Task task, _) => task.taskvalue,
        colorFn: (Task task, _) =>
            charts.ColorUtil.fromDartColor(task.colorval),
        id: 'TestData',
        data: pieData,
        labelAccessorFn: (Task row, _) => '${row.taskvalue}',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    start();
    _seriesPieData = List<charts.Series<Task, String>>();
    _seriesData = List<charts.Series<Score, String>>();
    FacebookAudienceNetwork.init(testingId: testID);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                leading: FlatButton(
                  onLongPress: () {
                    Fluttertoast.showToast(msg: 'Refresh');
                  },
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    refresh();
                  },
                  child: Icon(
                    Icons.cached,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Color(0xfff83600),
                actions: <Widget>[
                  FlatButton(
                    onLongPress: () {
                      Fluttertoast.showToast(msg: 'Go Home');
                    },
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                  ),
                ],
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(icon: Icon(FontAwesomeIcons.chartPie)),
                    Tab(icon: Icon(FontAwesomeIcons.solidChartBar)),
                    Tab(icon: Icon(FontAwesomeIcons.chalkboard)),
                  ],
                ),
                title: Text("Performance"),
              ),
              body: WillPopScope(
                onWillPop: () async {
                  return Future.value(true);
                },
                child: isLoading
                    ? Scaffold(
                        backgroundColor: Colors.white,
                        body: Center(child: ColorLoader()),
                      )
                    : TabBarView(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Overall Performance',
                                      style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Expanded(
                                      child: charts.PieChart(_seriesPieData,
                                          animate: true,
                                          animationDuration:
                                              Duration(seconds: 3),
                                          behaviors: [
                                            new charts.DatumLegend(
                                              outsideJustification: charts
                                                  .OutsideJustification
                                                  .endDrawArea,
                                              horizontalFirst: false,
                                              desiredMaxRows: 2,
                                              cellPadding: new EdgeInsets.only(
                                                  right: 4.0, bottom: 4.0),
                                              entryTextStyle:
                                                  charts.TextStyleSpec(
                                                      color: charts
                                                          .MaterialPalette
                                                          .deepOrange
                                                          .shadeDefault,
                                                      fontFamily: 'Georgia',
                                                      fontSize: 11),
                                            )
                                          ],
                                          defaultRenderer:
                                              new charts.ArcRendererConfig(
                                                  arcWidth: 100,
                                                  arcRendererDecorators: [
                                                new charts.ArcLabelDecorator(
                                                    labelPosition: charts
                                                        .ArcLabelPosition
                                                        .inside)
                                              ])),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'Your Marks',
                                              style: TextStyle(
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        2,
                                              ),
                                            ),
                                            Text(
                                              totalScore,
                                              style: TextStyle(
                                                  fontSize: SizeConfig
                                                          .textMultiplier *
                                                      4,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        VerticalDivider(),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'Total Marks',
                                              style: TextStyle(
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        2,
                                              ),
                                            ),
                                            Text(
                                              quest,
                                              style: TextStyle(
                                                  fontSize: SizeConfig
                                                          .textMultiplier *
                                                      4,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 3,
                                    ),
                                    member == 'N'
                                        ? Container(
                                            alignment: Alignment(0.5, 1),
                                            child: FacebookNativeAd(
                                              placementId: nativeBannerID,
                                              adType:
                                                  NativeAdType.NATIVE_BANNER_AD,
                                              bannerAdSize:
                                                  NativeBannerAdSize.HEIGHT_50,
                                              width: double.infinity,
                                              height: 51,
                                              backgroundColor: Colors.white,
                                              titleColor: Colors.black,
                                              descriptionColor: Colors.black,
                                              buttonColor: Color(0xfff83600),
                                              buttonTitleColor: Colors.black,
                                              buttonBorderColor: Colors.black,
                                              listener: (result, value) {
                                                print(
                                                    "Native Banner Ad: $result --> $value");
                                                if (NativeAdResult.ERROR ==
                                                    result) {}
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
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Comparison with other students',
                                      style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: charts.BarChart(
                                        _seriesData,
                                        animate: true,
                                        barGroupingType:
                                            charts.BarGroupingType.grouped,
                                        //behaviors: [new charts.SeriesLegend()],
                                        animationDuration: Duration(seconds: 3),
                                      ),
                                    ),
                                    member == 'N'
                                        ? Container(
                                            alignment: Alignment(0.5, 1),
                                            child: FacebookNativeAd(
                                              placementId: nativeBannerID,
                                              adType:
                                                  NativeAdType.NATIVE_BANNER_AD,
                                              bannerAdSize:
                                                  NativeBannerAdSize.HEIGHT_50,
                                              width: double.infinity,
                                              height: 51,
                                              backgroundColor: Colors.white,
                                              titleColor: Colors.black,
                                              descriptionColor: Colors.black,
                                              buttonColor: Color(0xfff83600),
                                              buttonTitleColor: Colors.black,
                                              buttonBorderColor: Colors.black,
                                              listener: (result, value) {
                                                print(
                                                    "Native Banner Ad: $result --> $value");
                                                if (NativeAdResult.ERROR ==
                                                    result) {}
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
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Scorecard',
                                      style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ListTile(
                                      leading: Text('No.'),
                                      title: Text('Name\u{1f600}'),
                                      trailing: Text('Marks'),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: ListView.builder(
                                            itemCount: data3.length,
                                            itemBuilder: (context, index) {
                                              return index < data3.length
                                                  ? ListTile(
                                                      leading: Text((index + 1)
                                                              .toString() +
                                                          "."),
                                                      title: Text(data3[index]
                                                          ['s_name']),
                                                      subtitle: Text(
                                                          "Batch : " +
                                                              data3[index]
                                                                      ['batch']
                                                                  .toString() +
                                                              " , " +
                                                              "Time : " +
                                                              data3[index]
                                                                      ['time']
                                                                  .toString()),
                                                      trailing: Text(
                                                          data3[index]['marks']
                                                              .toStringAsFixed(
                                                                  2)),
                                                    )
                                                  : Container(
                                                      height: 0,
                                                      width: 0,
                                                    );
                                            }),
                                      ),
                                    ),
                                    member == 'N'
                                        ? Container(
                                            alignment: Alignment(0.5, 1),
                                            child: FacebookNativeAd(
                                              placementId: nativeBannerID,
                                              adType:
                                                  NativeAdType.NATIVE_BANNER_AD,
                                              bannerAdSize:
                                                  NativeBannerAdSize.HEIGHT_50,
                                              width: double.infinity,
                                              height: 51,
                                              backgroundColor: Colors.white,
                                              titleColor: Colors.black,
                                              descriptionColor: Colors.black,
                                              buttonColor: Color(0xfff83600),
                                              buttonTitleColor: Colors.black,
                                              buttonBorderColor: Colors.black,
                                              listener: (result, value) {
                                                print(
                                                    "Native Banner Ad: $result --> $value");
                                                if (NativeAdResult.ERROR ==
                                                    result) {}
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
                        ],
                      ),
              ),
            ),
          ),
        ));
  }
}

class Score {
  String stnam;
  double marks;
  Color omee;

  Score(this.stnam, this.marks, this.omee);
}

class Task {
  String task;
  double taskvalue;
  Color colorval;

  Task(this.task, this.taskvalue, this.colorval);
}
