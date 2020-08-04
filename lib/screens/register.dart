import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Register extends StatefulWidget {
  static const routeName = '/register';
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup your Network'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(8),
            decoration: defaultBoxDecoration(context, true),
            child: Text(
              'Add your primary details',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          TextFormField(
            decoration: inputDecoration(
                label: 'Username', icon: FlutterIcons.ios_person_ion),
          ),
          SizedBox(height: 10),
          TextFormField(
            // initialValue: email,
            enabled: false,
            decoration: inputDecoration(label: 'E-Mail', icon: Icons.email),
          ),
          SizedBox(height: 10),
          TextFormField(
            // initialValue: phoneNumber,
            enabled: false,
            decoration:
                inputDecoration(label: 'Phone number', icon: Icons.phone),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration:
                inputDecoration(label: 'Network name', icon: Icons.business_center),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(8),
            decoration: defaultBoxDecoration(context, true),
            child: Text(
              'Add your default area and plan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          TextFormField(
            decoration: inputDecoration(
                label: 'Default area', icon: Icons.add_location),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: inputDecoration(
                label: 'Default plan', icon: FlutterIcons.currency_inr_mco),
          ),
          SizedBox(height: 20),
          defaultbutton(
              context: context,
              function: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  BottomTabsScreen.routeName, (route) => false),
              title: 'Submit'),
        ],
      ),
    );
  }
}
