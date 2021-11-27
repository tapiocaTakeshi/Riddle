import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();

  List<bool> CoOrIn;
  List<DocumentSnapshot> Slides;
  ResultPage({@required this.CoOrIn, @required this.Slides});
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
      ),
      body: ListView(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.CoOrIn.length,
              itemBuilder: (context, index) => Column(
                    children: [
                      Text('問題${(index + 1).toString()}'),
                      Text(widget.CoOrIn[index] ? '正解' : '不正解'),
                      Image.network(
                        widget.Slides[index]['expImageURL'],
                        height: 225,
                        width: 400,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      )
                    ],
                  )),
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
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          )
        ],
      ),
    );
  }
}
