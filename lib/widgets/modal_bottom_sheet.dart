import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:validators/validators.dart' as validator;

class ModalBottomSheet extends StatefulWidget {
  final customer;
  ModalBottomSheet({@required this.customer});
  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _address;
  String _phone;
  String _account;
  String _mac;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Edit Customer Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.name,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Invalid input!';
                        }
                        String error;
                        final sub = value.split(' ');
                        sub.forEach((element) {
                          if (!validator.isAlphanumeric(element)) {
                            error =
                                'Must be a combination of alphabet & number!';
                          } else if (value.length > 25) {
                            error = 'Name is too long!';
                          }
                        });
                        return error;
                      },
                      decoration: InputDecoration(
                        labelText: 'Customer name',
                        contentPadding: EdgeInsets.all(10),
                        prefixIcon: Icon(FlutterIcons.ios_person_ion),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onSaved: (newValue) {
                        _name = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.address,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Address field is empty!';
                        } else if (value.length > 50) {
                          return 'Address is too long!';
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
                      onSaved: (newValue) {
                        _address = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.phoneNumber,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (!validator.isNumeric(value)) {
                          return 'Phone number is Invalid!';
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
                      onSaved: (newValue) {
                        _phone = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.accountNumber,
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
                      onSaved: (newValue) {
                        _account = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.macId,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'MAC Id field is empty!';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'MAC Id',
                        contentPadding: EdgeInsets.all(10),
                        prefixIcon: Icon(FlutterIcons.ethernet_cable_mco),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onSaved: (newValue) {
                        _mac = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton.extended(
                      elevation: 0,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          widget.customer.name = _name;
                          widget.customer.address = _address;
                          widget.customer.phoneNumber = _phone;
                          widget.customer.accountNumber = _account;
                          widget.customer.macId = _mac;
                          Navigator.of(context).pop();
                        }
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      label: Text('Save'),
                      icon: Icon(FlutterIcons.content_save_edit_mco),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
