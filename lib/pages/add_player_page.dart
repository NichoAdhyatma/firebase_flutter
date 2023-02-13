import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/players.dart';

class AddPlayer extends StatelessWidget {
  static const routeName = "/add-player";
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController imageController =
      TextEditingController(text: "https://api.multiavatar.com/1.png");

  AddPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final players = Provider.of<Players>(context, listen: false);
    addPlayer() {
      players
          .addPlayer(
        nameController.text,
        positionController.text,
        imageController.text,
        context,
      )
          .then(
        (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Berhasil ditambahkan"),
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
        title: const Text("ADD PLAYER"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              addPlayer();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            children: [
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
                  addPlayer();
                },
              ),
              const SizedBox(height: 50),
              Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () {
                    addPlayer();
                  },
                  child: const Text(
                    "Submit",
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
