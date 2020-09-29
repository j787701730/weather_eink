import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_eink/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map nowData = {};
  List sevenDayData = [];
  List hoursData = [];

  Map cityData = {
    'name': '福州',
    'id': 101230101,
    'lat': '26.07530',
    'lon': '119.30623',
    'adm2': '福州',
    'adm1': '福建',
    'country': '中国',
    'tz': 'Asia/Shanghai',
    'utcOffset': '+08:00',
    'isDst': 0,
    'type': 'city',
    'rank': '11',
    'fxLink': 'http://hfx.link/34w1'
  };

  @override
  void initState() {
    super.initState();
    _getCity();
  }

  _getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String logs = prefs.getString('logs');
    if (logs != null && jsonDecode(logs) is List && jsonDecode(logs).isNotEmpty) {
      setState(() {
        cityData = jsonDecode(logs)[0];
        ck();
      });
    } else {
      prefs.setString('logs', jsonEncode([cityData]));
      ck();
    }
  }

  hoursWeather() {
    ajax('https://devapi.heweather.net/v7/weather/24h?location=${cityData['id']}', {}, (data) {
      if (mounted) {
        if (data['code'] == '200') {
          setState(() {
            hoursData = data['hourly'].sublist(0, 12);
          });
        } else {}
      }
    });
  }

  sevenDayWeather() {
    ajax(
      'https://devapi.heweather.net/v7/weather/7d?location=${cityData['id']}',
      {},
      (data) {
        if (mounted) {
          if (data['code'] == '200') {
            setState(() {
              sevenDayData = data['daily'];
            });
          } else {}
        }
      },
    );
  }

  nowWeather() {
    if (mounted) {
      setState(() {
        nowData = {};
      });
    }
    ajax(
      'https://devapi.heweather.net/v7/weather/now?location=${cityData['id']}',
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
      },
    );
  }

  void ck() async {
    if (await checkNetWork()) {
      nowWeather();
      sevenDayWeather();
      hoursWeather();
    } else {}
  }

  DateTime _lastQuitTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    double width = media.size.width - media.padding.left - media.padding.right - 30;
    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.list,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/log').then(
                    (value) {
                      if (value == true) {
                        _getCity();
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/add').then(
                    (value) {
                      if (value == true) {
                        _getCity();
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.black,
                ),
                onPressed: ck,
              ),
            ],
          ),
          body: nowData.isNotEmpty
              ? ListView(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                          '${DateTime.parse(nowData['obsTime']).year}/${DateTime.parse(nowData['obsTime']).month}/'
                          '${DateTime.parse(nowData['obsTime']).day} '
                          '${DateTime.parse('2020-09-28T16:15').hour}:${DateTime.parse(nowData['obsTime']).minute} 更新'),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${cityData['name']}',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                'weather-icon-S1/bw-64/${nowData['icon']}.png',
                                width: 50,
                                height: 50,
                              ),
                              Text(nowData['text'])
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${nowData['temp']}℃',
                                style: TextStyle(
                                  fontSize: 60,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Color(0xffcccccc),
                          ),
                          bottom: BorderSide(
                            color: Color(0xffcccccc),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('相对湿度'),
                              Text('百分之${nowData['humidity']}'),
                            ],
                          ),
                          Column(
                            children: [
                              Text('${nowData['windDir']}'),
                              Text('${nowData['windScale']}级'),
                            ],
                          ),
                          Column(
                            children: [
                              Text('气压'),
                              Text('${nowData['pressure']}百帕'),
                            ],
                          ),
                          Column(
                            children: [
                              Text('能见度'),
                              Text('${nowData['vis']}公里'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xffcccccc),
                          ),
                        ),
                      ),
                      child: hoursData.isEmpty
                          ? Container()
                          : Wrap(
                              children: hoursData.map<Widget>((item) {
                                return Container(
                                  key: Key(item['fxTime']),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 15),
                                  width: width / 6,
                                  child: Column(
                                    children: [
                                      Text('${DateTime.parse(item['fxTime'].substring(0, 16)).hour}时'),
                                      Image.asset(
                                        'weather-icon-S1/bw-64/${item['icon']}.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      Text('${item['temp']}℃'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    Container(
                      child: sevenDayData.isEmpty
                          ? Container()
                          : Column(
                              children: sevenDayData.map<Widget>((item) {
                                return Container(
                                  key: Key(item['fxDate']),
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text('${item['fxDate']}'.substring(5)),
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'weather-icon-S1/bw-64/${item['iconDay']}.png',
                                            width: 50,
                                            height: 50,
                                          ),
                                          Text('${item['textDay']}')
                                        ],
                                      ),
                                      Container(
                                        child: Text('${item['tempMin']}~${item['tempMax']}℃'),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                )
              : Container(
                  alignment: Alignment.center,
                  child: Text('加载中...'),
                ),
        ),
        onWillPop: () async {
          if (_lastQuitTime == null || DateTime.now().difference(_lastQuitTime).inSeconds > 1) {
            print('再按一次 Back 按钮退出');
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Container(
                  height: 44,
                  alignment: Alignment.center,
                  child: Text('再按一次 Back 按钮退出'),
                ),
              ),
            );
            _lastQuitTime = DateTime.now();
            return false;
          } else {
            print('退出');
            Navigator.of(context).pop(true);
            return true;
          }
        });
  }
}
