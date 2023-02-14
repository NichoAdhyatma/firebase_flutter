import 'dart:math';

import 'package:flutter/material.dart';

class Avatars extends ChangeNotifier {
  final List<String> _images = [];

  List<String> get images => _images;
  int get length => _images.length;

  String imageUrl = "https://api.multiavatar.com/";

  Future<void> generateImages() async {
    _images.clear();
    for (int i = 0; i < 4; i++) {
      _images.add("$imageUrl${1 + Random().nextInt(1000)}.png");
    }
    
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
