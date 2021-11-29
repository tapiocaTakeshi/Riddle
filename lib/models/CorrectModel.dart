import 'package:flutter/material.dart';

class CorrectModel extends ChangeNotifier {
  List<bool> CoOrIn = [];

  void addtrue() {
    CoOrIn.add(true);
    notifyListeners();
  }

  void addfalse() {
    CoOrIn.add(false);
    notifyListeners();
  }

  void reset() {
    CoOrIn = [];
    notifyListeners();
  }
}
