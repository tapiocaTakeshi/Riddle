import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();

  List<bool> CoOrIn;
  List<DocumentSnapshot> Slides;
  String id;
  ResultPage({@required this.CoOrIn, @required this.Slides, @required this.id});
}

class _ResultPageState extends State<ResultPage> {
  double CAR;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.CoOrIn = [];
    CAR = widget.CoOrIn.fold(
            0, (previousValue, element) => previousValue + (element ? 1 : 0)) /
        widget.Slides.length *
        100;
    print(CAR);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Text(CAR.toString()),
          SizedBox(
            width: 300,
            child: RaisedButton(
                elevation: 1,
                textColor: Colors.white,
                color: Colors.blueAccent.withOpacity(0.9),
                child: Text(
                  '終了',
                  style: TextStyle(fontSize: 13),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();

                  await FirebaseFirestore.instance
                      .collection('Riddles')
                      .doc(widget.id)
                      .update({'answerCount': FieldValue.increment(1)});
                  await FirebaseFirestore.instance
                      .collection('Riddles')
                      .doc(widget.id)
                      .update({'CARsum': FieldValue.increment(CAR)});
                }),
          )
        ],
      ),
    );
  }
}
