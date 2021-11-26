import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotifyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Riddle', style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.white,
        elevation: 0.4,
      ),
      body: Center(
        child: Text('Notify'),
      ),
    );
  }
}
