import 'package:Riddle/screens/DetailPage.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flappy_search_bar_ns/flappy_search_bar_ns.dart';
import 'package:flappy_search_bar_ns/search_bar_style.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Query riddlesReference = FirebaseFirestore.instance
      .collection('Riddles')
      .orderBy('date', descending: false);
  List<Map<String, dynamic>> temp = [];

  int lastIndex = 0;
  final loadLength = 1;
  bool hasMore = true;
  List<Map<String, dynamic>> riddles = [];
  final _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;

  void loadRiddles() async {
    temp = (await riddlesReference.get())
        .docs
        .map((DocumentSnapshot document) =>
            document.data() as Map<String, dynamic>)
        .toList();

    riddles = [];
    for (var i = 0; i < lastIndex + loadLength; i++) {
      if (i < temp.length) riddles.add(temp[i]);
    }

    lastIndex += loadLength;
    if (riddles.length >= temp.length) hasMore = false;
    if (mounted) setState(() {});
  }

  Future<List<Map<String, dynamic>>> _search(String? keyword) async {
    return temp.where((riddle) => riddle['title'].contains(keyword)).toList();
  }

  @override
  void initState() {
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: SearchBar<Map<String, dynamic>>(
        minimumChars: 1,
        hintText: 'Search Riddles...',
        onSearch: _search,
        searchBarStyle:
            SearchBarStyle(padding: EdgeInsets.symmetric(horizontal: 5)),
        header: CustomRadioButton(
          elevation: 0,
          buttonLables: ['新着', '人気', '難易度'],
          buttonValues: ['NEW', 'POPULAR', 'DIFFICULTY'],
          radioButtonValue: (value) {
            switch (value) {
              case 'NEW':
                riddlesReference = FirebaseFirestore.instance
                    .collection('Riddles')
                    .orderBy('date', descending: false);
                // print('New');
                break;
              case 'POPULAR':
                riddlesReference = FirebaseFirestore.instance
                    .collection('Riddles')
                    .orderBy('answerCount', descending: true);
                // print('Popular');
                break;
              case 'DIFFICULTY':
                riddlesReference = FirebaseFirestore.instance
                    .collection('Riddles')
                    .orderBy('CorrectAnswerRatemean', descending: false);
                // print('Difficluty');
                break;
              default:
                break;
            }
            loadRiddles();
          },
          selectedColor: Colors.grey,
          selectedBorderColor: Colors.grey,
          unSelectedColor: Colors.white,
          unSelectedBorderColor: Colors.grey,
          enableShape: true,
          defaultSelected: 'NEW',
        ),
        placeHolder: RefreshIndicator(
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
        ),
        onItemFound: (value, index) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUser!.uid)
                .get(),
            builder: (context, currentUser) {
              if (currentUser.hasData) {
                return Visibility(
                  visible: !(currentUser.data!['BlockedUserList'] as List)
                      .contains(value!['uid']),
                  child: Card(
                    elevation: 3,
                    clipBehavior: Clip.antiAlias,
                    child: OpenContainer(
                      closedElevation: 1,
                      openBuilder: (context, closedContainer) {
                        return DetailPage(
                          id: value['id'],
                          title: value['title'],
                          image: value['thumbnailURL'],
                          onPressed: closedContainer,
                        );
                      },
                      closedBuilder: (context, openContainer) {
                        return Center(
                          child: InkWell(
                            child: Image.network(
                              value['thumbnailURL'],
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
            },
          );
        },
      )),
    );
  }
}
