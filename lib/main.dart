import 'dart:io';

import 'package:Riddle/data/AdState.dart';
import 'package:Riddle/models/GoogleSignInModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'screens/MyAccountScreen.dart';
import 'screens/HomeScreen.dart';
import 'screens/SignUpPage.dart';
import 'screens/UploadScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInModel(),
      child: MaterialApp(
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
        home: Branch(),
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
          return MyHomePage();
        } else if (snapshot.hasError) {
          return Center(child: Text("ログインできませんでした"));
        } else {
          return SignUpPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _contents = <Widget>[
    HomeScreen(),
    MyAccountScreen(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
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
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add_outlined,
            size: 38,
            color: Colors.orange,
          ),
          elevation: 2,
          onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UploadScreen(),
                fullscreenDialog: true,
              )),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SizedBox(
          height: Platform.isAndroid ? 70 : 86,
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_sharp),
                  // ignore: deprecated_member_use
                  label: 'ホーム'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  // ignore: deprecated_member_use
                  label: 'アカウント')
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orange,
            iconSize: 24,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            onTap: _onItemTap,
            elevation: 20,
          ),
        ));
  }
}
