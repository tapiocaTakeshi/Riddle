import 'dart:io';

import 'package:flutter/material.dart';

import 'Upload.dart';

class ThumbnailModel extends ChangeNotifier {
  String thumbnailPath = '';
  File thumbnailImageFile;
  Image thumbnailImage;
  bool visible = false;

  void setThumbnail() async {
    thumbnailPath = await JpgUpload();
    if (thumbnailPath != null) {
      visible = true;
      thumbnailImageFile = File(thumbnailPath);
      thumbnailImage = Image.memory(
        await thumbnailImageFile.readAsBytes(),
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
