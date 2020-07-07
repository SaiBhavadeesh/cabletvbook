import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:image_picker/image_picker.dart';

import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/models/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  static const routeName = '/addCustomerScreen';

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  final _macController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _selectedArea;
  int _selectedPlan;
  File _selectedImageFile;

  void _selectAreaField(String value) {
    setState(() {
      _selectedArea = value;
    });
  }

  void _selectPlanField(int value) {
    setState(() {
      _selectedPlan = value;
    });
  }

  void _getImageFromDevice(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlatButton.icon(
              onPressed: () async {
                final pickedImage =
                    await _imagePicker.getImage(source: ImageSource.camera);
                try {
                  _selectedImageFile = File(pickedImage.path);
                } catch (error) {}
              },
              icon: Icon(FlutterIcons.ios_camera_ion),
              label: Text('Take Image'),
            ),
            FlatButton.icon(
              onPressed: () async {
                final pickedImage =
                    await _imagePicker.getImage(source: ImageSource.gallery);
                try {
                  _selectedImageFile = File(pickedImage.path);
                } catch (error) {}
              },
              icon: Icon(FlutterIcons.ios_images_ion),
              label: Text('Select Image'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 40),
                  Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedImageFile == null
                            ? AssetImage(
                                'assets/images/profile_icon.png',
                              )
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
                            onPressed: () => _getImageFromDevice(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Name field is empty!';
                      } else if (value.length > 25) {
                        return 'Name is too long!';
                      } else if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
                        return 'Name must start with a letter!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Customer name',
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(FlutterIcons.ios_person_ion),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _addressController,
                    minLines: 1,
                    maxLines: 2,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Address field is empty!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Address',
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(FlutterIcons.address_ent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Phone number field is empty!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Account number field is empty!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Account number',
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon:
                          Icon(FlutterIcons.account_badge_horizontal_mco),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _macController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Account number field is empty!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'MAC number',
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(FlutterIcons.ethernet_cable_mco),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Select Area : ',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                          ...areas.map(
                            (area) {
                              return Row(
                                children: <Widget>[
                                  Radio(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    activeColor: Theme.of(context).primaryColor,
                                    value: area.areaName,
                                    groupValue: _selectedArea,
                                    onChanged: _selectAreaField,
                                  ),
                                  Text(area.areaName),
                                ],
                              );
                            },
                          ).toList(),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Select Plan : ',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                          ...plans.map(
                            (plan) {
                              return Row(
                                children: <Widget>[
                                  Radio(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    activeColor: Theme.of(context).primaryColor,
                                    value: plan,
                                    groupValue: _selectedPlan,
                                    onChanged: _selectPlanField,
                                  ),
                                  Text('\u20B9 ' + plan.toString()),
                                ],
                              );
                            },
                          ).toList(),
                        ],
                      ),
                    ],
                  ),
                  FloatingActionButton.extended(
                    label: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (_formKey.currentState.validate() &&
                          _selectedArea != null &&
                          _selectedPlan != null) {
                        _formKey.currentState.save();
                        final newCustomer = Customer(
                          id: DateTime.now().toString(),
                          name: _nameController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                          accountNumber: _accountController.text.trim(),
                          macId: _macController.text.trim(),
                          networkProviderName: 'Sri Rama Cable Network',
                          startDate: DateTime.now(),
                          area: _selectedArea,
                          currentPlan: _selectedPlan,
                        );
                        areas.forEach((element) {
                          if (element.areaName == _selectedArea) {
                            element.totalAccounts++;
                            element.inActiveAccounts++;
                          }
                        });
                        customers.add(newCustomer);
                        _nameController.clear();
                        _phoneController.clear();
                        _addressController.clear();
                        _accountController.clear();
                        _macController.clear();
                        setState(() {
                          _selectedArea = null;
                          _selectedPlan = null;
                        });
                      } else if (_selectedArea == null ||
                          _selectedPlan == null) {
                        String msg;
                        if (_selectedArea == null && _selectedPlan == null)
                          msg = 'area and plan';
                        else
                          msg = _selectedArea == null ? 'area' : 'plan';
                        DefaultDialogBox.errorDialog(
                            context, 'Alert', 'Please select $msg');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 50,
            right: 50,
            child: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Text(
                'ADD NEW CUSTOMER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(5, 5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
