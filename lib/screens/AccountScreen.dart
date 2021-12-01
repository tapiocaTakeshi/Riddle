import 'package:Riddle/functions/Firebase.dart';
import 'package:Riddle/screens/SettingPage.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DetailPage.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> myRiddles = [];
  List<Map<String, dynamic>> favoriteRiddles = [];

  void loadRiddles() async {
    final data = await getData("Users", user!.uid);

    final myRiddleList = data['MyRiddleList'];
    if (myRiddleList.isNotEmpty) {
      final myRiddlesSnapshot = await FirebaseFirestore.instance
          .collection('Riddles')
          .where('id', whereIn: myRiddleList)
          .get();
      setState(() {
        this.myRiddles = myRiddlesSnapshot.docs
            .map((DocumentSnapshot document) =>
                document.data() as Map<String, dynamic>)
            .toList();
      });
    }

    final favoriteRiddleList = data['FavoriteRiddleList'];
    if (favoriteRiddleList.isNotEmpty) {
      final favoriteRiddlesSnapshot = await FirebaseFirestore.instance
          .collection('Riddles')
          .where('id', whereIn: favoriteRiddleList)
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
    loadRiddles();
    _tabController = TabController(length: _tab.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user!.displayName.toString(),
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.settings_outlined,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingPage()));
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
                      userImage: user!.photoURL,
                      subscribersCount: 100,
                      GDV: 50)),
              SliverPadding(
                padding: EdgeInsets.only(bottom: 1),
                sliver: SliverAppBar(
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
          body: TabBarView(controller: _tabController, children: <Widget>[
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
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final userImage;
  final subscribersCount;
  final GDV;

  MySliverPersistentHeaderDelegate(
      {@required this.userImage,
      @required this.subscribersCount,
      @required this.GDV});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
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
            VerticalDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    "登録者数",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Text(
                    subscribersCount.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ]),
            ),
            VerticalDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    "偏差値",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Text(
                    GDV.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ]),
            ),
            VerticalDivider(),
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
