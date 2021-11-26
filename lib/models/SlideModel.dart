import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../functions/Upload.dart';

class SlideModel extends ChangeNotifier {
  String slidePath = '';
  List<Image> slideImages = [];
  List<File> slideImageFiles = [];
  List<Uint8List> slideImageBytes = [];
  List<String> answers;
  List<Duration> durations;
  List<bool> isOpeneds = [false];
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

      answers = List.generate(slideImages.length, (index) => '');
      durations = List.generate(slideImages.length, (index) => Duration.zero);
      visible = false;
      print(slidePath);
      expPaths = List.generate(slideImageBytes.length, (index) => '');
      expImages = []..length = slideImageBytes.length;
      expImageFiles = []..length = slideImageBytes.length;

      isOpeneds = List.generate(slideImageBytes.length, (index) => false);
    }
    notifyListeners();
  }

  List<String> expPaths;
  List<File> expImageFiles;
  List<Image> expImages;

  void setExp(int index) async {
    expPaths[index] = await JpgUpload();
    if (expPaths[index] != '') {
      visible = true;
      expImageFiles[index] = File(expPaths[index]);
      expImages[index] = Image.memory(
        await expImageFiles[index].readAsBytes(),
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
