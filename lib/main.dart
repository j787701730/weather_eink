import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_eink/home.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.white);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      child: MaterialApp(
        title: '天气墨水屏',
        themeMode: ThemeMode.light,
        theme: ThemeData(
          // primarySwatch: Colors.blue,
          brightness: Brightness.light,
          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: Brightness.light,
          ),
          platform: TargetPlatform.iOS,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: MyHomePage(title: '天气墨水屏'),
        debugShowCheckedModeBanner: false,
      ),
      value: SystemUiOverlayStyle.dark,
    );
  }
}
