import 'package:Riddle/functions/Firebase.dart';
import 'package:Riddle/main.dart';
import 'package:Riddle/screens/SettingPage.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DetailPage.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountScreenState();
  String uid;
  AccountScreen(this.uid);
}

class AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> myRiddles = [];
  List<Map<String, dynamic>> favoriteRiddles = [];
  var user;
  bool isSubscribed = false;
  int? subscribersCount = 0;

  void loadRiddles() async {
    user = await getData('Users', widget.uid);
    final myRiddleList = user['MyRiddleList'];

    if (myRiddleList.isNotEmpty) {
      myRiddles = await subListFunc(myRiddleList);
    }

    final favoriteRiddleList = user['FavoriteRiddleList'];

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
    Future(() async {
      loadRiddles();
      final currentUserData = await getData('Users', currentUser!.uid);
      final CurrentSubscribedChannelList =
          currentUserData['SubscribedChannelList'];
      isSubscribed = CurrentSubscribedChannelList.contains(widget.uid);
      final Users = await FirebaseFirestore.instance
          .collection('Users')
          .where('SubscribedChannelList', arrayContains: widget.uid)
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
            .doc(widget.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: AppBar(
                  title: Text(
                    snapshot.data!['name'].toString(),
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1!.color),
                  ),
                  elevation: 1,
                  centerTitle: false,
                  actions: [
                    IconButton(
                        onPressed: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) => CupertinoActionSheet(
                                    actions: [
                                      CupertinoActionSheetAction(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Users')
                                                .doc(currentUser!.uid)
                                                .update({
                                              'BlockedUserList':
                                                  FieldValue.arrayUnion(
                                                      [widget.uid])
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'ユーザーをブロックしました。')));
                                          },
                                          child: Text('ユーザーをブロックする'))
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('キャンセル'),
                                    ),
                                  ));
                        },
                        icon: Icon(CupertinoIcons.shield_slash))
                  ],
                ),
              ),
              body: NestedScrollView(
                  headerSliverBuilder: (context, value) {
                    return [
                      SliverPersistentHeader(
                          delegate: MySliverPersistentHeaderDelegate(
                              snapshot.data!['photoURL'],
                              subscribersCount,
                              widget.uid,
                              isSubscribed)),
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: 1),
                        sliver: SliverAppBar(
                          automaticallyImplyLeading: false,
                          titleSpacing: 0,
                          elevation: 5,
                          pinned: true,
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
                        child: TabPage(contents: myRiddles)),
                    RefreshIndicator(
                        onRefresh: () async {
                          loadRiddles();
                        },
                        child: TabPage(contents: favoriteRiddles)),
                  ])),
            );
          } else {
            return Container(
              color: Theme.of(context).backgroundColor,
            );
          }
        });
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final currentUserImage;
  final subscribersCount;
  final uid;
  var isSubscribed;

  MySliverPersistentHeaderDelegate(this.currentUserImage, this.subscribersCount,
      this.uid, this.isSubscribed);

  void updateSubscribe() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    isSubscribed
        ? await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .update({
            'SubscribedChannelList': FieldValue.arrayUnion([uid])
          })
        : await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.uid)
            .update({
            'SubscribedChannelList': FieldValue.arrayRemove([uid])
          });
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    String subscribersText = subscribersCount! >= 10000
        ? subscribersCount! >= 100000000
            ? (subscribersCount! ~/ 100000000).toString() + '億'
            : (subscribersCount! ~/ 10000).toString() + '万'
        : subscribersCount.toString();
    return StatefulBuilder(builder: (context, setState) {
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
                child: CircleAvatar(
                    backgroundImage: NetworkImage(currentUserImage)),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
                    FlatButton(
                      child: isSubscribed
                          ? Text('登録済み', style: TextStyle(color: Colors.grey))
                          : Text('チャンネル登録',
                              style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          isSubscribed = !isSubscribed;
                        });
                        updateSubscribe();
                      },
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
  final currentUser = FirebaseAuth.instance.currentUser;

  TabPage({@required this.contents});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // TODO: implement build
    return Center(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(contents.length, (index) {
          return FutureBuilder<DocumentSnapshot>(
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
              });
        }),
      ),
    );
  }
}
