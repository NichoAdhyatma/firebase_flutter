import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/players.dart';

class DetailPlayer extends StatelessWidget {
  static const routeName = "/detail-player";

  const DetailPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final players = Provider.of<Players>(context, listen: false);
    final playerId = ModalRoute.of(context)!.settings.arguments as String;
    final selectPLayer = players.selectById(playerId);
    final TextEditingController imageController =
        TextEditingController(text: selectPLayer.imageUrl);
    final TextEditingController nameController =
        TextEditingController(text: selectPLayer.name);
    final TextEditingController positionController =
        TextEditingController(text: selectPLayer.position);

    editPlayer() {
      players
          .editPlayer(
        playerId,
        nameController.text,
        positionController.text,
        imageController.text,
      )
          .then(
        (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Berhasil diubah"),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        },
      ).catchError(
        (err) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Server Error $err"),
              content: const Text("Check your internet connection!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ok"),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("DETAIL PLAYER"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: CachedNetworkImage(
                    imageUrl: selectPLayer.imageUrl!,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.network(
                      "https://api.multiavatar.com/0.png",
                    ),
                  ),
                ),
              ),
              TextFormField(
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(labelText: "Nama"),
                textInputAction: TextInputAction.next,
                controller: nameController,
              ),
              TextFormField(
                autocorrect: false,
                decoration: const InputDecoration(labelText: "Posisi"),
                textInputAction: TextInputAction.next,
                controller: positionController,
              ),
              TextFormField(
                autocorrect: false,
                decoration: const InputDecoration(labelText: "Image URL"),
                textInputAction: TextInputAction.done,
                controller: imageController,
                onEditingComplete: () {
                  editPlayer();
                },
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () {
                    editPlayer();
                  },
                  child: const Text(
                    "Edit",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
