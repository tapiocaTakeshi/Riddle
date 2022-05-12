import 'dart:io';
import 'dart:typed_data';
import 'package:Riddle/main.dart';
import 'package:Riddle/models/SlideModel.dart';
import 'package:Riddle/models/ThumbnailModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../functions/Firebase.dart';
import '../functions/Loading.dart';

class UploadScreen2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UploadScreen2State();
  List<String>? answers;
  List<Duration>? durations;
  List<File>? slideImageFiles;
  List<File>? expImageFiles;

  UploadScreen2(
      this.answers, this.durations, this.slideImageFiles, this.expImageFiles);
}

class UploadScreen2State extends State<UploadScreen2> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _formkey = GlobalKey<FormState>();
  String _title = '';
  Color thumbnailTextColor = Colors.black45;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<ThumbnailModel>(builder: (context, model, child) {
      return Stack(fit: StackFit.expand, children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: AppBar(
                elevation: 1,
              ),
            ),
            body: Form(
              key: _formkey,
              child: ListView(
                children: [
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: InkWell(
                              onTap: () async {
                                model.setThumbnail();
                              },
                              child: model.thumbnailPath == ''
                                  ? Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300)),
                                      child: Container(
                                        child: Center(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'サムネイル用画像（JPG）を選択',
                                              style: TextStyle(
                                                  color: thumbnailTextColor,
                                                  fontSize: 15),
                                            ),
                                            Text(
                                              '縦横比　9:16',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10),
                                            ),
                                          ],
                                        )),
                                        height: 135,
                                        width: 240,
                                        color: Colors.grey[100],
                                      ),
                                    )
                                  : model.thumbnailImage),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'タイトル',
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 20),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                              initialValue: _title,
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'タイトルを入力してください';
                                }
                              },
                              onChanged: (value) {
                                this._title = value;
                              },
                              maxLength: 20,
                              maxLines: 2,
                              cursorColor: Colors.blueAccent,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blueAccent)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.red)))),
                          width: 300,
                        ),
                      ],
                    ),
                  )),
                  ElevatedButton(
                      child: Text(
                        'アップロード',
                        style: TextStyle(fontSize: 13),
                      ),
                      onPressed: () async {
                        if (_formkey.currentState!.validate() &&
                            model.thumbnailImage != null) {
                          _formkey.currentState!.save();
                          setState(() {
                            model.visible = true;
                          });
                          print('a');
                          final snapshotRiddle = await FirebaseFirestore
                              .instance
                              .collection('Riddles')
                              .add({
                            'title': _title,
                            'explanation': '',
                            'date': DateTime.now(),
                            'answerCount': 0
                          });

                          //作成したユーザーと紐付ける
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(currentUser!.uid)
                              .update({
                            'MyRiddleList':
                                FieldValue.arrayUnion([snapshotRiddle.id])
                          });

                          //スライドをアップロード
                          widget.slideImageFiles!
                              .asMap()
                              .forEach((index, value) async {
                            var slideurl = await uploadImage(value,
                                'Riddles/${snapshotRiddle.id}/Slides/${value.path.split('/').last}');
                            var expurl = await uploadImage(
                                widget.expImageFiles![index],
                                'Riddles/${snapshotRiddle.id}/Slides/${widget.expImageFiles![index].path.split('/').last}');
                            print(slideurl);
                            print(expurl);
                            await FirebaseFirestore.instance
                                .collection('Riddles')
                                .doc(snapshotRiddle.id)
                                .collection('Slides')
                                .doc(index.toString())
                                .set({
                              'slideImageURL': slideurl,
                              'expImageURL': expurl,
                              'answer': widget.answers![index],
                              'limit': widget.durations![index].inSeconds,
                            });
                          });

                          //サムネイルをアップロード
                          String thumbnailURL = await uploadImage(
                              model.thumbnailImageFile!,
                              'Riddles/${snapshotRiddle.id}/thumbnailImageFile.jpg');
                          print(thumbnailURL);
                          await FirebaseFirestore.instance
                              .collection('Riddles')
                              .doc(snapshotRiddle.id)
                              .update({
                            'thumbnailURL': thumbnailURL,
                            'id': snapshotRiddle.id.toString(),
                            'uid': currentUser!.uid
                          });
                          Provider.of<SlideModel>(context, listen: false)
                              .deleteSlide();
                          Provider.of<ThumbnailModel>(context, listen: false)
                              .deleteThumbnail();

                          setState(() {
                            model.visible = false;
                          });
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        } else if (model.thumbnailImage == null) {
                          setState(() {
                            thumbnailTextColor = Colors.red;
                          });
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
        OverlayLoadingMolecules(visible: model.visible),
      ]);
    });
  }
}
