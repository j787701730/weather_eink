import 'package:flutter/material.dart';
import 'package:weather_eink/utils.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map nowData = {};

  @override
  void initState() {
    super.initState();
    ck();
  }

  void ck() async {
    if (await checkNetWork()) {
      ajax(
        'https://devapi.heweather.net/v7/weather/now?location=101230101',
        {},
        (data) {
          if (mounted) {
            if (data['code'] == '200') {
              data['now']['obsTime'] = data['now']['obsTime'].substring(0, 16);
              setState(() {
                nowData = data['now'];
              });
            } else {}
          }
          print(data);
        },
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    print(nowData);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.black,
              ),
              onPressed: ck)
        ],
      ),
      body: nowData.isNotEmpty
          ? ListView(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: Text('${DateTime.parse(nowData['obsTime']).month}-${DateTime.parse(nowData['obsTime']).day} '
                      '${DateTime.parse('2020-09-28T16:15').hour}:${DateTime.parse(nowData['obsTime']).minute}更新'),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text('福州市'),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text('${nowData['temp']}℃'),
                ),
                Image.asset(
                  'weather-icon-S1/bw-64/${nowData['icon']}.png',
                  width: 64,
                  height: 64,
                )
              ],
            )
          : Container(
              alignment: Alignment.center,
              child: Text('无数据'),
            ),
    );
  }
}
