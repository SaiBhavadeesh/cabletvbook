import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
  String _selectedArea;
  int _selectedPlan;

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Text(
                  'ADD NEW CUSTOMER',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
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
              SizedBox(height: 10),
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
                  prefixIcon: Icon(FlutterIcons.ios_person_ion),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
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
                  prefixIcon: Icon(FlutterIcons.address_ent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
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
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
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
                  prefixIcon: Icon(FlutterIcons.account_badge_horizontal_mco),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
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
                  prefixIcon: Icon(FlutterIcons.ethernet_cable_mco),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                    customers.add(
                      Customer(
                        id: DateTime.now().toString(),
                        name: _nameController.text.trim(),
                        phoneNumber: _phoneController.text.trim(),
                        address: _addressController.text.trim(),
                        accountNumber: _accountController.text.trim(),
                        macId: _macController.text.trim(),
                        networkProviderName: 'Sri Rama Cable Network',
                        area: _selectedArea,
                        currentPlan: _selectedPlan,
                      ),
                    );
                  } else if (_selectedArea == null || _selectedPlan == null) {
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
    );
  }
}
