import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_flutter/providers/avatars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/players.dart';

class AddPlayer extends StatefulWidget {
  static const routeName = "/add-player";

  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() => _AddPlayerState();
}

class _AddPlayerState extends State<AddPlayer> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController positionController = TextEditingController();

  final TextEditingController imageController = TextEditingController(text: "");

  bool isInit = true;
  bool select = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<Avatars>(context)
          .generateImages()
          .whenComplete(() => isInit = !isInit);
    }
    super.didChangeDependencies();
  }

  setImage(String url) {
    imageController.text = url;
  }

  int selectedImage = -1;

  @override
  Widget build(BuildContext context) {
    final players = Provider.of<Players>(context, listen: false);
    final avatars = Provider.of<Avatars>(context);

    addPlayer() {
      if (_formKey.currentState!.validate()) {
        if (imageController.text.isEmpty) {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Avatar is not selected"),
              content: const Text("Select Yout Avatar..."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Okay"),
                ),
              ],
            ),
          );
        }
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
                title: const Text("Server Error"),
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
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autocorrect: false,
                autofocus: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your Position";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: "Nama"),
                textInputAction: TextInputAction.next,
                controller: nameController,
              ),
              TextFormField(
                autocorrect: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your Position";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: "Posisi"),
                textInputAction: TextInputAction.next,
                controller: positionController,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Select Avatar",
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
                  constraints: BoxConstraints.tightFor(
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
                                setImage("https://api.multiavatar.com/0.png");
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
                          errorWidget: (context, url, error) =>
                              const FlutterLogo(),
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
                          selectedImage = -1;
                          setImage("");
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
                        addPlayer();
                      },
                      child: const Text(
                        "Add",
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
