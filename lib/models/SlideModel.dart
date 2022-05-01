import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../functions/Upload.dart';

class SlideModel extends ChangeNotifier {
  String slidePath = '';
  List<Image> slideImages = [];
  List<File> slideImageFiles = [];
  List<Uint8List> slideImageBytes = [];
  List<String>? answers;
  List<Duration>? durations;
  List<bool> isOpeneds = [false];
  final Directory systemTempDir = Directory.systemTemp;
  bool visible = false;

  void setSlide() async {
    slidePath = await PdfUpload();

    if (slidePath != '') {
      visible = true;
      //pdf->images
      slideImageBytes = await SplitPdf(slidePath);
      slideImageBytes.asMap().forEach((index, value) {
        slideImages.add(Image.memory(
          value,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ));
      });

      //slide: images->jpgs

      slideImageFiles = List.generate(
          slideImageBytes.length,
          (index) =>
              File('${systemTempDir.path}/slideImage${index.toString()}.jpg'));

      slideImageFiles.asMap().forEach((index, value) {
        value..writeAsBytesSync(slideImageBytes[index]);
      });

      answers = List.generate(slideImages.length, (index) => '');
      durations = List.generate(slideImages.length, (index) => Duration.zero);
      visible = false;
      print(slidePath);
      expPaths = List.generate(slideImageBytes.length, (index) => '');
      expImages = [].cast()..length = slideImageBytes.length;
      expImageFiles = [].cast()..length = slideImageBytes.length;
      expImageBytes = [].cast()..length = slideImageBytes.length;
      isOpeneds = List.generate(slideImageBytes.length, (index) => false);
    }
    notifyListeners();
  }

  void deleteSlide() {
    slidePath = '';
    slideImages = [];
    slideImageFiles = [];
    slideImageBytes = [];
    answers = [];
    durations = [];
    isOpeneds = [false];
    notifyListeners();
  }

  List<String>? expPaths;
  List<File>? expImageFiles;
  List<Image>? expImages;
  List<Uint8List>? expImageBytes;

  void setExp(int index) async {
    expPaths![index] = await JpgUpload();
    if (expPaths![index] != '') {
      visible = true;
      expImageBytes![index] = File(expPaths![index]).readAsBytesSync();
      expImageFiles![index] =
          File('${systemTempDir.path}/expImage${index.toString()}.jpg');
      expImageFiles![index].writeAsBytesSync(expImageBytes![index]);
      expImages![index] = Image.memory(
        expImageBytes![index],
        height: 135,
        width: 240,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
      visible = false;
    }
    notifyListeners();
  }
}
