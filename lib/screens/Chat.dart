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
  final user = FirebaseAuth.instance.currentUser;
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: CommentBox(
          userImage: user!.photoURL,
          textColor: Theme.of(context).textTheme.bodyText1!.color,
          backgroundColor: Theme.of(context).backgroundColor,
          sendWidget: Icon(
            Icons.send_sharp,
            size: 30,
            color: Theme.of(context).iconTheme.color,
          ),
          commentController: _controller,
          withBorder: false,
          sendButtonMethod: () {
            FirebaseFirestore.instance
                .collection('Riddles')
                .doc(widget.id)
                .collection('Chat')
                .add({'uid': user!.uid, 'comment': _controller.text});
          },
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Riddles')
                  .doc(widget.id)
                  .collection('Chat')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('エラー');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return ListView(
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot doc) =>
                              StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(doc['uid'])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              snapshot.data!['photoURL']),
                                        ),
                                        title: Text(doc['comment']),
                                      );
                                    }
                                    return Container();
                                  }))
                          .toList(),
                    );
                }
              }),
        ),
      ),
    );
  }
}
