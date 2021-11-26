import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiddlePage extends StatefulWidget {
  @override
  _RiddlePageState createState() => _RiddlePageState();

  List<DocumentSnapshot> Slides;

  int index;
  int length;

  RiddlePage({
    @required this.Slides,
    @required this.index,
    @required this.length,
  });
}

class _RiddlePageState extends State<RiddlePage> {
  int count;
  Timer timer;

  void StartTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        count--;
        if (count < 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    count = widget.Slides[widget.index]['limit'];
    StartTimer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Column(
          children: [
            Expanded(
                child: Center(
                    child: Text(
              '${(count ~/ 60).toString().padLeft(2, '0')}:${(count % 60).toString().padLeft(2, '0')}',
            ))),
            Expanded(
                child: Center(
              child:
                  Image.network(widget.Slides[widget.index]['slideImageURL']),
            )),
            Expanded(
                child: Center(
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      onFieldSubmitted: (value) {},
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
