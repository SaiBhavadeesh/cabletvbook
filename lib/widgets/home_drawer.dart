import 'dart:io';

import 'package:cableTvBook/screens/collection_screen.dart';
import 'package:cableTvBook/screens/login_register_screen.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:cableTvBook/screens/profile_screen.dart';

class HomeDrawer extends StatelessWidget {
  final File image;

  Widget styledTitleText(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  HomeDrawer({@required this.image});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Drawer(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: height * 0.25,
            width: double.infinity,
            child: image == null
                ? Image.asset(
                    'assets/images/drawer.jpg',
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(height: height * 0.01),
          FlatButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(ProfileScreen.routeName),
            icon: Icon(Icons.account_circle),
            label: styledTitleText('Profile'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(CollectionScreen.routeName),
            icon: Icon(Icons.collections_bookmark),
            label: styledTitleText('Collection Information'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
            icon: Icon(Icons.settings),
            label: styledTitleText('Settings'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                LoginRegisterScreen.routeName, (route) => false),
            icon: Icon(Icons.power_settings_new),
            label: styledTitleText('Logout'),
          ),
        ],
      ),
    );
  }
}
