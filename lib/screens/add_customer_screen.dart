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
  String _selectedArea;

  void selectAreaField() {}

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: null,
                decoration: InputDecoration(
                  labelText: 'Customer name',
                  prefixIcon: Icon(FlutterIcons.ios_person_ion),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: null,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: null,
                decoration: InputDecoration(
                  labelText: 'Account number',
                  prefixIcon: Icon(FlutterIcons.account_badge_horizontal_mco),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: null,
                decoration: InputDecoration(
                  labelText: 'MAC number',
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
                  Text(
                    'Select Area :-',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                  DropdownButton(
                    value: _selectedArea,
                    hint: Text(
                      'Select Area\t',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    icon: Icon(FlutterIcons.ios_arrow_dropdown_ion),
                    iconEnabledColor: Theme.of(context).primaryColor,                      
                    items: areas
                        .map(
                          (area) => DropdownMenuItem(
                            child: Text(area.areaName),
                            value: area.areaName,
                          ),
                        )
                        .toList(),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    elevation: 10,
                    onChanged: (value) {
                      setState(() {
                        _selectedArea = value;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
