import 'package:Riddle/MyApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showChat(BuildContext context, String id) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ChatPage(
                id: id,
              )));
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
  String? id;

  ChatPage({this.id});
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            elevation: 1,
          ),
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUser!.uid)
                .get(),
            builder: (context, user) {
              if (user.hasData) {
                return CommentBox(
                  userImage: user.data!['photoURL'],
                  textColor: Theme.of(context).textTheme.bodyText1!.color,
                  backgroundColor: Theme.of(context).backgroundColor,
                  sendWidget: Icon(
                    Icons.send_sharp,
                    size: 30,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  commentController: _controller,
                  withBorder: false,
                  sendButtonMethod: () async {
                    await FirebaseFirestore.instance
                        .collection('Riddles')
                        .doc(widget.id)
                        .collection('Chat')
                        .add({
                      'uid': currentUser!.uid,
                      'comment': _controller.text,
                      'date': DateTime.now()
                    }).then((value) => _controller.clear());
                  },
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Riddles')
                          .doc(widget.id)
                          .collection('Chat')
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: (context, chat) {
                        if (chat.hasError) return Text('エラー');
                        switch (chat.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return ListView(
                              shrinkWrap: true,
                              children: chat.data!.docs
                                  .map((DocumentSnapshot doc) =>
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(doc['uid'])
                                              .snapshots(),
                                          builder: (context, user) {
                                            if (user.hasData) {
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      user.data!['photoURL']),
                                                ),
                                                title: Text(doc['comment']),
                                                subtitle:
                                                    Text(user.data!['name']),
                                              );
                                            }
                                            return Container();
                                          }))
                                  .toList(),
                            );
                        }
                      }),
                );
              } else {
                return Container();
              }
            }),
      ),
    );
  }
}
