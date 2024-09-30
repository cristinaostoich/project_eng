import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progetto/screens/cigarette_counter.dart';
import 'package:progetto/screens/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CigaretteCounter()),
      ],
      child: MaterialApp(
        title: 'Nicotine Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}
