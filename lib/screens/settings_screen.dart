import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settingsScreen';

  Widget getTitle(BuildContext context, String title) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget getdetailText(BuildContext context, String text, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Divider(
            indent: 0,
            endIndent: size.width * 0.9,
            thickness: 2,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('General Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getTitle(
            context,
            'Account Settings',
          ),
          getdetailText(
            context,
            'Change Email',
            size,
          ),
          getdetailText(
            context,
            'Change Phone number',
            size,
          ),
          getTitle(
            context,
            'Privacy Settings',
          ),
          getdetailText(
            context,
            'Change Security pin',
            size,
          ),
          getdetailText(
            context,
            'Change Password',
            size,
          ),
        ],
      ),
    );
  }
}
