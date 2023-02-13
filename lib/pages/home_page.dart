import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../pages/detail_player_page.dart';
import '../pages/add_player_page.dart';

import '../providers/players.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isInit = true;
  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<Players>(context).initializeData();
      isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final allPlayerProvider = Provider.of<Players>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ALL PLAYERS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AddPlayer.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                allPlayerProvider.allPlayer.clear();
                allPlayerProvider.initializeData();
              });
            },
          ),
        ],
      ),
      body: (allPlayerProvider.jumlahPlayer == 0)
          ? SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No Data",
                    style: TextStyle(fontSize: 25),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AddPlayer.routeName);
                    },
                    child: const Text(
                      "Add Player",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            )
          : Consumer<Players>(
              builder: (context, value, child) => ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  height: 10,
                  thickness: 1,
                  color: Colors.grey[500],
                ),
                itemCount: value.jumlahPlayer,
                itemBuilder: (context, index) {
                  var id = value.allPlayer[index].id;
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        DetailPlayer.routeName,
                        arguments: id,
                      );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CachedNetworkImage(
                          imageUrl: value.allPlayer[index].imageUrl!,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.network(
                            "https://api.multiavatar.com/0.png",
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      value.allPlayer[index].name!,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          value.allPlayer[index].position!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          DateFormat.yMMMMd()
                              .format(value.allPlayer[index].createdAt!),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        value.deletePlayer(id!).then(
                          (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Berhasil dihapus"),
                                duration: Duration(milliseconds: 1000),
                              ),
                            );
                          },
                        ).catchError(
                          (err) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Server Error $err"),
                                content: const Text(
                                    "Check your internet connection!"),
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
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
