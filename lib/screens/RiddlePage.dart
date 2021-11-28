import 'dart:async';

import 'package:Riddle/screens/ResultPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiddlePage extends StatefulWidget {
  @override
  _RiddlePageState createState() => _RiddlePageState();

  List<DocumentSnapshot> Slides;
  int index;
  int length;
  List<bool> CoOrIn;
  String id;

  RiddlePage(
      {@required this.Slides,
      @required this.index,
      @required this.length,
      @required this.CoOrIn,
      @required this.id});
}

class _RiddlePageState extends State<RiddlePage> {
  int count;
  Timer timer;
  int limit;
  String answer;
  String slideImageURL;
  bool isCorrect = false;
  bool isIncorrect = false;
  bool isComplete = false;

  void StartTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (count <= 0) {
            timer.cancel();
            count = 0;
            setState(() {
              widget.CoOrIn.add(false);
              isComplete = true;
            });
          } else {
            count--;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    limit = widget.Slides[widget.index]['limit'];
    answer = widget.Slides[widget.index]['answer'];
    slideImageURL = widget.Slides[widget.index]['slideImageURL'];
    count = limit;
    StartTimer();
  }

  @override
  Widget build(BuildContext context) {
    final MediaSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: !isComplete
              ? SingleChildScrollView(
                  // reverse: true,
                  child: SizedBox(
                      width: 400,
                      height: MediaSize.height,
                      child: Stack(children: [
                        Column(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Center(
                                  child: Image.network(
                                    slideImageURL,
                                    height: 225,
                                    width: 400,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Center(
                                    child: Text(
                                  '${(count ~/ 60).toString().padLeft(2, '0')}:${(count % 60).toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.headline3,
                                ))),
                            Expanded(
                                flex: 3,
                                child: Center(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 300,
                                        child: TextField(
                                          maxLength: 10,
                                          maxLines: 1,
                                          cursorColor: Colors.blueAccent,
                                          decoration: InputDecoration(
                                            errorStyle: TextStyle(fontSize: 0),
                                            filled: true,
                                            fillColor: Colors.white,
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent)),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.red)),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.red)),
                                          ),
                                          onSubmitted: (value) async {
                                            if (value == answer) {
                                              setState(() {
                                                isCorrect = true;
                                              });
                                              await Future<void>.delayed(
                                                  Duration(milliseconds: 500));

                                              setState(() {
                                                widget.CoOrIn.add(true);
                                                isComplete = true;
                                              });
                                            } else {
                                              setState(() {
                                                isIncorrect = true;
                                              });
                                              await Future<void>.delayed(
                                                  Duration(milliseconds: 500));
                                              setState(() {
                                                isIncorrect = false;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                        if (isCorrect)
                          Center(
                            child: Icon(
                              Icons.circle_outlined,
                              size: 250,
                              color: Colors.red,
                            ),
                          ),
                        if (isIncorrect)
                          Center(
                            child: Icon(
                              Icons.clear,
                              size: 250,
                              color: Colors.blue,
                            ),
                          )
                      ])),
                )
              : SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      Text(
                        widget.CoOrIn[widget.index] ? '正解' : '不正解',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      Card(
                        child: Image.network(
                          widget.Slides[widget.index]['expImageURL'],
                          height: 225,
                          width: 400,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      RaisedButton(
                          elevation: 1,
                          textColor: Colors.white,
                          color: Colors.blueAccent.withOpacity(0.9),
                          child: Text(
                            '次へ',
                            style: TextStyle(fontSize: 13),
                          ),
                          onPressed: () {
                            if (widget.index < widget.length - 1) {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (_) => RiddlePage(
                                            Slides: widget.Slides,
                                            index: widget.index + 1,
                                            length: widget.Slides.length,
                                            CoOrIn: widget.CoOrIn,
                                            id: widget.id,
                                          )));
                            } else {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (_) => ResultPage(
                                            CoOrIn: widget.CoOrIn,
                                            Slides: widget.Slides,
                                            id: widget.id,
                                          )));
                              print(widget.CoOrIn);
                            }
                          })
                    ],
                  ),
                )),
    );
  }
}
