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

  RiddlePage(
      {@required this.Slides,
      @required this.index,
      @required this.length,
      @required this.CoOrIn});
}

class _RiddlePageState extends State<RiddlePage> {
  int count;
  Timer timer;
  int limit;
  String answer;
  String slideImageURL;
  bool isCorrect = false;
  bool isIncorrect = false;

  void StartTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (count <= 0) {
            timer.cancel();
            count = 0;
            setState(() {
              widget.index++;
              widget.CoOrIn.add(false);
            });
            if (widget.index < widget.length) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => RiddlePage(
                        Slides: widget.Slides,
                        index: widget.index,
                        length: widget.Slides.length,
                        CoOrIn: widget.CoOrIn,
                      )));
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => ResultPage(
                        CoOrIn: widget.CoOrIn,
                        Slides: widget.Slides,
                      )));
              print(widget.CoOrIn);
            }
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
        body: SingleChildScrollView(
          // reverse: true,
          child: SizedBox(
            width: MediaSize.width,
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
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blueAccent)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                ),
                                onSubmitted: (value) async {
                                  if (value == answer) {
                                    setState(() {
                                      isCorrect = true;
                                    });
                                    await Future<void>.delayed(
                                        Duration(milliseconds: 500));
                                    setState(() {
                                      widget.index++;
                                      widget.CoOrIn.add(true);
                                    });
                                    if (widget.index < widget.length) {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (_) => RiddlePage(
                                                    Slides: widget.Slides,
                                                    index: widget.index,
                                                    length:
                                                        widget.Slides.length,
                                                    CoOrIn: widget.CoOrIn,
                                                  )));
                                    } else {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (_) => ResultPage(
                                                    CoOrIn: widget.CoOrIn,
                                                    Slides: widget.Slides,
                                                  )));
                                      print(widget.CoOrIn);
                                    }
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
            ]),
          ),
        ),
      ),
    );
  }
}
