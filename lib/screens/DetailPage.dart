import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/functions/Firebase.dart';
import 'package:Riddle/screens/AccountScreen.dart';
import 'package:Riddle/screens/Chat.dart';
import 'package:Riddle/screens/RiddlePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DetailPageState();

  final String? id;
  final String? title;
  final String? image;
  final VoidCallback? onPressed;

  DetailPage({
    this.id,
    this.title,
    this.image,
    this.onPressed,
    int? index,
  });
}

class DetailPageState extends State<DetailPage> {
  final user = FirebaseAuth.instance.currentUser;
  var isLiked = false;
  var isSubscribed = false;
  var AnswerCountText = '';
  var CARText = '';
  List<bool> CoOrIn = [];
  Map<String, dynamic> data1 = Map();
  Map<String, dynamic> data2 = Map();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future(() async {
      data1 = await getData('Users', user!.uid);
      data2 = await getData('Riddles', widget.id!);
      isLiked = (data1['FavoriteRiddleList'] as List).contains(widget.id);
      isSubscribed =
          (data1['SubscribedChannelList'] as List).contains(data2['uid']);

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
      if (data2['answerCount'] != null && data2['CARsum'] != null) {
        CARText =
            '　正答率${(data2['CARsum'] / data2['answerCount']).toStringAsFixed(1)}%';
      }
    });
  }

  void updateLike() async {
    isLiked
        ? await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .update({
            'FavoriteRiddleList': FieldValue.arrayUnion([widget.id])
          })
        : await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .update({
            'FavoriteRiddleList': FieldValue.arrayRemove([widget.id])
          });
  }

  void updateSubscribe() async {
    isSubscribed
        ? await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .update({
            'SubscribedChannelList': FieldValue.arrayUnion([data2['uid']])
          })
        : await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .update({
            'SubscribedChannelList': FieldValue.arrayRemove([data2['uid']])
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
                      child: Image.network(widget.image!,
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
                                  widget.title!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(AnswerCountText + CARText)
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
                              AsyncSnapshot<DocumentSnapshot> snapshot1) {
                            if (snapshot1.hasData) {
                              return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(snapshot1.data!['uid'])
                                      .get(),
                                  builder: (context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot2) {
                                    if (snapshot2.hasData) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) => AccountScreen(
                                                      data2['uid'])));
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot2.data!['photoURL']),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              child: Text(
                                                snapshot2.data!['name'],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Spacer(),
                                            FlatButton(
                                              child: isSubscribed
                                                  ? Text('登録済み',
                                                      style: TextStyle(
                                                          color: Colors.grey))
                                                  : Text('チャンネル登録',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                              onPressed: () {
                                                setState(() {
                                                  this.isSubscribed =
                                                      !isSubscribed;
                                                });
                                                updateSubscribe();
                                              },
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
                              setState(() {
                                CoOrIn = [];
                              });

                              List<DocumentSnapshot> Slides =
                                  await FirebaseFirestore.instance
                                      .collection('Riddles')
                                      .doc(widget.id)
                                      .collection('Slides')
                                      .get()
                                      .then((value) => value.docs);
                              var index = 0;
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => RiddlePage(
                                        Slides: Slides,
                                        index: index,
                                        length: Slides.length,
                                        CoOrIn: CoOrIn,
                                        id: widget.id,
                                      )));
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
          showChat(context, widget.id!);
        },
        icon: Icon(
          Icons.chat_bubble_outline_rounded,
          color: Theme.of(context).iconTheme.color,
          size: 35,
        ));
  }
}
