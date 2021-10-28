
import 'dart:io';

import 'package:flutter/material.dart';

import 'Upload.dart';

class ThumbnailModel extends ChangeNotifier{
  String thumbnailPath = '';
  File thumbnailImageFile;
  Image thumbnailImage;
  bool visible = false;

  void setThumbnail() async {

    thumbnailPath = await JpgUpload();
    visible = true;
    thumbnailImageFile = File(thumbnailPath);
    thumbnailImage = Image.memory(
        await thumbnailImageFile.readAsBytes(),
    filterQuality: FilterQuality.high,
    );
    visible = false;
    notifyListeners();
  }
}