import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_eink/add.dart';
import 'package:weather_eink/home.dart';
import 'package:weather_eink/list-log.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.white);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

/// 去掉 可滚动组件滑到顶部和尾部会有水波纹效果
class RefreshScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return child;
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return GlowingOverscrollIndicator(
          child: child,
          showLeading: false,
          //顶部水波纹是否展示
          showTrailing: false,
          //底部水波纹是否展示
          axisDirection: axisDirection,
          notificationPredicate: (notification) {
            if (notification.depth == 0) {
              // 越界是否展示水波纹
              if (notification.metrics.outOfRange) {
                return false;
              }
              return true;
            }
            return false;
          },
          color: Theme.of(context).primaryColor,
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
    }
    return null;
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
            primaryColor: Colors.white,
            brightness: Brightness.light,
            // cupertinoOverrideTheme: CupertinoThemeData(
            //   brightness: Brightness.light,
            // ),
            // platform: TargetPlatform.iOS,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(
              bodyText2: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
            )),
        home: MyHomePage(title: '天气墨水屏'),
        builder: (context, child) {
          return ScrollConfiguration(
            child: child,
            behavior: RefreshScrollBehavior(),
          );
        },
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          '/home': (_) => MyHomePage(),
          '/log': (_) => ListLog(),
          '/add': (_) => Add(),
        },
      ),
      value: SystemUiOverlayStyle.dark,
    );
  }
}
