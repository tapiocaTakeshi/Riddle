import 'package:like_button/like_button.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {

  DetailPage({
    @required this.index,
    @required this.title,
    @required this.image,
    this.onPressed,
  });

  final int index;
  final String title;
  final String image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size defaultSize = mediaQueryData.size;

    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
                child: IconButton(icon: Icon(Icons.clear),onPressed: onPressed),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 6),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        child: Image.asset(image,fit: BoxFit.fitWidth),
                        elevation: 3,
                        shadowColor: Colors.grey.withOpacity(0.5),
                      ),
                    ),

                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                          child: Container(child: Text(title),width: double.infinity),
                        ),
                        Divider(
                          color: Colors.grey.withOpacity(0.5),
                          height: 1,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                child: LikeButton(
                                  size: 35,
                                  bubblesColor: BubblesColor(dotPrimaryColor: Colors.pinkAccent.withOpacity(0.3), dotSecondaryColor: Colors.pinkAccent.withOpacity(0.3)),
                                  circleColor: CircleColor(start: Colors.pinkAccent.withOpacity(0.2), end: Colors.pinkAccent.withOpacity(0.2)),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Text('10'),
                                    Center(
                                      child: Container(
                                        height: 1,
                                        // width: double.infinity,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text('100')
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}