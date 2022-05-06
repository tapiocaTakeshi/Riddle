import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/functions/Firebase.dart';
import 'package:Riddle/main.dart';
import 'package:Riddle/screens/AccountScreen.dart';
import 'package:Riddle/screens/Chat.dart';
import 'package:Riddle/screens/MyAccountScreen.dart';
import 'package:Riddle/screens/ReportPage.dart';
import 'package:Riddle/screens/RiddlePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  var isLiked = false;
  var isSubscribed = false;
  var AnswerCountText = '';
  var CorrectAnswerRateText = '';
  List<bool> CoOrIn = [];
  Map<String, dynamic> data1 = Map();
  Map<String, dynamic> data2 = Map();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future(() async {
      data1 = await getData('Users', currentUser!.uid);
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
      if (data2['answerCount'] != null &&
          data2['CorrectAnswerRatesum'] != null) {
        CorrectAnswerRateText =
            '　正答率${(data2['CorrectAnswerRatemean']).toStringAsFixed(1)}';
      }
    });
  }

  void updateLike() async {
    isLiked
        ? await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .update({
            'FavoriteRiddleList': FieldValue.arrayUnion([widget.id])
          })
        : await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .update({
            'FavoriteRiddleList': FieldValue.arrayRemove([widget.id])
          });
  }

  void updateSubscribe() async {
    isSubscribed
        ? await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .update({
            'SubscribedChannelList': FieldValue.arrayUnion([data2['uid']])
          })
        : await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
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
      body: SingleChildScrollView(
        child: Column(
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
                    FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Riddles')
                            .doc(widget.id)
                            .get(),
                        builder: (context, riddle) {
                          if (riddle.hasData) {
                            return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(riddle.data!['uid'])
                                    .get(),
                                builder: (context, user) {
                                  if (user.hasData) {
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        widget.title!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                      Spacer(),
                                                      IconButton(
                                                          onPressed: () {
                                                            showCupertinoModalPopup(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        CupertinoActionSheet(
                                                                          actions: [
                                                                            CupertinoActionSheetAction(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                  Navigator.of(context).push(MaterialPageRoute(builder: ((context) => ReportPage(riddle.data!['uid']))));
                                                                                },
                                                                                child: Text('この投稿を通報する'))
                                                                          ],
                                                                          cancelButton: CupertinoActionSheetAction(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Text('キャンセル')),
                                                                        ));
                                                          },
                                                          icon: Icon(
                                                              CupertinoIcons
                                                                  .flag))
                                                    ],
                                                  ),
                                                  Text(AnswerCountText +
                                                      CorrectAnswerRateText)
                                                ],
                                              ),
                                              width: double.infinity),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            LikedButton(isLiked),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: CommentButton(),
                                            )
                                          ],
                                        ),
                                        Divider(),
                                        InkWell(
                                          onTap: () {
                                            if (data2['uid'] ==
                                                currentUser!.uid) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          MyAccountScreen()));
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          AccountScreen(riddle
                                                              .data!['uid'])));
                                            }
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    user.data!['photoURL']),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: Text(
                                                  user.data!['name'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Spacer(),
                                              if (data2['uid'] !=
                                                  currentUser!.uid)
                                                FlatButton(
                                                  child: isSubscribed
                                                      ? Text('登録済み',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey))
                                                      : Text('チャンネル登録',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
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
                                        ),
                                        Divider(),
                                        ElevatedButton(
                                            child: Text(
                                              '問題を解く',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                CoOrIn = [];
                                              });

                                              List<DocumentSnapshot> Slides =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Riddles')
                                                      .doc(widget.id)
                                                      .collection('Slides')
                                                      .get()
                                                      .then((value) =>
                                                          value.docs);
                                              var index = 0;
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          RiddlePage(
                                                            Slides: Slides,
                                                            index: index,
                                                            length:
                                                                Slides.length,
                                                            CoOrIn: CoOrIn,
                                                            id: widget.id,
                                                          )));
                                            })
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                });
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        })
                  ],
                ),
              ),
            )
          ],
        ),
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
