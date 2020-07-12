import 'dart:io';

import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/screens/add_customer_screen.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/widgets/home_drawer.dart';

class BottomTabsScreen extends StatefulWidget {
  static const routeName = '/bottomTabsScreen';
  final int index;
  BottomTabsScreen({this.index = 0});

  @override
  _BottomTabsScreenState createState() => _BottomTabsScreenState();
}

class _BottomTabsScreenState extends State<BottomTabsScreen> {
  int _currentIndex;
  File _profilePic;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cable Tv Book'),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: GestureDetector(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _profilePic == null
                    ? AssetImage('assets/images/drawer.jpg')
                    : FileImage(_profilePic),
              ),
              onTap: () async {
                _profilePic = await ImageGetter.getImageFromDevice(context);
                setState(() {});
              },
            ),
          )
        ],
      ),
      drawer: HomeDrawer(image: _profilePic),
      body: [HomeScreen(), SearchScreen(), AddCustomerScreen()][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        showUnselectedLabels: false,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(FlutterIcons.home_ant),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIcons.search1_ant),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIcons.adduser_ant),
            title: Text('Add customer'),
          ),
        ],
      ),
    );
  }
}
