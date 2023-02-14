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
    print("Didchange");
    if (isInit) {
      Provider.of<Players>(context)
          .initializeData()
          .whenComplete(() => isInit = false);
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    print("DidUpdateWIdget");
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final allPlayerProvider = Provider.of<Players>(context);
    print("rebuild");

    return Scaffold(
      appBar: AppBar(
        title: const Text("ALL PLAYERS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddPlayer.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(
                () {
                  isInit = true;
                  allPlayerProvider.allPlayer.clear();
                  allPlayerProvider.notifyListeners();
                },
              );
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
                  isInit
                      ? const CircularProgressIndicator()
                      : const Text(
                          "No Data",
                          style: TextStyle(fontSize: 25),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 10,
                thickness: 1,
                color: Colors.grey[500],
              ),
              itemCount: allPlayerProvider.jumlahPlayer,
              itemBuilder: (context, index) {
                var id = allPlayerProvider.allPlayer[index].id;
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
                        imageUrl: allPlayerProvider.allPlayer[index].imageUrl!,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.network(
                          "https://api.multiavatar.com/0.png",
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    allPlayerProvider.allPlayer[index].name!,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        allPlayerProvider.allPlayer[index].position!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        DateFormat.yMMMMd().format(
                            allPlayerProvider.allPlayer[index].createdAt!),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      allPlayerProvider.deletePlayer(id!).then(
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
                              content:
                                  const Text("Check your internet connection!"),
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
    );
  }
}
