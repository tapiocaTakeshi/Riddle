import 'package:Riddle/functions/Firebase.dart';
import 'package:Riddle/main.dart';
import 'package:Riddle/models/GoogleSignInModel.dart';
import 'package:Riddle/screens/ProfileEditingPage.dart';
import 'package:Riddle/screens/SettingPage.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DetailPage.dart';

class MyAccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAccountScreenState();
}

class MyAccountScreenState extends State<MyAccountScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> myRiddles = [];
  List<Map<String, dynamic>> favoriteRiddles = [];
  int? subscribersCount = 0;

  void loadRiddles() async {
    final data = await getData("Users", currentUser!.uid);

    final myRiddleList = data['MyRiddleList'];
    if (myRiddleList.isNotEmpty) {
      myRiddles = await subListFunc(myRiddleList);
    }

    final favoriteRiddleList = data['FavoriteRiddleList'];
    if (favoriteRiddleList.isNotEmpty) {
      favoriteRiddles = await subListFunc(favoriteRiddleList);
    }
    if (mounted) setState(() {});
  }

  Future<List<Map<String, dynamic>>> loadData(List s) async {
    final riddlesSnapshot = await FirebaseFirestore.instance
        .collection('Riddles')
        .where('id', whereIn: s)
        .get();
    final riddles = riddlesSnapshot.docs
        .map((DocumentSnapshot document) =>
            document.data() as Map<String, dynamic>)
        .toList();
    return riddles;
  }

  Future<List<Map<String, dynamic>>> subListFunc(List list) async {
    var inChunks = [];
    List<Map<String, dynamic>> outChunks = [];
    for (var i = 0; i < list.length; i += 10) {
      inChunks = list.sublist(i, i + 10 > list.length ? list.length : i + 10);
      outChunks.addAll(await loadData(inChunks));
    }
    return outChunks;
  }

  final _tab = <Tab>[
    Tab(
      icon: Icon(Icons.auto_awesome_motion),
    ),
    Tab(
      icon: Icon(Icons.favorite),
    )
  ];

  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRiddles();
    Future(() async {
      final Users = await FirebaseFirestore.instance
          .collection('Users')
          .where('SubscribedChannelList', arrayContains: currentUser!.uid)
          .get()
          .then((QuerySnapshot snapshots) => snapshots.docs);
      subscribersCount = Users.length;
    });
    _tabController = TabController(length: _tab.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  snapshot.data!['name'],
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1!.color),
                ),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'ログアウト',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      })
                ],
                elevation: 1,
                centerTitle: false,
              ),
              body: NestedScrollView(
                  headerSliverBuilder: (context, value) {
                    return [
                      SliverPersistentHeader(
                          delegate: MySliverPersistentHeaderDelegate(
                        currentUserImage: snapshot.data!['photoURL'],
                        subscribersCount: subscribersCount,
                      )),
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: 1),
                        sliver: SliverAppBar(
                          titleSpacing: 0,
                          elevation: 5,
                          pinned: true,
                          automaticallyImplyLeading: false,
                          title: TabBar(
                              controller: _tabController,
                              tabs: _tab,
                              labelColor: Colors.orange,
                              unselectedLabelColor:
                                  Theme.of(context).textTheme.bodyText1!.color,
                              indicatorColor: Colors.orange),
                        ),
                      ),
                    ];
                  },
                  body:
                      TabBarView(controller: _tabController, children: <Widget>[
                    RefreshIndicator(
                        onRefresh: () async {
                          loadRiddles();
                        },
                        child: TabPage(
                          contents: myRiddles,
                          isMyRiddle: true,
                          loadRiddles: () => loadRiddles(),
                        )),
                    RefreshIndicator(
                        onRefresh: () async {
                          loadRiddles();
                        },
                        child: TabPage(
                          contents: favoriteRiddles,
                          isMyRiddle: false,
                          loadRiddles: () => loadRiddles(),
                        )),
                  ])),
            );
          } else {
            return Material(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final currentUserImage;
  final subscribersCount;

  MySliverPersistentHeaderDelegate({
    @required this.currentUserImage,
    @required this.subscribersCount,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    String subscribersText = subscribersCount! >= 10000
        ? subscribersCount! >= 100000000
            ? (subscribersCount! ~/ 100000000).toString() + '億'
            : (subscribersCount! ~/ 10000).toString() + '万'
        : subscribersCount.toString();
    return Container(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child:
                  CircleAvatar(backgroundImage: NetworkImage(currentUserImage)),
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            Column(
              children: [
                subscribersCount != null
                    ? Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Text(
                          'チャンネル登録者数 ' + subscribersText + '人',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(),
                OutlinedButton(
                    onPressed: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => ProfileEditingPage()));
                    }),
                    child: Text('プロフィールを編集'))
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 100;

  @override
  // TODO: implement minExtent
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return true;
  }
}

class TabPage extends StatelessWidget {
  final contents;
  final isMyRiddle;
  final VoidCallback? loadRiddles;

  TabPage(
      {@required this.contents, @required this.isMyRiddle, this.loadRiddles});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // TODO: implement build
    return Center(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(contents.length, (index) {
          return Stack(
            children: [
              FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(currentUser!.uid)
                      .get(),
                  builder: (context, currentUser) {
                    if (currentUser.hasData) {
                      return Visibility(
                        visible: !(currentUser.data!['BlockedUserList'] as List)
                            .contains(contents[index]['uid']),
                        child: Card(
                          elevation: 3,
                          clipBehavior: Clip.antiAlias,
                          child: OpenContainer(
                            closedElevation: 1,
                            openBuilder: (context, closedContainer) {
                              return DetailPage(
                                id: contents[index]['id'],
                                title: contents[index]['title'],
                                image: contents[index]['thumbnailURL'],
                                onPressed: closedContainer,
                              );
                            },
                            closedBuilder: (context, openContainer) {
                              return Center(
                                child: InkWell(
                                  child: Image.network(
                                    contents[index]['thumbnailURL'],
                                    width: size.width,
                                    height: size.width * 9 / 16,
                                    fit: BoxFit.cover,
                                  ),
                                  highlightColor: Colors.grey.withOpacity(0.3),
                                  splashColor: Colors.grey.withOpacity(0.3),
                                  onTap: () => openContainer(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
              if (isMyRiddle)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoActionSheet(
                                    actions: [
                                      CupertinoActionSheetAction(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Riddles')
                                                .doc(contents[index]['id']
                                                    .toString())
                                                .delete();
                                            // await FirebaseStorage.instance
                                            //     .ref('/')
                                            //     .child('Riddles')
                                            //     .child(contents[index]['id']
                                            //         .toString())
                                            //     .delete();
                                            loadRiddles;
                                            Navigator.pop(context);
                                          },
                                          child: Text('削除'))
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: Text('キャンセル'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ));
                        },
                      ),
                    ),
                  ),
                )
            ],
          );
        }),
      ),
    );
  }
}
