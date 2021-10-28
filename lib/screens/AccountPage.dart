
import 'package:Riddle/screens/SettingPage.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DetailPage.dart';

class AccountPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>AccountPageState();
}

class AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: _tab.length, vsync: this);
  }

  final user = FirebaseAuth.instance.currentUser;

  List<String> myImages = [
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg",
    "assets/images/riddle_ex.jpg"
  ];


  final _tab = <Tab>[
    Tab(
      icon: Icon(Icons.auto_awesome_motion),
    ),
    Tab(
      icon: Icon(Icons.favorite),
    )
  ];

  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    Size defaultSize = MediaQuery.of(context).size;
    // TODO: implement build
    return  Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          user.displayName.toString(),
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.orange,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingPage()));
              })
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, value){
          return [
            SliverPersistentHeader(
                delegate: MySliverPersistentHeaderDelegate(defaultSize: defaultSize,userImage: user.photoURL,subscribersCount: 100,GDV: 50)
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 1),
              sliver: SliverAppBar(
                titleSpacing: 0,
                elevation: 1,
                pinned: true,
                title: TabBar(
                    controller: _tabController,
                    tabs: _tab,
                    indicatorColor: Colors.orange
                ),
              ),
            ),
          ];
        },
        body: TabBarView(controller: _tabController, children: <Widget>[
          TabPage(contents: myImages),
          TabPage(contents: myImages)
        ]),
      ),
    );
  }

}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate{

  final Size defaultSize;
  final userImage;
  final subscribersCount;
  final GDV;


  MySliverPersistentHeaderDelegate({@required this.defaultSize, @required this.userImage,@required this.subscribersCount,@required this.GDV});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.white,
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
                color: Colors.grey[200],
              ),
            ),
            VerticalDivider(color: Colors.black26,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget> [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "登録者数",
                        style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black45),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        subscribersCount.toString(),
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black87),
                      ),
                    )
                  ]
              ),
            ),
            VerticalDivider(color: Colors.black26,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget> [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "偏差値",
                        style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black45),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        GDV.toString(),
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black87),
                      ),
                    )
                  ]
              ),
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
  final List<String> contents;

  TabPage({@required this.contents});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GridView.count(
      crossAxisCount: 1,
      mainAxisSpacing: 0.5,
      childAspectRatio: 3/2,
      children: List.generate(contents.length, (index) {
        return GridTile(
          child: OpenContainer(
            openBuilder: (context, closedContainer) {
              return DetailPage(
                index: index, title: '問題', image: contents[index], onPressed: closedContainer,);
            },
            closedBuilder: (context, openContainer) {
              return Stack(
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      contents[index],
                      fit: BoxFit.fitWidth,
                    ),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      highlightColor: Colors.grey.withOpacity(0.3),
                      splashColor: Colors.grey.withOpacity(0.3),
                      onTap: () => openContainer(),
                    ),
                  )
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
