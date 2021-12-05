import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/screens/SearchOptionPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../functions/Firebase.dart';
import 'DetailPage.dart';

GlobalKey<HomeScreenState> HomeKey = new GlobalKey<HomeScreenState>();

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> riddles = [];
  // List<Map<String, dynamic>> userInfos=[];
  String? keyword = '';

  Future loadRiddles() async {
    Query? riddlesReference;
    switch (order) {
      case orders.New:
        riddlesReference = FirebaseFirestore.instance
            .collection('Riddles')
            .orderBy('date', descending: false);
        print('New');
        break;
      case orders.Popular:
        riddlesReference = FirebaseFirestore.instance
            .collection('Riddles')
            .orderBy('answerCount', descending: true);
        print('Popular');
        break;
      case orders.Difficult:
        riddlesReference = FirebaseFirestore.instance
            .collection('Riddles')
            .orderBy('CorrectAnswerRatemean', descending: false);
        print('Difficlut');
        break;
      default:
        break;
    }
    var flag = false;
    switch (filter) {
      case filters.All:
        break;
      case filters.Subsc:
        final currentUser = FirebaseAuth.instance.currentUser;
        final currentUserData = await getData('Users', currentUser!.uid);
        if (currentUserData['SubscribedChannelList'].isNotEmpty) {
          riddlesReference = riddlesReference!
              .where('uid', whereIn: currentUserData['SubscribedChannelList']);
        } else {
          flag = true;
        }
        break;
      default:
    }
    QuerySnapshot riddlesSnapshot = await riddlesReference!.get();
    if (mounted) {
      setState(() {
        if (flag) {
          this.riddles = [];
        } else {
          this.riddles = riddlesSnapshot.docs
              .map((DocumentSnapshot document) =>
                  document.data() as Map<String, dynamic>)
              .toList();
        }
        if (keyword != '')
          this.riddles = riddles
              .where((riddle) => riddle['title'].contains(keyword))
              .toList();
      });
    }
  }

  BannerAd? banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdState.BannerAdId,
      listener: BannerAdListener(),
      request: AdRequest());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    banner!.load();
    loadRiddles();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Size size = MediaQuery.of(context).size;
    final k = 3;
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          actions: [
            IconButton(
                onPressed: () async {
                  final Keywords =
                      FirebaseFirestore.instance.collection('Keywords');

                  final histories =
                      (await Keywords.orderBy('searchCount', descending: true)
                              .get())
                          .docs
                          .map((DocumentSnapshot document) =>
                              document.data() as Map<String, dynamic>)
                          .toList();
                  keyword = await showSearch(
                      context: context,
                      delegate: searchDelegate(Keywords, histories),
                      useRootNavigator: true);
                  loadRiddles();
                },
                icon: Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) => SearchOptionPage(),
                          fullscreenDialog: true))
                      .then((value) {
                    loadRiddles();
                  });
                },
                icon: Icon(Icons.menu))
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            loadRiddles();
          },
          child: Center(
            child: Container(
              width: 400,
              child: GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 16 / 9,
                children: List.generate(
                    riddles.length + riddles.length ~/ k + 1, (index) {
                  final index2 = index - index ~/ k - 1;
                  return index % k == 0
                      ? AdWidget(ad: banner!)
                      : Card(
                          elevation: 3,
                          clipBehavior: Clip.antiAlias,
                          child: OpenContainer(
                            closedElevation: 1,
                            openBuilder: (context, closedContainer) {
                              return DetailPage(
                                id: riddles[index2]['id'],
                                title: riddles[index2]['title'],
                                image: riddles[index2]['thumbnailURL'],
                                onPressed: closedContainer,
                              );
                            },
                            closedBuilder: (context, openContainer) {
                              return Center(
                                child: InkWell(
                                  child: Image.network(
                                    riddles[index2]['thumbnailURL'],
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
          ),
        ));
  }
}

class searchDelegate extends SearchDelegate<String> {
  late CollectionReference Keywords;
  late List<Map<String, dynamic>> histories;
  late List<Map<String, dynamic>> keywordsfilter;

  searchDelegate(this.Keywords, this.histories) {
    keywordsfilter = histories;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
            showSuggestions(context);
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, '');
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      close(context, query);
      if (query.isNotEmpty) {
        final snapshotFilter =
            await Keywords.where('word', isEqualTo: query).get();
        final docs = snapshotFilter.docs;
        if (docs.length == 0) {
          await Keywords.add({
            'word': query,
            'searchCount': 1,
          });
        } else {
          final data = docs[0].data() as Map<String, dynamic>;
          await Keywords.doc(docs[0].id)
              .update({'searchCount': data['searchCount'] + 1});
        }
      }
    });
    // TODO: implement buildResults
    return showKeywords(keywordsfilter);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    this.keywordsfilter = query.isEmpty
        ? histories
        : histories.where((history) {
            final historyLower = history['word'].toString().toLowerCase();
            final queryLower = query.toLowerCase();
            return historyLower.startsWith(queryLower);
          }).toList();
    return showKeywords(keywordsfilter);
  }

  Widget showKeywords(List<Map<String, dynamic>> keywordsShowed) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) => ListTile(
          onTap: () {
            query = keywordsShowed[index]['word'].toString();
            showResults(context);
          },
          leading: Icon(Icons.search),
          title: Text(keywordsShowed[index]['word'].toString())),
      itemCount: keywordsShowed.length,
    );
  }
}
