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
  final networkName;
  final username;
  final phoneNumber;
  BottomTabsScreen({
    this.networkName = 'Sri Rama Cable Network',
    this.username = 'Srinivasa Rao',
    this.phoneNumber = '+ 91 8106263461',
  });

  @override
  _BottomTabsScreenState createState() => _BottomTabsScreenState();
}

class _BottomTabsScreenState extends State<BottomTabsScreen> {
  int _currentIndex = 0;
  File _profilePic;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cable Tv Book'),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all((size.height - top) * 0.007),
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
        bottom: PreferredSize(
          child: Column(
            children: <Widget>[
              Text(
                widget.networkName,
                style: TextStyle(
                  fontSize: (size.height - top) * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.width * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.username,
                      style: TextStyle(
                        fontSize: (size.height - top) * 0.023,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      widget.phoneNumber,
                      style: TextStyle(
                        fontSize: (size.height - top) * 0.023,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          preferredSize: Size(size.width, (size.height - top) * 0.06),
        ),
      ),
      drawer: HomeDrawer(image: _profilePic),
      body: [HomeScreen(), SearchScreen(), AddCustomerScreen()][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
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
