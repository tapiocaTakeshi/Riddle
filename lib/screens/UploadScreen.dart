import 'dart:io';
import 'package:Riddle/screens/UploadScreen2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Upload.dart';
import '../Loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Firebase.dart';

class UploadScreen extends StatefulWidget {
  @override
  UploadScreenState createState() => new UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  final _formkey=GlobalKey<FormState>();
  String slidePath = '';
  List<Image> slideImages=[];
  List<File> slideImageFiles;
  List<String> answers;
  List<Duration> durations;
  bool visible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 1,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UploadScreen2(answers, durations, slideImageFiles)));
          }, icon: Icon(Icons.arrow_forward_ios))
        ],
      ),
      body: Form(
        key: _formkey,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: ListView(
                children: <Widget>[
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
                                '問題',
                                style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 20),
                              ),
                            ),
                            Center(
                              child: Column(
                                children: <Widget>[
                                  RaisedButton(
                                    elevation: 1,
                                    child: Text('PDFファイルを選択'),
                                    onPressed: () async {
                                      slidePath = await PdfUpload();
                                      setState(() {
                                        visible = true;
                                      });
                                      //pdf->images
                                      final slideImageBytes = await SplitPdf(slidePath);
                                      slideImageBytes.asMap().forEach((index, value) {
                                        slideImages.add(Image.memory(value,filterQuality: FilterQuality.high,));
                                      });

                                      final Directory systemTempDir = Directory.systemTemp;
                                      //images->jpgs
                                      final slideImageFiles = List.generate(
                                          slideImageBytes.length, (index) => File(
                                          '${systemTempDir.path}/slideImage${index
                                              .toString()}.jpg'));

                                      slideImageFiles.asMap().forEach((index, value) {
                                        value..writeAsBytesSync(slideImageBytes[index]);
                                      });

                                      answers = List.generate(
                                          slideImageFiles.length, (index) => '');
                                      durations = List.generate(
                                          slideImageFiles.length, (index) => Duration.zero);
                                      setState(() {
                                        visible = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (slideImages != null)
                    ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: slideImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "問題" + (index + 1).toString(),
                                      style: TextStyle(
                                          color: Colors.blueAccent, fontSize: 15),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: slideImages[index],
                                          height: 150,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey, width: 0.35)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Divider(
                                            thickness: 1,
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Container(
                                            child: TextFormField(
                                              initialValue: answers[index],
                                                validator: (value){
                                                  if(value.isNotEmpty){
                                                    return null;
                                                  }
                                                  else {
                                                    return '答えを入力してください';
                                                  }
                                                },
                                                onChanged: (value){
                                                  this.answers[index] = value;
                                                },
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      20)
                                                ],
                                                maxLines: 1,
                                                cursorColor: Colors
                                                    .blueAccent,
                                                decoration: InputDecoration(
                                                  labelText: '答え',
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey)
                                                    ),
                                                    focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .blueAccent)
                                                    ),
                                                  focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.red
                                                      )
                                                    ),
                                                )
                                            ),
                                            width: 300,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Divider(
                                            thickness: 1,
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            '制限時間',
                                            style: TextStyle(
                                                color: Colors.blueAccent, fontSize: 15),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Container(
                                            // width: 80,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceAround,
                                              children: [
                                                Container(
                                                  child: CupertinoTimerPicker(
                                                    initialTimerDuration: durations[index],
                                                    mode: CupertinoTimerPickerMode.ms,
                                                    onTimerDurationChanged: (duration){
                                                      setState(() {
                                                        this.durations[index] = duration;
                                                      });
                                                    },
                                                  ),

                                                  height: 200,
                                                  // width: 100,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                ],
              ),
            ),
            OverlayLoadingMolecules(visible: visible),
          ],
        ),
      ),
    );
  }
}

