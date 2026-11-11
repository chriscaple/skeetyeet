import 'package:flutter/material.dart';

import 'src/home_screen.dart';
import 'src/theme.dart';

void main() => runApp(const SkeetYeetApp());

class SkeetYeetApp extends StatelessWidget {
  const SkeetYeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkeetYeet',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}
