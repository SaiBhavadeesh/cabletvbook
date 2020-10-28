import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/widgets/home_drawer.dart';
import 'package:cableTvBook/screens/home_screen.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
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
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.delayed(Duration(seconds: 0), () {
          if (_count == 0) {
            _count++;
            Fluttertoast.showToast(
                msg: 'Press again to exit',
                backgroundColor: Colors.grey[800],
                textColor: Colors.white);
            Future.delayed(Duration(seconds: 2), () => _count = 0);
            return false;
          } else
            return true;
        });
      },
      child: Scaffold(
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
        body: [
          HomeScreen(),
          SearchScreen(),
          AddCustomerScreen()
        ][_currentIndex],
        bottomNavigationBar: ConvexAppBar(
          elevation: 5,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          initialActiveIndex: _currentIndex,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withRed(600),
              Theme.of(context).primaryColor.withRed(400),
              Theme.of(context).primaryColor.withRed(200),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          style: TabStyle.textIn,
          items: [
            TabItem(
                icon: Icon(FlutterIcons.home_ant,
                    color: _currentIndex == 0 ? Colors.white : Colors.black),
                title: 'Home'),
            TabItem(
                icon: Icon(FlutterIcons.search1_ant,
                    color: _currentIndex == 1 ? Colors.white : Colors.black),
                title: 'Search'),
            TabItem(
                icon: Icon(FlutterIcons.adduser_ant,
                    color: _currentIndex == 2 ? Colors.white : Colors.black),
                title: 'Add customer'),
          ],
        ),
        bottomSheet: firebaseUser.emailVerified
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
      ),
    );
  }
}
