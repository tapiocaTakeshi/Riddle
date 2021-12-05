import 'package:Riddle/functions/Firebase.dart';
import 'package:Riddle/screens/SettingPage.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    final myRiddleIdList = user['MyRiddleList'];

    if (myRiddleIdList.isNotEmpty) {
      final myRiddlesSnapshot = await FirebaseFirestore.instance
          .collection('Riddles')
          .where('id', whereIn: myRiddleIdList)
          .get();
      setState(() {
        this.myRiddles = myRiddlesSnapshot.docs
            .map((DocumentSnapshot document) =>
                document.data() as Map<String, dynamic>)
            .toList();
      });
    }

    final favoriteRiddleIdList = user['FavoriteRiddleList'];

    if (favoriteRiddleIdList.isNotEmpty) {
      final favoriteRiddlesSnapshot = await FirebaseFirestore.instance
          .collection('Riddles')
          .where('id', whereIn: favoriteRiddleIdList)
          .get();
      setState(() {
        this.favoriteRiddles = favoriteRiddlesSnapshot.docs
            .map((DocumentSnapshot document) =>
                document.data() as Map<String, dynamic>)
            .toList();
      });
    }
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
              appBar: AppBar(
                title: Text(
                  snapshot.data!['name'].toString(),
                  style: TextStyle(color: Colors.black),
                ),
                elevation: 1,
                centerTitle: false,
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
                              unselectedLabelColor: Colors.black,
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
  final userImage;
  final subscribersCount;
  final uid;
  var isSubscribed;

  MySliverPersistentHeaderDelegate(
      this.userImage, this.subscribersCount, this.uid, this.isSubscribed);

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
                child: CircleAvatar(backgroundImage: NetworkImage(userImage)),
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
                              'チャンネル登録者数 ' + subscribersCount.toString() + '人',
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

  TabPage({@required this.contents});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // TODO: implement build
    return Center(
      child: Container(
        width: 400,
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 1,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: 16 / 9,
          children: List.generate(contents.length, (index) {
            return Card(
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(5)
              // ),
              child: OpenContainer(
                closedElevation: 0,
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
            );
          }),
        ),
      ),
    );
  }
}
