import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/SearchScreen.dart';
import 'screens/UploadScreen.dart';
import 'screens/AccountScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme().apply(bodyColor: Colors.black),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black)
        ),
        iconTheme: IconThemeData(color: Colors.black),
        primaryColor: Colors.white
      ),
      home: MyHomePage(),
      // routes: <String, WidgetBuilder> {
      //   '/uploadpage': (BuildContext context) => new UploadPage(),
      // },
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

        floatingActionButton: Container(
          margin: EdgeInsets.only(top:52),
          width: 48,
          child: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.orangeAccent,
              elevation: 1,
              onPressed: () =>  Navigator.push(context, MaterialPageRoute(
                builder: (context) => UploadScreen(),
                    fullscreenDialog: true
              )),
            ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                // ignore: deprecated_member_use
                title:Text('Search')
            ),

            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                // ignore: deprecated_member_use
                title: Text('Account')
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          onTap: _onItemTap,
          elevation: 0,
          backgroundColor: Colors.white,

        )
    );
  }

}


