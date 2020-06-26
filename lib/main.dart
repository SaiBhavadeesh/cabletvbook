import 'package:flutter/material.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cable Tv Book',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(14, 137, 234, 1),
        accentColor: Colors.white,
      ),
      themeMode: ThemeMode.system,
      home: BottomTabsScreen(),
    );
  }
}
