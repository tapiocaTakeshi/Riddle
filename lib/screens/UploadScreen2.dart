import 'dart:io';
import 'dart:typed_data';
import 'package:Riddle/ThumbnailModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Firebase.dart';
import '../Loading.dart';

class UploadScreen2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UploadScreen2State();
  List<String> answers;
  List<Duration> durations;
  List<Uint8List> slideImageBytes;

  UploadScreen2(this.answers, this.durations, this.slideImageBytes);
}

class UploadScreen2State extends State<UploadScreen2> {
  final _formkey = GlobalKey<FormState>();
  String _title = '';
  Color thumbnailTextColor = Colors.black45;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<ThumbnailModel>(
      create: (_) => ThumbnailModel(),
      child: Consumer<ThumbnailModel>(builder: (context, model, child) {
        return Stack(fit: StackFit.expand, children: [
          GestureDetector(
            onTap: () =>
                FocusScope.of(context).requestFocus(FocusNode()),
            child: Scaffold(
              appBar: AppBar(),
              body: Form(
                key: _formkey,
                child: ListView(
                  children: [
                    Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child:
                                InkWell(
                                  onTap: () => model.setThumbnail(),
                                  child: model.thumbnailImage == null ?
                                  Container(
                                    child: Center(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('サムネイル画像（JPG）を選択',
                                              style: TextStyle(color: thumbnailTextColor,fontSize: 15),
                                            ),
                                            Text('縦横比　9:16',
                                              style: TextStyle(color: Colors.blueAccent,fontSize: 10),
                                            ),
                                          ],
                                        )
                                    ),
                                    height: 135,
                                    width: 240,
                                    color: Colors.grey,
                                  )
                                      :model.thumbnailImage
                                ),
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
                                    validator: (value) {
                                      if (value.isNotEmpty) {
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
                                            borderSide: BorderSide(
                                                color: Colors.grey)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blueAccent)),
                                        focusedErrorBorder:
                                            OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.red)))),
                                width: 300,
                              ),
                            ],
                          ),
                        )),
                    Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 110,
                        child: RaisedButton(
                            elevation: 1,
                            textColor: Colors.white,
                            color: Colors.blueAccent.withOpacity(0.9),
                            child: Text(
                              'アップロード',
                              style: TextStyle(fontSize: 13),
                            ),
                            onPressed: () async {
                              if (_formkey.currentState.validate() &&
                                  model.thumbnailImage != null) {
                                _formkey.currentState.save();
                                setState(() {
                                  model.visible = true;
                                });
                                final snapshotRiddle = await FirebaseFirestore
                                    .instance
                                    .collection('Riddles')
                                    .add({
                                  'title': _title,
                                  'explanation': '',
                                  'date': DateTime.now(),
                                  'answerCount':0
                                });

                                //作成したユーザーと紐付ける
                                await FirebaseFirestore.instance.collection('Users').doc(user.uid).update(
                                    {
                                      'MyRiddleList':FieldValue.arrayUnion([snapshotRiddle.id])
                                    });

                                //サムネイルをアップロード
                                String thumbnailURL = await uploadImage(
                                    model.thumbnailImageFile,
                                    'Riddles/${snapshotRiddle.id}/thumbnailImageFile.jpg');


                                await FirebaseFirestore.instance
                                    .collection('Riddles')
                                    .doc(snapshotRiddle.id)
                                    .update({
                                  'thumbnailURL': thumbnailURL,
                                  'id' : snapshotRiddle.id.toString(),
                                  'uid' :user.uid
                                    });


                                //slide: images->jpgs
                                final Directory systemTempDir =
                                    Directory.systemTemp;

                                List<File> slideImageFiles = List.generate(
                                    widget.slideImageBytes.length,
                                    (index) => File(
                                        '${systemTempDir.path}/slideImage${index.toString()}.jpg'));

                                slideImageFiles.asMap().forEach((index, value) {
                                  value
                                    ..writeAsBytesSync(
                                        widget.slideImageBytes[index]);
                                });

                                //スライドをアップロード
                                slideImageFiles
                                    .asMap()
                                    .forEach((index, value) async {
                                  var url = await uploadImage(value,
                                      'Riddles/${snapshotRiddle.id}/Slides/${value.path.split('/').last}');
                                  print(url);
                                  await FirebaseFirestore.instance
                                      .collection('Riddles')
                                      .doc(snapshotRiddle.id)
                                      .collection('Slides')
                                      .doc(index.toString())
                                      .set({
                                    'slideImageURL': url,
                                    'answer': widget.answers[index],
                                    'limit': widget.durations[index].inSeconds,
                                  });
                                });
                                setState(() {
                                  model.visible = false;
                                });
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              }else if (model.thumbnailImage == null){
                                setState(() {
                                  thumbnailTextColor = Colors.red;
                                });
                              }
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          OverlayLoadingMolecules(visible: model.visible),
        ]);
      }),
    );
  }
}
