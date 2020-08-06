import 'dart:io';
import 'dart:ui';

import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

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
  String _selectedArea;
  double _selectedPlan;
  File _selectedImageFile;
  bool _checked = false;

  void _selectAreaField(String value) {
    setState(() {
      _selectedArea = value;
    });
  }

  void _selectPlanField(double value) {
    setState(() {
      _selectedPlan = value;
    });
  }

  void uploadPhotoToDatabase() {}

  void saveDetails() async {
    if (_formKey.currentState.validate() &&
        _selectedArea != null &&
        _selectedPlan != null) {
      _formKey.currentState.save();
      final newCustomer = Customer(
        id: null,
        name: _nameController.text.trim(),
        phoneNumber: '+ 91 ' + _phoneController.text.trim(),
        address: _addressController.text.trim(),
        accountNumber: _accountController.text.trim(),
        macId: _macController.text.trim(),
        networkProviderId: operatorDetails.id,
        startDate: null,
        area: _selectedArea,
        currentPlan: _selectedPlan,
        currentStatus: _checked ? 'Active' : 'Inactive',
      );
      print(newCustomer.toJson());
      try {} catch (_) {}
      // operatorDetails.areas.forEach((element) {
      //   if (element.areaName == _selectedArea) {
      //     element.totalAccounts++;
      //     element.inActiveAccounts++;
      //   }
      // });
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //     BottomTabsScreen.routeName, (route) => false);
    } else if (_selectedArea == null || _selectedPlan == null) {
      String msg;
      if (_selectedArea == null && _selectedPlan == null)
        msg = 'area and plan';
      else
        msg = _selectedArea == null ? 'area' : 'plan';
      DefaultDialogBox.errorDialog(context,
          title: 'Alert', content: 'Please select $msg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stack(
        children: <Widget>[
          ListView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: <Widget>[
              SizedBox(height: 45),
              Align(
                alignment: Alignment.center,
                child: Stack(
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
              SizedBox(height: 5),
              TextFormField(
                controller: _nameController,
                validator: nameValidator,
                decoration: inputDecoration(
                    icon: FlutterIcons.ios_person_ion, label: 'Customer name'),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.text,
                validator: addressValidator,
                decoration: inputDecoration(
                    icon: FlutterIcons.address_ent, label: 'Address'),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: phoneValidator,
                decoration: inputDecoration(
                    icon: Icons.phone,
                    label: 'Phone number',
                    prefixText: '+91 '),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                validator: defaultValidator,
                decoration: inputDecoration(
                    icon: FlutterIcons.account_badge_horizontal_mco,
                    label: 'Account number'),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _macController,
                validator: defaultValidator,
                decoration: inputDecoration(
                    icon: FlutterIcons.ethernet_cable_mco, label: 'MAC Id'),
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      ...operatorDetails.areas.map(
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
                      ...operatorDetails.plans.map(
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
              Divider(height: 0),
              CheckboxListTile(
                activeColor: Colors.green,
                controlAffinity: ListTileControlAffinity.leading,
                value: _checked,
                title: Text('Check this box, if already paid bill.'),
                onChanged: (value) {
                  setState(() {
                    _checked = !_checked;
                  });
                },
              ),
              defaultbutton(
                  context: context, function: saveDetails, title: 'Submit'),
            ],
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
