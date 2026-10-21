import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cableTvBook/screens/profile_screen.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/screens/settings_screen.dart';
import 'package:cableTvBook/screens/collection_screen.dart';

class HomeDrawer extends StatelessWidget {
  final File? image;

  const HomeDrawer({super.key, this.image});

  Widget styledTitleText(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Drawer(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: height * 0.25,
            width: double.infinity,
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
            ),
          ),
          const Divider(
            height: 0,
            thickness: 2,
            endIndent: 0,
            indent: 0,
            color: Colors.black,
          ),
          SizedBox(height: height * 0.01),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              alignment: Alignment.centerLeft,
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(ProfileScreen.routeName),
            icon: const Icon(Icons.account_circle),
            label: styledTitleText('Profile'),
          ),
          const Divider(),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              alignment: Alignment.centerLeft,
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(CollectionScreen.routeName),
            icon: const Icon(Icons.collections_bookmark),
            label: styledTitleText('Collection Information'),
          ),
          const Divider(),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              alignment: Alignment.centerLeft,
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
            label: styledTitleText('Settings'),
          ),
          const Divider(),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              alignment: Alignment.centerLeft,
            ),
            onPressed: () async => await Authentication.signout(context),
            icon: const Icon(Icons.power_settings_new),
            label: styledTitleText('Logout'),
          ),
          const Divider(),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              alignment: Alignment.centerLeft,
            ),
            onPressed: () async {
              final emailLaunchUri =
                  Uri(scheme: 'mailto', path: 'srinivasasoftwares@gmail.com');
              if (await canLaunchUrl(emailLaunchUri)) {
                try {
                  await launchUrl(emailLaunchUri);
                } catch (_) {}
              } else {
                Fluttertoast.showToast(
                    msg: 'Could not process your request, Please try again');
              }
            },
            icon: const Icon(Icons.help_outline),
            label: styledTitleText('Help'),
          ),
          const Divider(),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              alignment: Alignment.centerLeft,
            ),
            onPressed: () async {
              final uri = Uri.parse(
                  "https://sites.google.com/view/srinivasasoftwares-privacy");
              if (await canLaunchUrl(uri)) {
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              } else {
                Fluttertoast.showToast(
                    msg: 'Could not process your request, Please try again');
              }
            },
            icon: const Icon(Icons.security),
            label: styledTitleText('Privacy Policy'),
          ),
          const Divider(),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              alignment: Alignment.centerLeft,
            ),
            onPressed: () async {
              final uri = Uri.parse(
                  "https://sites.google.com/view/srinivasasoftwares-terms");
              if (await canLaunchUrl(uri)) {
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              } else {
                Fluttertoast.showToast(
                    msg: 'Could not process your request, Please try again');
              }
            },
            icon: const Icon(Icons.notes_outlined),
            label: styledTitleText('Terms & Conditions'),
          ),
        ],
      ),
    );
  }
}
