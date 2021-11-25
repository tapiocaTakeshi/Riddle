import 'package:Riddle/screens/UploadScreen2.dart';
import 'package:animations/animations.dart';
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
                    if (model.isOpeneds.every((element) => element))
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UploadScreen2(
                                        model.answers,
                                        model.durations,
                                        model.slideImageBytes)));
                          },
                          icon: Icon(Icons.arrow_forward_ios))
                  ],
                ),
                body: model.slidePath == ''
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
                    : GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: 16 / 9,
                        children: List.generate(
                            model.slideImages.length,
                            (index) => Card(
                                  child: InkWell(
                                      highlightColor:
                                          Colors.grey.withOpacity(0.3),
                                      splashColor: Colors.grey.withOpacity(0.3),
                                      onTap: () {
                                        final _formkey = GlobalKey<FormState>();
                                        var expTextColor = Colors.black;
                                        setState(() {
                                          model.isOpeneds[index] = true;
                                        });
                                        showModalBottomSheet(
                                          isDismissible: false,
                                          enableDrag: false,
                                          clipBehavior: Clip.antiAlias,
                                          context: context,
                                          builder: (context) => Container(
                                            height: 500,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            20))),
                                            child: Form(
                                              key: _formkey,
                                              child: GestureDetector(
                                                onTap: () => FocusScope.of(
                                                        context)
                                                    .requestFocus(FocusNode()),
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading: IconButton(
                                                        icon: Icon(Icons.clear),
                                                        onPressed: () {
                                                          if (_formkey
                                                              .currentState
                                                              .validate()) if (model
                                                                      .expPaths[
                                                                  index] !=
                                                              '') {
                                                            _formkey
                                                                .currentState
                                                                .save();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          } else {
                                                            setState(() {
                                                              expTextColor =
                                                                  Colors.red;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                      title: Text('DETAIL'),
                                                    ),
                                                    ListView(
                                                      shrinkWrap: true,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0.5),
                                                      children: [
                                                        ListTile(
                                                          leading: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text('答え',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                          trailing: SizedBox(
                                                            width: 200,
                                                            child:
                                                                TextFormField(
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                    maxLength:
                                                                        10,
                                                                    initialValue:
                                                                        model.answers[
                                                                            index],
                                                                    validator:
                                                                        (value) {
                                                                      if (value
                                                                          .isNotEmpty) {
                                                                        return null;
                                                                      } else {
                                                                        return '答えを入力してください';
                                                                      }
                                                                    },
                                                                    onChanged:
                                                                        (value) {
                                                                      model.answers[
                                                                              index] =
                                                                          value;
                                                                    },
                                                                    inputFormatters: [
                                                                      LengthLimitingTextInputFormatter(
                                                                          20)
                                                                    ],
                                                                    maxLines: 1,
                                                                    cursorColor:
                                                                        Colors
                                                                            .blueAccent,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      errorStyle:
                                                                          TextStyle(
                                                                              fontSize: 0),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .white,
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                              borderSide: BorderSide(color: Colors.grey)),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                              borderSide: BorderSide(color: Colors.blueAccent)),
                                                                      errorBorder:
                                                                          OutlineInputBorder(
                                                                              borderSide: BorderSide(color: Colors.red)),
                                                                      focusedErrorBorder:
                                                                          OutlineInputBorder(
                                                                              borderSide: BorderSide(color: Colors.red)),
                                                                    )),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          leading: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text('制限時間',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                          trailing: SizedBox(
                                                            height: 40,
                                                            width: 100,
                                                            child:
                                                                CupertinoDialogAction(
                                                                    child: Text(
                                                                      '${(model.durations[index].inSeconds ~/ 60).toString().padLeft(2, '0')}:${(model.durations[index].inSeconds % 60).toString().padLeft(2, '0')}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              30),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      showCupertinoModalPopup(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              CupertinoActionSheet(
                                                                                actions: [
                                                                                  SizedBox(
                                                                                    height: 200,
                                                                                    child: CupertinoTimerPicker(
                                                                                      initialTimerDuration: model.durations[index],
                                                                                      mode: CupertinoTimerPickerMode.ms,
                                                                                      onTimerDurationChanged: (duration) {
                                                                                        setState(() {
                                                                                          model.durations[index] = duration;
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                                cancelButton: CupertinoActionSheetAction(
                                                                                  child: Text('閉じる'),
                                                                                  onPressed: () => Navigator.pop(context),
                                                                                ),
                                                                              ));
                                                                    }),
                                                          ),
                                                        ),
                                                        Center(
                                                          child: InkWell(
                                                              onTap: () async {
                                                                await model
                                                                    .setExp(
                                                                        index);
                                                                print(model
                                                                        .expImages[
                                                                    index]);
                                                              },
                                                              child: model.expPaths[
                                                                          index] ==
                                                                      ''
                                                                  ? Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              border: Border.all(color: Colors.grey[300])),
                                                                      child:
                                                                          Container(
                                                                        child: Center(
                                                                            child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              '解説用画像（JPG）を選択',
                                                                              style: TextStyle(color: expTextColor, fontSize: 15),
                                                                            ),
                                                                            Text(
                                                                              '縦横比　9:16',
                                                                              style: TextStyle(color: Colors.grey, fontSize: 10),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                        height:
                                                                            135,
                                                                        width:
                                                                            240,
                                                                        color: Colors
                                                                            .grey[100],
                                                                      ),
                                                                    )
                                                                  : model.expImages[
                                                                      index]),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: model.slideImages[index]),
                                )),
                      )),
          ),
          OverlayLoadingMolecules(visible: model.visible),
        ]);
      }),
    );
  }
}
