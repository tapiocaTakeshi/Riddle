import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/screens/Chat.dart';
import 'package:Riddle/screens/RiddlePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

const int maxFailedLoadAttempts = 3;

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DetailPageState();

  final String id;
  final String title;
  final String image;
  final VoidCallback onPressed;

  DetailPage({
    @required this.id,
    @required this.title,
    @required this.image,
    this.onPressed,
  });
}

class DetailPageState extends State<DetailPage> {
  final user = FirebaseAuth.instance.currentUser;
  var isLiked = false;
  var AnswerCountText = '';
  var CorrectAnswerRateText = '';
  List<bool> CoOrIn;

  InterstitialAd interstitial;
  int _interstitialLoadAttempts = 0;

  void interCreate() {
    AdState adState = Provider.of<AdState>(context, listen: false);
    adState.initialization;
    InterstitialAd.load(
        adUnitId: adState.InterstitialAdId,
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

  void interShow() {
    if (interstitial != null) {
      interstitial.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        interCreate();
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        interCreate();
      });
      interstitial.show();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future(() async {
      interCreate();
      Map<String, dynamic> data1 = (await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get())
          .data();
      isLiked = (data1['FavoriteRiddleList'] as List).contains(widget.id);
      final Map<String, dynamic> data2 = (await FirebaseFirestore.instance
              .collection('Riddles')
              .doc(widget.id)
              .get())
          .data();
      setState(() {
        if (data2['answerCount'] >= 100000000) {
          AnswerCountText =
              '${(data2['answerCount'] / 100000000).toStringAsFixed(1)}億回解答';
        } else if (data2['answerCount'] >= 10000) {
          AnswerCountText =
              '${(data2['answerCount'] / 10000).toStringAsFixed(1)}万回解答';
        } else {
          AnswerCountText = '${data2['answerCount']}回解答';
        }
      });
      if (data2['answerCount'] != null &&
          data2['CorrectAnswerRatesum'] != null) {
        CorrectAnswerRateText =
            '　正答率${(data2['CorrectAnswerRatesum'] / data2['answerCount']).toStringAsFixed(1)}%';
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    interstitial?.dispose();
  }

  void updateLike() async {
    isLiked
        ? await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
            'FavoriteRiddleList': FieldValue.arrayUnion([widget.id])
          })
        : await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
            'FavoriteRiddleList': FieldValue.arrayRemove([widget.id])
          });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Container(
              width: 400,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(widget.image,
                          width: size.width,
                          height: size.width * 9 / 16,
                          fit: BoxFit.cover),
                      elevation: 0,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(AnswerCountText + CorrectAnswerRateText)
                              ],
                            ),
                            width: double.infinity),
                      ),
                      Row(
                        children: <Widget>[
                          LikedButton(isLiked),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CommentButton(),
                          )
                        ],
                      ),
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('Riddles')
                              .doc(widget.id)
                              .get(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(snapshot.data['uid'])
                                      .get(),
                                  builder: (context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasData) {
                                      return InkWell(
                                        onTap: () {},
                                        child: Row(
                                          children: <Widget>[
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot.data['photoURL']),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              child: Text(
                                                snapshot.data['name'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  });
                            } else {
                              return Container();
                            }
                          }),
                      ButtonTheme(
                        minWidth: size.width,
                        child: RaisedButton(
                            elevation: 1,
                            textColor: Colors.white,
                            color: Colors.blueAccent.withOpacity(0.9),
                            child: Text(
                              '問題を解く',
                              style: TextStyle(fontSize: 13),
                            ),
                            onPressed: () async {
                              List<DocumentSnapshot> Slides =
                                  await FirebaseFirestore.instance
                                      .collection('Riddles')
                                      .doc(widget.id)
                                      .collection('Slides')
                                      .get()
                                      .then((value) => value.docs);
                              setState(() {
                                CoOrIn = [];
                              });

                              var index = 0;
                              interShow();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => RiddlePage(
                                          Slides: Slides,
                                          index: index,
                                          length: Slides.length,
                                          CoOrIn: CoOrIn,
                                          id: widget.id,
                                        )),
                              );
                            }),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget LikedButton(bool isLiked) {
    final icon = this.isLiked ? Icons.favorite : Icons.favorite_outline;
    return IconButton(
        onPressed: () {
          setState(() {
            this.isLiked = !isLiked;
          });
          updateLike();
        },
        icon: Icon(
          icon,
          color: Theme.of(context).iconTheme.color,
          size: 35,
        ));
  }

  Widget CommentButton() {
    return IconButton(
        onPressed: () {
          showChat(context, widget.id);
        },
        icon: Icon(
          Icons.chat_bubble_outline_rounded,
          color: Theme.of(context).iconTheme.color,
          size: 35,
        ));
  }
}
