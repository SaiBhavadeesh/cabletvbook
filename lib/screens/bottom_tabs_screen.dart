import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/widgets/home_drawer.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:cableTvBook/screens/add_customer_screen.dart';

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
                backgroundImage: operatorDetails.profileImageLink == null
                    ? _profilePic == null
                        ? AssetImage('assets/images/profile_icon.png')
                        : FileImage(_profilePic)
                    : NetworkImage(operatorDetails.profileImageLink),
              ),
              onTap: () async {
                _profilePic = await ImageGetter.getImageFromDevice(context);
                if (_profilePic != null) {
                  await DatabaseService.uploadProfilePicture(context,
                      file: _profilePic);
                  setState(() {});
                }
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
      bottomSheet: firebaseUser.isEmailVerified
          ? null
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.elliptical(50, 50))),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Please verify your email & Restart the App\n\n',
                  children: [
                    TextSpan(
                        text:
                            'Go to ( \u2630 -> settings ) to get link to verify email',
                        style: TextStyle(fontSize: 16))
                  ],
                  style: TextStyle(color: Colors.white, fontSize: 26),
                ),
              ),
            ),
    );
  }
}
