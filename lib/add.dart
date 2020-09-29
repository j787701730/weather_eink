import 'dart:convert';

import 'package:flutter/material.dart';
import 'utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Add extends StatefulWidget {
  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  List locations = [];
  String keyWord = '';

  _cityAdd(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String logs = prefs.getString('logs');
    List data = [];
    if (logs == null) {
      data.add(value);
    } else {
      data = jsonDecode(logs);
      for (var o in data) {
        if (o['id'] == value['id']) {
          data.remove(o);
          break;
        }
      }
      data.insert(0, value);
    }
    await prefs.setString('logs', jsonEncode(data));
    Navigator.of(context).pop(true);
  }

  lookup() {
    ajax(
      'https://geoapi.heweather.net/v2/city/lookup?location=$keyWord',
      {},
      (data) {
        if (mounted) {
          if (data['code'] == '200') {
            setState(() {
              locations = data['location'] is List ? data['location'] : [];
            });
          } else {}
        }
      },
    );
  }

  search() {
    if (keyWord.trim().isNotEmpty) {
      lookup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 1,
        title: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '输入城市名称',
          ),
          onChanged: (val) {
            keyWord = val;
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: search,
          )
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (context, index) {
          Map item = locations[index];
          return ListTile(
            key: Key('${item['id']}'),
            title: Row(
              children: [
                Text(item['name']),
                Text(
                  '   (${item['country']} ${item['adm1']} ${item['adm2']})',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            onTap: () {
              _cityAdd(item);
            },
          );
        },
        itemCount: locations.length,
      ),
    );
  }
}
