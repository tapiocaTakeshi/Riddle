import 'dart:async';

import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/screens/ResultPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const int maxFailedLoadAttempts = 3;

class RiddlePage extends StatefulWidget {
  @override
  _RiddlePageState createState() => _RiddlePageState();

  List<DocumentSnapshot>? Slides;
  int? index;
  int? length;
  List<bool>? CoOrIn;
  String? id;

  RiddlePage({this.Slides, this.index, this.length, this.CoOrIn, this.id});
}

class _RiddlePageState extends State<RiddlePage> {
  late int count;
  Timer? timer;
  int? limit;
  String? answer;
  String? slideImageURL;
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
              widget.CoOrIn!.add(false);
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
    interCreate();
    limit = widget.Slides![widget.index!]['limit'];
    answer = widget.Slides![widget.index!]['answer'];
    slideImageURL = widget.Slides![widget.index!]['slideImageURL'];
    count = limit!;
    StartTimer();
  }

  InterstitialAd? interstitial;
  int _interstitialLoadAttempts = 0;

  void interCreate() {
    InterstitialAd.load(
        adUnitId: AdState.InterstitialAdId,
        request: AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          interstitial = ad;
          _interstitialLoadAttempts = 0;
          print('ok');
        }, onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts += 1;
          interstitial = null;
          if (_interstitialLoadAttempts >= maxFailedLoadAttempts) interCreate();
          print('not ok');
        }));
  }

  void interShow() async {
    if (interstitial != null) {
      interstitial!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        interCreate();
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        interCreate();
      });
      await interstitial!.show();
      print('a');
    }
  }

  void onSubmitted(value) async {
    if (value == answer) {
      setState(() {
        isCorrect = true;
      });
      await Future<void>.delayed(Duration(milliseconds: 500));

      setState(() {
        isCorrect = false;
        widget.CoOrIn!.add(true);
        isComplete = true;
      });
    } else {
      setState(() {
        isIncorrect = true;
      });
      await Future<void>.delayed(Duration(milliseconds: 500));
      setState(() {
        isIncorrect = false;
      });
    }
  }

  Widget ChatBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration:
          BoxDecoration(color: Theme.of(context).primaryColor, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 1,
          spreadRadius: 1,
        ),
      ]),
      child: Center(
        child: Container(
          height: 40,
          width: 300,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(35.0),
              border: Border.all(color: Colors.grey)),
          child: Center(
            child: TextField(
                maxLines: 1,
                decoration:
                    InputDecoration(border: InputBorder.none, hintText: '解答欄'),
                onSubmitted: onSubmitted),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      left: false,
      right: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: !isComplete
                ? Stack(children: [
                    Column(
                      children: [
                        Center(
                          child: Image.network(
                            slideImageURL!,
                            width: size.width,
                            height: size.width * 9 / 16,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                              onPressed: () => Navigator.popUntil(
                                  context, (route) => route.isFirst),
                              child: Text('解くのをやめる')),
                        ),
                        Expanded(
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${(count ~/ 60).toString().padLeft(2, '0')}:${(count % 60).toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          )),
                        ),
                        ChatBox(),
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
                  ])
                : Center(
                    child: Column(
                      children: [
                        Text(
                          widget.CoOrIn![widget.index!] ? '正解' : '不正解',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        Card(
                          child: Image.network(
                            widget.Slides![widget.index!]['expImageURL'],
                            width: size.width,
                            height: size.width * 9 / 16,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        ElevatedButton(
                            child: Text(
                              '次へ',
                              style: TextStyle(fontSize: 13),
                            ),
                            onPressed: () {
                              if (widget.index! < widget.length! - 1) {
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                        builder: (_) => RiddlePage(
                                              Slides: widget.Slides,
                                              index: widget.index! + 1,
                                              length: widget.Slides!.length,
                                              CoOrIn: widget.CoOrIn,
                                              id: widget.id,
                                            )));
                              } else {
                                interShow();
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                        builder: (_) => ResultPage(
                                              CoOrIn: widget.CoOrIn!,
                                              Slides: widget.Slides!,
                                              id: widget.id!,
                                            )));
                                print(widget.CoOrIn);
                              }
                            })
                      ],
                    ),
                  )),
      ),
    );
  }
}
