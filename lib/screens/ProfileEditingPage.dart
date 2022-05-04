import 'dart:io';

import 'package:Riddle/functions/Firebase.dart';
import 'package:Riddle/functions/Upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileEditingPage extends StatefulWidget {
  ProfileEditingPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditingPage> createState() => _ProfileEditingPageState();
}

class _ProfileEditingPageState extends State<ProfileEditingPage> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(snapshot.data!['photoURL'])),
                    onTap: () async {
                      final imageFile = await imagePicker();
                      if (imageFile == null) return;
                      final downloadURL =
                          await uploadImage(imageFile, 'Users/' + user!.uid);
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user!.uid)
                          .update({'photoURL': downloadURL});
                    },
                  ),
                  Padding(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '名前',
                      ),
                      onSubmitted: (value) async {
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user!.uid)
                            .update({'name': value});
                      },
                    ),
                    padding: EdgeInsets.all(20.0),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
