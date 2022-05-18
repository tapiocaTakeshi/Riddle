import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/MyApp.dart';
import 'package:Riddle/screens/UploadScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:showcaseview/showcaseview.dart';
import '../functions/Firebase.dart';
import 'DetailPage.dart';

GlobalKey<HomeScreenState> HomeKey = new GlobalKey<HomeScreenState>();

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> riddles = [];
  // List<Map<String, dynamic>> currentUserInfos=[];
  var inChunks = [];
  List<Query> outChunks = [];
  int lastIndex = 0;
  final loadLength = 10;
  bool hasMore = true;
  List<Map<String, dynamic>> temp = [];
  final _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;

  Future loadRiddles() async {
    temp = [];
    riddles = [];
    Query? riddlesReference = FirebaseFirestore.instance
        .collection('Riddles')
        .orderBy('date', descending: false);

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserData = await getData('Users', currentUser!.uid);

    if (currentUserData['SubscribedChannelList'].isNotEmpty) {
      outChunks = [];
      for (var i = 0;
          i < currentUserData['SubscribedChannelList'].length;
          i += 10) {
        inChunks = currentUserData['SubscribedChannelList'].sublist(
            i,
            i + 10 > currentUserData['SubscribedChannelList'].length
                ? currentUserData['SubscribedChannelList'].length
                : i + 10);
        var riddlesQuery = riddlesReference.where('uid', whereIn: inChunks);
        outChunks.add(riddlesQuery);
      }
    }

    for (Query riddlesQuery in outChunks) {
      temp.addAll((await riddlesQuery.get())
          .docs
          .map((DocumentSnapshot document) =>
              document.data() as Map<String, dynamic>)
          .toList());
    }

    for (var i = 0; i < lastIndex + loadLength; i++) {
      if (i < temp.length) riddles.add(temp[i]);
    }

    lastIndex += loadLength;
    if (riddles.length >= temp.length) hasMore = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRiddles();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        loadRiddles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset(
                MediaQuery.platformBrightnessOf(context) == Brightness.dark
                    ? 'assets/images/RiddleLogo_DarkMode.png'
                    : 'assets/images/RiddleLogo_LightMode.png',
                height: 30,
              ),
            ),
            elevation: 1,
            actions: [
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      fullscreenDialog: true, builder: (_) => UploadScreen())),
                  icon: Icon(
                    Icons.add_box_rounded,
                    size: 30,
                  ))
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            loadRiddles();
          },
          child: Center(
            child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(currentUser!.uid)
                    .get(),
                builder: (context, currentUser) {
                  if (currentUser.hasData) {
                    return ListView(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: List.generate(riddles.length + 1, (index) {
                        if (index < riddles.length) {
                          return Visibility(
                            visible:
                                !(currentUser.data!['BlockedUserList'] as List)
                                    .contains(riddles[index]['uid']),
                            child: Card(
                              elevation: 3,
                              clipBehavior: Clip.antiAlias,
                              child: OpenContainer(
                                closedElevation: 1,
                                openBuilder: (context, closedContainer) {
                                  return DetailPage(
                                    id: riddles[index]['id'],
                                    title: riddles[index]['title'],
                                    image: riddles[index]['thumbnailURL'],
                                    onPressed: closedContainer,
                                  );
                                },
                                closedBuilder: (context, openContainer) {
                                  return Center(
                                    child: InkWell(
                                      child: Image.network(
                                        riddles[index]['thumbnailURL'],
                                        width: size.width,
                                        height: size.width * 9 / 16,
                                        fit: BoxFit.cover,
                                      ),
                                      highlightColor:
                                          Colors.grey.withOpacity(0.3),
                                      splashColor: Colors.grey.withOpacity(0.3),
                                      onTap: () => openContainer(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        } else {
                          return Center(
                              child: hasMore
                                  ? Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.orange,
                                      ),
                                    )
                                  : Container());
                        }
                      }),
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
        ));
  }
}
