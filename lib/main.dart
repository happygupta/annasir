import 'package:annasir/splash/splash.dart';
import 'package:flutter/material.dart';

import 'screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Anna Sir',
              theme: ThemeData.light(),
              home: Splash(),
            );
          },
        );
      },
    );
  }
}
