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
  bool visible = false;

  void setSlide() async {
    slidePath = await PdfUpload();
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
    notifyListeners();
  }
}
