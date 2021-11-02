import 'dart:io';

import 'package:Riddle/GoogleSignInModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/AccountScreen.dart';
import 'screens/SearchScreen.dart';
import 'screens/SignUpPage.dart';
import 'screens/UploadScreen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          textTheme: TextTheme().apply(bodyColor: Colors.black),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)
          ),
          iconTheme: IconThemeData(color: Colors.black),
          primaryColor: Colors.white
        ),
        home: Branch(),
        // routes: <String, WidgetBuilder> {
        //   '/uploadpage': (BuildContext context) => new UploadPage(),
        // },
      ),
    );
  }
}

class Branch extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>BranchState();
}

class BranchState extends State<Branch> {

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }else if(snapshot.hasData){
          return MyHomePage();
        }else if(snapshot.hasError){
          return Center(child: Text("ログインできませんでした"));
        }else{
          return SignUpPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>{
  int _selectedIndex=0;

  static  List<Widget> _contents=<Widget>[
    SearchScreen(),
    AccountScreen(),
  ];


  void _onItemTap(int index){
    setState((){
      _selectedIndex=index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

        body: Center(
          child: _contents.elementAt(_selectedIndex),
        ),

        floatingActionButton: Padding(
        padding: EdgeInsets.only(top: Platform.isAndroid?65:50),
        child:FloatingActionButton(
          child: Icon(Icons.add_box_outlined,size: 38,),
          backgroundColor: Colors.white10,
          foregroundColor: Colors.black,
          elevation: 0,
          onPressed: () =>  Navigator.push(context, MaterialPageRoute(
              builder: (context) => UploadScreen(),
              fullscreenDialog: true
          )),
        ),
      ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: SizedBox(
          height: Platform.isAndroid?70:86,
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_sharp),
                  // ignore: deprecated_member_use
                  title:Text('ホーム')
              ),


              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  // ignore: deprecated_member_use
                  title: Text('アカウント')
              )
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.black,
            iconSize: 24,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            onTap: _onItemTap,
            elevation: 0,
            backgroundColor: Colors.white,

          ),
        )
    );
  }

}


