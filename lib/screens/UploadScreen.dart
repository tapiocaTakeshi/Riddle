import 'package:Riddle/screens/UploadScreen2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../SlideModel.dart';
import '../Upload.dart';
import '../Loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadScreen extends StatefulWidget {
  @override
  UploadScreenState createState() => new UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size defaultSize = MediaQuery.of(context).size;
    // TODO: implement build
    return ChangeNotifierProvider<SlideModel>(
      create: (_) => SlideModel(),
      child: Consumer<SlideModel>(builder: (context, model, child) {
        return Stack(fit: StackFit.expand, children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Scaffold(
                backgroundColor: Colors.grey[100],
                appBar: AppBar(
                  elevation: 1,
                  actions: [
                    if (model.slidePath != '')
                      IconButton(
                          onPressed: () {
                            if (_formkey.currentState.validate() &&
                                !model.expPaths.contains('')) {
                              _formkey.currentState.save();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UploadScreen2(
                                          model.answers,
                                          model.durations,
                                          model.slideImageBytes)));
                            } else {
                              model.expTextColors.asMap().forEach((key, value) {
                                if (model.expPaths[key] == '') {
                                  setState(() {
                                    value = Colors.red;
                                  });
                                }
                              });
                            }
                          },
                          icon: Icon(Icons.arrow_forward_ios))
                  ],
                ),
                body: Form(
                  key: _formkey,
                  child: model.slidePath == ''
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                onPressed: () async {
                                  model.setSlide();
                                },
                                child: Text(
                                  'スライド画像（PDF）を選択',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.blueAccent,
                              ),
                              Text('縦横比　9:16')
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: model.slideImages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "問題" + (index + 1).toString(),
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              child: model.slideImages[index],
                                              width: defaultSize.width,
                                              height:
                                                  defaultSize.width * 9 / 16,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 0.35)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Divider(
                                                thickness: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Container(
                                                child: TextFormField(
                                                    initialValue:
                                                        model.answers[index],
                                                    validator: (value) {
                                                      if (value.isNotEmpty) {
                                                        return null;
                                                      } else {
                                                        return '答えを入力してください';
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      model.answers[index] =
                                                          value;
                                                    },
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                          20)
                                                    ],
                                                    maxLines: 1,
                                                    cursorColor:
                                                        Colors.blueAccent,
                                                    decoration: InputDecoration(
                                                      labelText: '答え',
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .blueAccent)),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .red)),
                                                    )),
                                                width: 300,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Divider(
                                                thickness: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                '制限時間',
                                                style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Container(
                                                // width: 80,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Container(
                                                      child:
                                                          CupertinoTimerPicker(
                                                        initialTimerDuration:
                                                            model.durations[
                                                                index],
                                                        mode:
                                                            CupertinoTimerPickerMode
                                                                .ms,
                                                        onTimerDurationChanged:
                                                            (duration) {
                                                          setState(() {
                                                            model.durations[
                                                                    index] =
                                                                duration;
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
                                            Center(
                                              child: InkWell(
                                                  onTap: () =>
                                                      model.setExp(index),
                                                  child: model.expImages[
                                                              index] ==
                                                          null
                                                      ? Container(
                                                          child: Center(
                                                              child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'サムネイル画像（JPG）を選択',
                                                                style: TextStyle(
                                                                    color: model
                                                                            .expTextColors[
                                                                        index],
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                              Text(
                                                                '縦横比　9:16',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blueAccent,
                                                                    fontSize:
                                                                        10),
                                                              ),
                                                            ],
                                                          )),
                                                          height: 135,
                                                          width: 240,
                                                          color: Colors.grey,
                                                        )
                                                      : model.expImages[index]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        ),
                )),
          ),
          OverlayLoadingMolecules(visible: model.visible),
        ]);
      }),
    );
  }
}
