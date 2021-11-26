import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import '../functions/Firebase.dart';
import 'DetailPage.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> riddles = [];
  // List<Map<String, dynamic>> userInfos=[];
  var keyword = '';

  Future loadRiddles() async {
    final riddlesSnapshot =
        await FirebaseFirestore.instance.collection('Riddles').get();
    if (mounted) {
      setState(() {
        this.riddles = riddlesSnapshot.docs
            .map((DocumentSnapshot document) =>
                document.data() as Map<String, dynamic>)
            .toList();
        if (keyword != '')
          this.riddles = riddles
              .where((riddle) => riddle['title'].contains(keyword))
              .toList();
        // Future((){
        //   userInfos=[];
        //   riddles.asMap().forEach((index, _) async {
        //     getData('Users', riddles[index]['uid']).then((value) => this.userInfos.add(value));
        //   });
        // });
      });
      // print(userInfos);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRiddles();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
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
                      delegate: searchDelegate(
                          Keywords: Keywords, histories: histories),
                      useRootNavigator: true);
                  loadRiddles();
                },
                icon: Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: Icon(Icons.menu))
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
                children: List.generate(riddles.length, (index) {
                  return Card(
                    elevation: 3,
                    clipBehavior: Clip.antiAlias,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(5)
                    // ),
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
  CollectionReference Keywords;
  List<Map<String, dynamic>> histories;
  List<Map<String, dynamic>> keywordsfilter;

  searchDelegate({@required this.Keywords, @required this.histories}) {
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
          close(context, null);
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
