import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cableTvBook/screens/profile_screen.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
import 'package:cableTvBook/screens/collection_screen.dart';

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
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
            ),
          ),
          Divider(
              height: 0,
              thickness: 2,
              endIndent: 0,
              indent: 0,
              color: Colors.black),
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
            onPressed: () async => await Authentication.signout(context),
            icon: Icon(Icons.power_settings_new),
            label: styledTitleText('Logout'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () async {
              final _emailLaunchUri =
                  Uri(scheme: 'mailto', path: 'srinivasasoftwares@gmail.com');
              if (await canLaunch(_emailLaunchUri.toString())) {
                try {
                  await launch(_emailLaunchUri.toString());
                } catch (_) {}
              } else {
                Fluttertoast.showToast(
                    msg: 'Could not process your request, Please try again');
              }
            },
            icon: Icon(Icons.help_outline),
            label: styledTitleText('Help'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () async {
              final url =
                  "https://sites.google.com/view/srinivasasoftwares-privacy";
              if (await canLaunch(url)) {
                try {
                  await launch(
                    url,
                    forceSafariVC: true,
                    forceWebView: true,
                    enableJavaScript: true,
                  );
                } catch (_) {}
              } else {
                Fluttertoast.showToast(
                    msg: 'Could not process your request, Please try again');
              }
            },
            icon: Icon(Icons.security),
            label: styledTitleText('Privacy Policy'),
          ),
          Divider(),
          FlatButton.icon(
            onPressed: () async {
              final url =
                  "https://sites.google.com/view/srinivasasoftwares-terms";
              if (await canLaunch(url)) {
                try {
                  await launch(
                    url,
                    forceSafariVC: true,
                    forceWebView: true,
                    enableJavaScript: true,
                  );
                } catch (_) {}
              } else {
                Fluttertoast.showToast(
                    msg: 'Could not process your request, Please try again');
              }
            },
            icon: Icon(Icons.notes_outlined),
            label: styledTitleText('Terms & Conditions'),
          ),
        ],
      ),
    );
  }
}
