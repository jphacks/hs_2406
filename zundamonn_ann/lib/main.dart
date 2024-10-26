import 'package:flutter/material.dart';

import 'select.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zundamon\'s All Night Nippon',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MoodSelectionPage(),
    );
  }
}
