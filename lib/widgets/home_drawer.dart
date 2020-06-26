import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Drawer(
      elevation: 5,
      child: Column(
        children: <Widget>[
          Container(
            height: height * 0.25,
            width: double.infinity,
            child: Image.asset(
              'assets/images/drawer.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
        ],
      ),
    );
  }
}
