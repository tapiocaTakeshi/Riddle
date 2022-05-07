import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/main.dart';
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
  List<Map<String, dynamic>> riddles = [];
  // List<Map<String, dynamic>> currentUserInfos=[];
  String? keyword = '';
  var inChunks = [];
  List<Query> outChunks = [];
  int lastIndex = 0;
  final loadLength = 3;
  bool hasMore = true;
  List<Map<String, dynamic>> temp = [];
  final _scrollController = ScrollController();

  Future loadRiddles() async {
    await Future.delayed(Duration(seconds: 3), () async {
      Query? riddlesReference;
      switch (order) {
        case orders.New:
          riddlesReference = FirebaseFirestore.instance
              .collection('Riddles')
              .orderBy('date', descending: false);
          // print('New');
          break;
        case orders.Popular:
          riddlesReference = FirebaseFirestore.instance
              .collection('Riddles')
              .orderBy('answerCount', descending: true);
          // print('Popular');
          break;
        case orders.Difficult:
          riddlesReference = FirebaseFirestore.instance
              .collection('Riddles')
              .orderBy('CorrectAnswerRatemean', descending: false);
          // print('Difficlut');
          break;
        default:
          break;
      }
      var flag = false;
      switch (filter) {
        case filters.All:
          outChunks = [];
          // print('All');
          break;
        case filters.Subsc:
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
              var riddlesQuery =
                  riddlesReference!.where('uid', whereIn: inChunks);
              outChunks.add(riddlesQuery);
            }
          } else {
            flag = true;
          }
          break;
        default:
      }
      temp = [];

      if (flag) {
        temp = [];
      } else {
        if (outChunks.isNotEmpty) {
          for (Query riddlesQuery in outChunks) {
            temp.addAll((await riddlesQuery.get())
                .docs
                .map((DocumentSnapshot document) =>
                    document.data() as Map<String, dynamic>)
                .toList());
          }
        } else {
          temp = (await riddlesReference!.get())
              .docs
              .map((DocumentSnapshot document) =>
                  document.data() as Map<String, dynamic>)
              .toList();
        }
      }
      if (keyword != '')
        temp =
            temp.where((riddle) => riddle['title'].contains(keyword)).toList();
      riddles = [];
      for (var i = 0; i < lastIndex + loadLength; i++) {
        if (i < temp.length) riddles.add(temp[i]);
      }

      lastIndex += loadLength;
      if (riddles.length >= temp.length) hasMore = false;
    });
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
                  setState(() {
                    lastIndex = 0;
                    riddles = [];
                  });
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
                    setState(() {
                      lastIndex = 0;
                      riddles = [];
                    });
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
            child: ListView(
              children: List.generate(riddles.length + 1, (index) {
                if (index < riddles.length) {
                  return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(currentUser!.uid)
                          .get(),
                      builder: (context, currentUser) {
                        if (currentUser.hasData) {
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
                          return Container();
                        }
                      });
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
