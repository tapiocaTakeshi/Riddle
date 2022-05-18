import 'dart:io';

import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/models/GoogleSignInModel.dart';
import 'package:Riddle/screens/NotifyScreen.dart';
import 'package:Riddle/screens/SearchScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'flavors.dart';
import 'models/AppleSignInModel.dart';
import 'models/SlideModel.dart';
import 'models/ThumbnailModel.dart';
import 'screens/MyAccountScreen.dart';
import 'screens/HomeScreen.dart';
import 'screens/SignUpPage.dart';
import 'screens/UploadScreen.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GoogleSignInModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AppleSignInModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => SlideModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThumbnailModel(),
        ),
      ],
      child: MaterialApp(
        title: F.title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: TextTheme().apply(bodyColor: Colors.black),
          appBarTheme: AppBarTheme(
              elevation: 2,
              backgroundColor: Colors.grey[100],
              iconTheme: IconThemeData(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
          primaryColor: Colors.grey[100],
          backgroundColor: Colors.grey[100],
          accentColor: Colors.white,
        ),

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme().apply(bodyColor: Colors.white),
          appBarTheme: AppBarTheme(
              elevation: 2,
              backgroundColor: Colors.grey[900],
              iconTheme: IconThemeData(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          primaryColor: Colors.grey[900],
          backgroundColor: Colors.grey[900],
          accentColor: Colors.black,
        ),
        home: _flavorBanner(child: Branch()),
        // routes: <String, WidgetBuilder> {
        //   '/uploadpage': (BuildContext context) => new UploadPage(),
        // },
      ),
    );
  }
}

class Branch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BranchState();
}

class BranchState extends State<Branch> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return ShowCaseWidget(
            builder: Builder(builder: (_) => MyHomePage()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("ログインできませんでした"));
        } else {
          return SignUpPage();
        }
      },
    );
  }
}

GlobalKey uploadKey = GlobalKey();
GlobalKey searchKey = GlobalKey();
GlobalKey humbergerKey = GlobalKey();

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _contents = <Widget>[
    HomeScreen(),
    SearchScreen(),
    MyAccountScreen(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future(
        () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool firstTime = prefs.getBool('firstTime') ?? true;
          if (firstTime) {
            await prefs.setBool('firstTime', false);
            ShowCaseWidget.of(context)!
                .startShowCase([uploadKey, searchKey, humbergerKey]);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: _selectedIndex,
          children: _contents,
        ),
        bottomNavigationBar: PreferredSize(
          preferredSize: Size.fromHeight(Platform.isAndroid ? 70 : 86),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home_sharp), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined), label: '')
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orange,
            iconSize: 30,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            onTap: _onItemTap,
            elevation: 20,
          ),
        ));
  }
}

Widget _flavorBanner({
  required Widget child,
}) =>
    F.appFlavor == Flavor.DEV
        ? Banner(
            child: child,
            location: BannerLocation.topStart,
            message: F.name,
            color: Colors.green.withOpacity(0.6),
            textStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.0,
                letterSpacing: 1.0),
            textDirection: TextDirection.ltr,
          )
        : child;
