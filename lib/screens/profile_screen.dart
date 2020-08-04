import 'dart:io';
import 'dart:ui';

import 'package:cableTvBook/global/default_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:validators/validators.dart' as validator;

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/global/box_decoration.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File _selectedImageFile;
  final Operator operatorDetails = getOperatorDetails();

  Widget getTitle(BuildContext context, String title) {
    return Column(
      children: <Widget>[
        Container(
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
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
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
            getTitle(context, 'Primary Information'),
            SizedBox(height: 10),
            getTitleValueEdit('Email', operatorDetails.email, null),
            SizedBox(height: 10),
            getTitleValueEdit(
                'Phone number', operatorDetails.phoneNumber, null),
            SizedBox(height: 10),
            getTitleValueEdit(
              'Name',
              operatorDetails.name,
              () => showDialog(
                context: context,
                builder: (ctx) {
                  final formKey = GlobalKey<FormState>();
                  String name;
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AlertDialog(
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
                    ),
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
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AlertDialog(
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
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            getTitle(context, 'Secondary Information'),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                'Areas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: sweepGradientDecoration(context),
                  child: Text(
                    operatorDetails.areas[index].areaName,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
              itemCount: operatorDetails.areas.length,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                'Plans',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              itemBuilder: (context, index) {
                return InkResponse(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: sweepGradientDecoration(context),
                    child: Text(
                      operatorDetails.plans[index].toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              itemCount: operatorDetails.plans.length,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: defaultbutton(
                  context: context,
                  function: () {},
                  title: 'Add Plan',
                  width: 18,
                  height: 12),
            ),
          ],
        ),
      ),
    );
  }
}
