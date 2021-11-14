import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';

void showChat(BuildContext context,String id){
  showModalBottomSheet(
    isScrollControlled: true,
      enableDrag: false,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      context: context,
      builder: (_) => Container(
        height: 600,
        child: CommentBox(

          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Riddles').doc(id).collection('Chat').snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasError) return Text('エラー');
              switch (snapshot.connectionState){
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  return ListView(
                    children: snapshot.data.docs.map(
                            (DocumentSnapshot doc) =>
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('Users').doc(doc['uid']).snapshots(),
                                  builder: (context, snapshot) {
                                    if(snapshot.hasData){
                                      return ListTile(
                                        leading: CircleAvatar(backgroundImage: NetworkImage(snapshot.data['photoURL']),),
                                        title: Text(doc['comment']),
                                      );
                                    }
                                    return Container();
                                  }
                                )
                    ).toList(),
                  );
              }
            }
          ),
        ),
      )
  );
}