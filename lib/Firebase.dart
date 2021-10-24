import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


//Storageにアップロード
Future<String> uploadImage( File imageFile, String path ) async {
  final storage = FirebaseStorage.instance;
  final ref = storage.ref().child(path);
  final uploadTask = ref.putFile(imageFile);

  var dowurl = await (await uploadTask).ref.getDownloadURL();
  var url = dowurl.toString();

  return url;
}
