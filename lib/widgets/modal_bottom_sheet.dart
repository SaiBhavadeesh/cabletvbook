import 'dart:ui';

import 'package:cableTvBook/global/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/box_decoration.dart';

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
                      validator: nameValidator,
                      decoration: inputDecoration(
                          label: 'Customer name',
                          icon: FlutterIcons.ios_person_ion),
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
                      decoration: inputDecoration(
                          label: 'Address', icon: FlutterIcons.address_ent),
                      onSaved: (newValue) {
                        _address = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.phoneNumber,
                      keyboardType: TextInputType.phone,
                      validator: phoneValidator,
                      decoration: inputDecoration(
                          label: 'Phone number', icon: Icons.phone),
                      onSaved: (newValue) {
                        _phone = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.accountNumber,
                      keyboardType: TextInputType.number,
                      validator: defaultValidator,
                      decoration: inputDecoration(
                          label: 'Account number',
                          icon: FlutterIcons.account_badge_horizontal_mco),
                      onSaved: (newValue) {
                        _account = newValue;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.customer.macId,
                      validator: defaultValidator,
                      decoration: inputDecoration(
                          label: 'MAC Id',
                          icon: FlutterIcons.ethernet_cable_mco),
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
