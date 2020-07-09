import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:validators/validators.dart' as validator;

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/helpers/image_getter.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File _selectedImageFile;
  final Operator operatorDetails = getOperatorDetails();

  Widget getTitleValueEdit(String title, String value, Function function) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Text(value),
            ),
          ],
        ),
        if (function != null)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: function,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(operatorDetails.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImageFile == null
                        ? operatorDetails.profileImageLink == null
                            ? AssetImage('assets/images/profile_icon.png')
                            : NetworkImage(operatorDetails.profileImageLink)
                        : FileImage(_selectedImageFile),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(FlutterIcons.ios_camera_ion),
                        onPressed: () async {
                          _selectedImageFile =
                              await ImageGetter.getImageFromDevice(context);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: size.width,
              child: Text(
                'Primary Info : ',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Divider(
              indent: 0,
              endIndent: size.width * 0.75,
              thickness: 2,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 10),
            getTitleValueEdit('Email', operatorDetails.email, null),
            SizedBox(height: 10),
            getTitleValueEdit(
              'Name',
              operatorDetails.name,
              () => showDialog(
                context: context,
                builder: (ctx) {
                  final formKey = GlobalKey<FormState>();
                  String name;
                  return AlertDialog(
                    content: Form(
                      key: formKey,
                      child: TextFormField(
                        initialValue: operatorDetails.name,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Invalid input!';
                          }
                          String error;
                          final sub = value.split(' ');
                          sub.forEach((element) {
                            if (!validator.isAlphanumeric(element)) {
                              error =
                                  'Must be a combination of alphabet & number';
                            } else if (value.length > 25) {
                              error = 'Name is too long!';
                            }
                          });
                          return error;
                        },
                        decoration: InputDecoration(
                          labelText: 'Edit Name',
                        ),
                        onSaved: (value) {
                          name = value;
                        },
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Cancel'),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            setState(() {
                              operatorDetails.name = name;
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            getTitleValueEdit(
              'Network name',
              operatorDetails.networkName,
              () => showDialog(
                context: context,
                builder: (ctx) {
                  final formKey = GlobalKey<FormState>();
                  String networkName;
                  return AlertDialog(
                    content: Form(
                      key: formKey,
                      child: TextFormField(
                        initialValue: operatorDetails.networkName,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Invalid input!';
                          }
                          String error;
                          final sub = value.split(' ');
                          sub.forEach((element) {
                            if (!validator.isAlpha(element)) {
                              error = 'Must be an alphabet';
                            } else if (value.length > 40) {
                              error = 'Name is too long!';
                            }
                          });
                          return error;
                        },
                        decoration: InputDecoration(
                          labelText: 'Edit Network name',
                        ),
                        onSaved: (value) {
                          networkName = value;
                        },
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Cancel'),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            setState(() {
                              operatorDetails.networkName = networkName;
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            getTitleValueEdit(
              'Phone number',
              operatorDetails.phoneNumber,
              () => showDialog(
                context: context,
                builder: (ctx) {
                  final formKey = GlobalKey<FormState>();
                  String phoneNumber;
                  return AlertDialog(
                    content: Form(
                      key: formKey,
                      child: TextFormField(
                        initialValue: operatorDetails.phoneNumber.substring(4),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (!validator.isNumeric(value)) {
                            return 'Phone number is Invalid!';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Edit Phone number',
                          prefixText: '+ 91 ',
                        ),
                        onSaved: (value) {
                          phoneNumber = '+ 91 ' + value;
                        },
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Cancel'),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            setState(() {
                              operatorDetails.phoneNumber = phoneNumber;
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
