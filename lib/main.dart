import 'package:fire_flutter/providers/avatars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/players.dart';
import 'pages/detail_player_page.dart';
import 'pages/add_player_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Players()),
        ChangeNotifierProvider(create: (context) => Avatars()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        routes: {
          AddPlayer.routeName: (context) => const AddPlayer(),
          DetailPlayer.routeName: (context) => const DetailPlayer(),
        },
      ),
    );
  }
}
