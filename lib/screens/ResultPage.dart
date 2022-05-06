import 'package:Riddle/functions/Firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();

  List<bool>? CoOrIn;
  List<DocumentSnapshot>? Slides;
  String? id;
  ResultPage({this.CoOrIn, this.Slides, this.id});
}

class _ResultPageState extends State<ResultPage> {
  int? CorrectAnswer;
  double? CorrectAnswerRate;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CorrectAnswer = widget.CoOrIn!.fold(
        0, (previousValue, element) => previousValue! + (element ? 1 : 0));
    CorrectAnswerRate = CorrectAnswer! / widget.Slides!.length * 100;
    print(CorrectAnswerRate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '採点結果',
              style: Theme.of(context).textTheme.headline3,
            ),
            Text(
              CorrectAnswer.toString() + '/' + widget.Slides!.length.toString(),
              style: Theme.of(context).textTheme.headline2,
            ),
            SizedBox(
              width: 300,
              child: ElevatedButton(
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
                        .update({
                      'CorrectAnswerRatesum':
                          FieldValue.increment(CorrectAnswerRate!)
                    });
                    final riddleData = await getData('Riddles', widget.id!);
                    await FirebaseFirestore.instance
                        .collection('Riddles')
                        .doc(widget.id)
                        .update({
                      'CorrectAnswerRatemean':
                          riddleData['CorrectAnswerRatesum'] /
                              riddleData['answerCount']
                    });
                  }),
            )
          ],
        ),
      ),
    );
  }
}
