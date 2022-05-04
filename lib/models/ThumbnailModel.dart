import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../functions/Upload.dart';

class ThumbnailModel extends ChangeNotifier {
  String thumbnailPath = '';
  File? thumbnailImageFile;
  Image? thumbnailImage;
  Uint8List? thumbnailImageByte;
  final Directory systemTempDir = Directory.systemTemp;
  bool visible = false;

  void setThumbnail() async {
    thumbnailPath = await JpgUpload();
    if (thumbnailPath != '') {
      visible = true;
      thumbnailImageByte = File(thumbnailPath).readAsBytesSync();
      thumbnailImageFile = File('${systemTempDir.path}/thumbnailImage.jpg');
      thumbnailImageFile!.writeAsBytesSync(thumbnailImageByte!);
      thumbnailImage = Image.memory(
        thumbnailImageByte!,
        height: 135,
        width: 240,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
      visible = false;
      notifyListeners();
    }
  }
}
