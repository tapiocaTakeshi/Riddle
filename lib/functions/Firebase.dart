import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//Storageにアップロード
Future<String> uploadImage(File imageFile, String path) async {
  final storage = FirebaseStorage.instance;
  final ref = storage.ref().child(path);
  if (imageFile.existsSync()) {
    final uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask).ref.getDownloadURL();
    var url = dowurl.toString();
    return url;
  } else {
    return '';
  }
}

Future<Map<String, dynamic>> getData(
    String collection, String documentId) async {
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection(collection)
      .doc(documentId)
      .get();

  return docSnapshot.data();
}
