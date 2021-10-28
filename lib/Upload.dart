import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';


//pdfファイルをアップロード
Future<String> PdfUpload() async {

  FilePickerResult result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  String path = result.files.single.path.toString();


  return Future<String>.value(path);
}

//pdfから複数の画像データ(Image)に変換
Future<List<Uint8List>> SplitPdf(String path) async {
  final pdf = PdfImageRendererPdf(path: path);
  await pdf.open();
  var count = await pdf.getPageCount();
  List<Image> images=[];
  List<Uint8List> imageBytes=[];
  for (var i = 0; i < count; i++) {
    var size = await pdf.getPageSize(pageIndex: i);
    var SlideByte = await pdf.renderPage(
      background: Colors.transparent,
      x: 0,
      y: 0,
      width: size.width,
      height: size.height,
      scale: 1.0,
      pageIndex: i,
    );
    imageBytes.add(SlideByte);
  }
  return Future<List<Uint8List>>.value(imageBytes);
}

//pdfファイルをアップロード
Future<String> JpgUpload() async {

  FilePickerResult result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg'],
  );

  String path = result.files.single.path.toString();

  return Future<String>.value(path);
}


