import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animations/animations.dart';
import 'DetailPage.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<String> titles = [
    "contents1unkomannnnnnnnnnnnnnnnnnnnndesuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu",
    "contents2",
    "contents3",
    "contents4",
    "contents5",
    "contents6",
    "contents7",
    "contents8",
    "contents9",
    "contents10",
    "contents11",
  ];
  List<String> images = [
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
            elevation: 1,
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    showSearch(context: context, delegate: DataSearch());
                  }),
              IconButton(icon: Icon(Icons.menu,color: Colors.black), onPressed: (){})
            ]),
        body: GridView.count(
          crossAxisCount: 1,
          mainAxisSpacing: 0.5,
          childAspectRatio: 3/2,
          children: List.generate(images.length, (index) {
            return GridTile(
              child: OpenContainer(
                openBuilder: (context, closedContainer) {
                  return DetailPage(
                    index: index, title: titles[index], image: images[index], onPressed: closedContainer,);
                },
                closedBuilder: (context, openContainer) {
                  return Stack(
                    children: <Widget>[
                      Container(
                        child: Image.asset(
                          images[index],
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
        )
    );
  }
}

// ignore: must_be_immutable


class DataSearch extends SearchDelegate<String> {
  final histories = ['history1', 'history2', 'history3', 'history4'];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {}

  @override
  Widget buildSuggestions(BuildContext context) {
    final results =
        histories.where((element) => element.contains(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.access_time), title: Text(results[index])),
      itemCount: results.length,
    );
  }
}
