import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Firebase.dart';
import '../Loading.dart';
import '../Upload.dart';


class UploadScreen2 extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => UploadScreen2State();
  List<String> answers;
  List<Duration> durations;
  List<File> slideImageFiles;

  UploadScreen2(this.answers, this.durations, this.slideImageFiles);
}

class UploadScreen2State extends State<UploadScreen2>{
  final _formkey=GlobalKey<FormState>();
  File thumbnailImageFile;
  Image thumbnailImage;
  String _title='';
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Form(
      key: _formkey,
      child: Stack(
        children: [
          ListView(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'タイトル',
                        style: TextStyle(
                            color: Colors.blueAccent, fontSize: 20),
                      ),
                    ),
                    Center(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: TextFormField(
                                initialValue: _title,
                                validator: (value){
                                  if(value.isNotEmpty){
                                    return null;
                                  }
                                  else {
                                    return 'タイトルを入力してください';
                                  }
                                },
                                onChanged: (value){
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
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:Colors.red))
                                )
                            ),
                            width: 300,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'サムネイル',
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 20),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: <Widget>[
                            RaisedButton(
                                elevation: 1,
                                child: Text('JPGファイルを選択'),
                                onPressed: () async {

                                  String thumbnailPath = '';
                                  thumbnailPath = await JpgUpload();
                                  setState(() {
                                    visible = true;
                                  });
                                  thumbnailImageFile = File(thumbnailPath);
                                  thumbnailImage = Image.memory(
                                    await thumbnailImageFile.readAsBytes(),
                                    filterQuality: FilterQuality.high,
                                  );
                                  setState(() {
                                    visible = false;
                                  });
                                }),
                            if (thumbnailImage != null)
                              Container(
                                child: thumbnailImage,
                                height: 150,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 0.35)),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      if (!_formkey.currentState.validate()) {
                        _formkey.currentState.save();

                        if (widget.slideImageFiles == null &&
                            thumbnailImageFile == null) {
                          DocumentReference snapshotRiddle;
                          setState(() {
                            visible = true;
                          });
                          snapshotRiddle =
                          await FirebaseFirestore.instance.collection('Riddles').add(
                              {
                                'title': _title,
                                'explanation': '',
                                'date': DateTime.now()
                              }
                          );
                          print('a');

                          //サムネイルをアップロード
                          String thumbnailURL = await uploadImage(
                              thumbnailImageFile,
                              'Riddles/${snapshotRiddle
                                  .id}/thumbnailImageFile.jpg');

                          await FirebaseFirestore.instance.collection('Riddles').doc(
                              snapshotRiddle.id).update(
                              {'thumbnailURL': thumbnailURL});

                          //スライドをアップロード
                            widget.slideImageFiles.asMap().forEach((index, value)  async {
                              var url = await uploadImage(value, 'Riddles/${snapshotRiddle.id}/Slides/${value.path.split('/').last}');
                              print(url);
                              await FirebaseFirestore.instance.collection('Riddles').doc(snapshotRiddle.id)
                                  .collection('Slides').doc(index.toString())
                                  .set({
                                'slideImageURL': url,
                                'answer': widget.answers[index],
                                'limit': widget.durations[index].inSeconds,
                              });
                            });
                          setState(() {
                            visible = false;
                          });
                          Navigator.of(context).pop();
                        }
                      }
                    }
                ),
              ),
            ),
          ],
        ),
          OverlayLoadingMolecules(visible: visible),
      ]
      ),
    );
  }

}