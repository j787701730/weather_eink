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
  DateTime _lastQuitTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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

  void init() async {
    if (await checkNetWork()) {
      nowWeather();
      sevenDayWeather();
      hoursWeather();
    } else {
      _message('无网络');
    }
  }

  _getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String logs = prefs.getString('logs');
    if (logs != null && jsonDecode(logs) is List && jsonDecode(logs).isNotEmpty) {
      setState(() {
        cityData = jsonDecode(logs)[0];
        init();
      });
    } else {
      prefs.setString('logs', jsonEncode([cityData]));
      init();
    }
  }

  _message(val) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Container(
          height: 34,
          alignment: Alignment.center,
          child: Text(val),
        ),
      ),
    );
  }

  hoursWeather() {
    ajax('https://devapi.heweather.net/v7/weather/24h?location=${cityData['id']}', {}, (data) {
      if (mounted) {
        if (data['code'] == '200') {
          setState(() {
            hoursData = data['hourly'].sublist(0, 12);
          });
        } else {
          _message('${data['code']}');
        }
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
          } else {
            _message('${data['code']}');
          }
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
          } else {
            _message('${data['code']}');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    double width = media.size.width - media.padding.left - media.padding.right - 30;
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.list,
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
              ),
              onPressed: init,
            ),
          ],
        ),
        body: nowData.isNotEmpty
            ? ListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${DateTime.parse(nowData['obsTime']).year}/${DateTime.parse(nowData['obsTime']).month}/'
                      '${DateTime.parse(nowData['obsTime']).day} '
                      '${DateTime.parse('2020-09-28T16:15').hour}:${DateTime.parse(nowData['obsTime']).minute} 更新',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${cityData['name']}',
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              'weather-icon-S1/bw-64/${nowData['icon']}.png',
                              width: 30,
                              height: 30,
                            ),
                            Text(nowData['text'])
                          ],
                        ),
                        Container(
                          width: 10,
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
                    padding: EdgeInsets.symmetric(vertical: 8),
                    margin: EdgeInsets.only(bottom: 8),
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
                  hoursData.isEmpty
                      ? Container()
                      : Wrap(
                          children: hoursData.map<Widget>((item) {
                            return Container(
                              key: Key(item['fxTime']),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(bottom: 8),
                              width: width / 6,
                              child: Column(
                                children: [
                                  Text('${DateTime.parse(item['fxTime'].substring(0, 16)).hour}时'),
                                  Image.asset(
                                    'weather-icon-S1/bw-64/${item['icon']}.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  Text('${item['temp']}℃'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xffcccccc),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(top: 4),
                    child: sevenDayData.isEmpty
                        ? Container()
                        : Column(
                            children: sevenDayData.map<Widget>((item) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                key: Key(item['fxDate']),
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
                                          width: 30,
                                          height: 30,
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
          _message('再按一次 Back 按钮退出');
          _lastQuitTime = DateTime.now();
          return false;
        }
        return true;
      },
    );
  }
}
