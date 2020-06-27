import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
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
            child: Image.asset(
              'assets/images/drawer.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: height * 0.01),
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.account_circle),
            label: Text('Profile settings'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.collections_bookmark),
            label: Text('Collection Information'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.power_settings_new),
            label: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
