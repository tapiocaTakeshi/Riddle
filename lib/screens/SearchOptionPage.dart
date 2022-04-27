import 'package:Riddle/screens/HomeScreen.dart';
import 'package:flutter/material.dart';

enum orders { New, Popular, Difficult }

orders order = orders.New;

enum filters { All, Subsc }

filters filter = filters.All;

class SearchOptionPage extends StatefulWidget {
  @override
  _SearchOptionPageState createState() => _SearchOptionPageState();
}

class _SearchOptionPageState extends State<SearchOptionPage> {
  void _handleRadio1(orders? e) => setState(() {
        order = e!;
      });

  void _handleRadio2(filters? e) => setState(() {
        filter = e!;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(
            '並び替え',
            style: TextStyle(fontSize: 20),
          ),
          Column(
            children: [
              RadioListTile<orders>(
                  activeColor: Colors.orange,
                  title: Text('新しい順'),
                  value: orders.New,
                  groupValue: order,
                  onChanged: (value) {
                    _handleRadio1(value);
                  }),
              RadioListTile<orders>(
                  activeColor: Colors.orange,
                  title: Text('人気順'),
                  value: orders.Popular,
                  groupValue: order,
                  onChanged: (value) {
                    _handleRadio1(value);
                  }),
              RadioListTile<orders>(
                  activeColor: Colors.orange,
                  title: Text('難易度順'),
                  value: orders.Difficult,
                  groupValue: order,
                  onChanged: (value) {
                    _handleRadio1(value);
                  }),
            ],
          ),
          Text(
            'フィルタ',
            style: TextStyle(fontSize: 20),
          ),
          Column(
            children: [
              RadioListTile<filters>(
                  activeColor: Colors.orange,
                  title: Text('すべて'),
                  value: filters.All,
                  groupValue: filter,
                  onChanged: (value) {
                    _handleRadio2(value);
                  }),
              RadioListTile<filters>(
                  activeColor: Colors.orange,
                  title: Text('登録済み'),
                  value: filters.Subsc,
                  groupValue: filter,
                  onChanged: (value) {
                    _handleRadio2(value);
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
