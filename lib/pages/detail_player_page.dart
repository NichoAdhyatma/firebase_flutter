import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/avatars.dart';
import '../providers/players.dart';

class DetailPlayer extends StatefulWidget {
  static const routeName = "/detail-player";

  const DetailPlayer({super.key});

  @override
  State<DetailPlayer> createState() => _DetailPlayerState();
}

class _DetailPlayerState extends State<DetailPlayer> {
  bool isInit = true;

  String imageUrl = "";

  int selectedImage = -1;

  setImage(String url) {
    imageUrl = url;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<Avatars>(context).generateImages();
      isInit = !isInit;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final players = Provider.of<Players>(context, listen: false);
    final avatars = Provider.of<Avatars>(context, listen: false);

    final playerId = ModalRoute.of(context)!.settings.arguments as String;
    final selectPLayer = players.selectById(playerId);

    final TextEditingController nameController =
        TextEditingController(text: selectPLayer.name);
    final TextEditingController positionController =
        TextEditingController(text: selectPLayer.position);

    editPlayer() {
      if (_formKey.currentState!.validate()) {
        players
            .editPlayer(
          playerId,
          nameController.text,
          positionController.text,
          imageUrl.isEmpty ? selectPLayer.imageUrl! : imageUrl,
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
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("DETAIL PLAYER"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: selectPLayer.imageUrl!,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Image.network("https://api.multiavatar.com/0.png"),
                  ),
                ),
              ),
              TextFormField(
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(labelText: "Nama"),
                textInputAction: TextInputAction.next,
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your Name";
                  }
                  return null;
                },
              ),
              TextFormField(
                autocorrect: false,
                decoration: const InputDecoration(labelText: "Posisi"),
                textInputAction: TextInputAction.next,
                controller: positionController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your Position";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Select New Avatar",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(
                      width: MediaQuery.of(context).size.width, height: 100),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemCount: avatars.length,
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: TextButton(
                        onPressed: () {
                          setImage(avatars.images[index]);
                          setState(
                            () {
                              if (selectedImage != index) {
                                selectedImage = index;
                              } else {
                                selectedImage = -1;
                                imageUrl = selectPLayer.imageUrl!;
                              }
                            },
                          );
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: BorderSide(
                                  width: selectedImage == index ? 5 : 0,
                                  color: Colors.blue),
                            ),
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: avatars.images[index],
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.network(
                            "https://api.multiavatar.com/0.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isInit = true;
                          avatars.notifyListeners();
                        });
                      },
                      child: const Icon(Icons.refresh),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    OutlinedButton(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
