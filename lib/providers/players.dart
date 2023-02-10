import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/player.dart';

class Players with ChangeNotifier {
  final List<Player> _allPlayer = [];

  List<Player> get allPlayer => _allPlayer;

  int get jumlahPlayer => _allPlayer.length;

  Player selectById(String id) =>
      _allPlayer.firstWhere((element) => element.id == id);

  Future<void> addPlayer(
    String name,
    String position,
    String image,
    BuildContext context,
  ) {
    Uri url = Uri.parse(
        "https://flutter-firebase-7cca4-default-rtdb.firebaseio.com/players.json");

    DateTime datetimeNow = DateTime.now();

    return http
        .post(
      url,
      body: json.encode(
        {
          "name": name,
          "position": position,
          "imageUrl": image,
          "createdAt": datetimeNow.toString(),
        },
      ),
    )
        .then(
      (response) {
        _allPlayer.add(
          Player(
            id: json.decode(response.body)["name"].toString(),
            name: name,
            position: position,
            imageUrl: image,
            createdAt: datetimeNow,
          ),
        );
        notifyListeners();
      },
    );
  }

  void editPlayer(String id, String name, String position, String image,
      BuildContext context) {
    Player selectPlayer = _allPlayer.firstWhere((element) => element.id == id);
    selectPlayer.name = name;
    selectPlayer.position = position;
    selectPlayer.imageUrl = image;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Berhasil diubah"),
        duration: Duration(seconds: 2),
      ),
    );
    notifyListeners();
  }

  void deletePlayer(String id, BuildContext context) {
    _allPlayer.removeWhere((element) => element.id == id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Berhasil dihapus"),
        duration: Duration(milliseconds: 500),
      ),
    );
    notifyListeners();
  }
}
