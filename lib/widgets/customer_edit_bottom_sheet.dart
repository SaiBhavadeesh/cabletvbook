import 'dart:ui';

import 'package:cableTvBook/services/databse_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';

class CustomerEditBottomSheet extends StatefulWidget {
  final Customer customer;
  CustomerEditBottomSheet({@required this.customer});
  @override
  _CustomerEditBottomSheetState createState() =>
      _CustomerEditBottomSheetState();
}

class _CustomerEditBottomSheetState extends State<CustomerEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _address;
  String _phone;
  String _account;
  String _mac;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.black45,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                  height: (size.height - top) * 0.375,
                  width: size.width,
                  color: Colors.transparent),
            ),
            Container(
              height: (size.height - top) * 0.625,
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
                child: SingleChildScrollView(
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
                        initialValue: widget.customer.phoneNumber.substring(5),
                        keyboardType: TextInputType.phone,
                        validator: phoneValidator,
                        decoration: inputDecoration(
                            label: 'Phone number',
                            icon: Icons.phone,
                            prefixText: '+91 '),
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
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            Map<String, dynamic> data = {};
                            if (widget.customer.name != _name)
                              data.addAll({'name': _name});
                            if (widget.customer.address != _address)
                              data.addAll({'address': _address});
                            if (widget.customer.phoneNumber != '+ 91 ' + _phone)
                              data.addAll({'phoneNumber': '+ 91 ' + _phone});
                            if (widget.customer.accountNumber != _account)
                              data.addAll({'accountNumber': _account});
                            if (widget.customer.macId != _mac)
                              data.addAll({'macId': _mac});
                            await DatabaseService.updateCustomerData(context,
                                data: data,
                                customerId: widget.customer.id,
                                areaId: widget.customer.areaId);
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
            ),
          ],
        ),
      ),
    );
  }
}
