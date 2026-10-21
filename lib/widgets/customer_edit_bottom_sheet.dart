import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/services/database_services.dart';

class CustomerEditBottomSheet extends StatefulWidget {
  final Customer customer;
  const CustomerEditBottomSheet({super.key, required this.customer});

  @override
  _CustomerEditBottomSheetState createState() =>
      _CustomerEditBottomSheetState();
}

class _CustomerEditBottomSheetState extends State<CustomerEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _address;
  late String _phone;
  late String _account;
  late String _mac;

  @override
  void initState() {
    super.initState();
    _name = widget.customer.name;
    _address = widget.customer.address;
    _phone = widget.customer.phoneNumber.length >= 5
        ? widget.customer.phoneNumber.substring(5)
        : widget.customer.phoneNumber;
    _account = widget.customer.accountNumber;
    _mac = widget.customer.macId;
  }

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
                color: Colors.transparent,
              ),
            ),
            Container(
              height: (size.height - top) * 0.625,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Edit Customer Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: widget.customer.name,
                        validator: nameValidator,
                        decoration: inputDecoration(
                          label: 'Customer name',
                          icon: Icons.person,
                        ),
                        onSaved: (newValue) {
                          _name = newValue ?? '';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: widget.customer.address,
                        keyboardType: TextInputType.text,
                        validator: addressValidator,
                        decoration: inputDecoration(
                          label: 'Address',
                          icon: Icons.location_on,
                        ),
                        onSaved: (newValue) {
                          _address = newValue ?? '';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: _phone,
                        keyboardType: TextInputType.phone,
                        validator: phoneValidator,
                        decoration: inputDecoration(
                          label: 'Phone number',
                          icon: Icons.phone,
                          prefixText: '+91 ',
                        ),
                        onSaved: (newValue) {
                          _phone = newValue ?? '';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: widget.customer.accountNumber,
                        keyboardType: TextInputType.number,
                        validator: defaultValidator,
                        decoration: inputDecoration(
                          label: 'Account number',
                          icon: Icons.badge,
                        ),
                        onSaved: (newValue) {
                          _account = newValue ?? '';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: widget.customer.macId,
                        validator: defaultValidator,
                        decoration: inputDecoration(
                          label: 'MAC Id',
                          icon: Icons.router,
                        ),
                        onSaved: (newValue) {
                          _mac = newValue ?? '';
                        },
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.extended(
                        elevation: 0,
                        onPressed: () async {
                          if (_formKey.currentState?.validate() == true) {
                            _formKey.currentState?.save();
                            Map<String, dynamic> data = {};
                            if (widget.customer.name != _name) {
                              data.addAll({'name': _name});
                            }
                            if (widget.customer.address != _address) {
                              data.addAll({'adrs': _address});
                            }
                            if (widget.customer.phoneNumber != '+ 91 $_phone') {
                              data.addAll({'pn': '+ 91 $_phone'});
                            }
                            if (widget.customer.accountNumber != _account) {
                              data.addAll({'accNo': _account});
                            }
                            if (widget.customer.macId != _mac) {
                              data.addAll({'macId': _mac});
                            }
                            await DatabaseService.updateCustomerData(
                              context,
                              data: data,
                              customerId: widget.customer.id,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        label: const Text('Save'),
                        icon: const Icon(Icons.save),
                      ),
                      const SizedBox(height: 5),
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
