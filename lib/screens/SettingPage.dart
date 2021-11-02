import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../GoogleSignInModel.dart';

class SettingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
       backgroundColor: Colors.grey[100],
     appBar: AppBar(
       elevation: 1,
     ),
     body: ListView(
       padding: EdgeInsets.all(24),
       children: [
         Padding(
           padding: const EdgeInsets.all(1.0),
           child: ListTile(
             title: Text('ログアウト'),
             tileColor: Colors.white,
             onTap: (){
               final provider = Provider.of<GoogleSignInModel>(context,listen: false);
               provider.signOut();
               Navigator.of(context).pop();
             },
           ),
         ),
       ],
     )
   );
  }

}