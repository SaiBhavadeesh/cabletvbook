import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ModalBottomSheet extends StatefulWidget {
  final customer;
  ModalBottomSheet({@required this.customer});
  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  final _macController = TextEditingController();
  bool _nameEdit = false;
  bool _addressEdit = false;
  bool _phoneEdit = false;
  bool _accountEdit = false;
  bool _macEdit = false;

  void clearInputs() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _accountController.clear();
    _macController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Column(
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
                    controller: _nameEdit ? _nameController : null,
                    initialValue: _nameEdit ? null : widget.customer.name,
                    onTap: () {
                      setState(() {
                        _nameEdit = true;
                      });
                    },
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
                    controller: _addressEdit ? _addressController : null,
                    initialValue: _addressEdit ? null : widget.customer.address,
                    minLines: 1,
                    maxLines: 2,
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      setState(() {
                        _addressEdit = true;
                      });
                    },
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
                    controller: _phoneEdit ? _phoneController : null,
                    initialValue:
                        _phoneEdit ? null : widget.customer.phoneNumber,
                    keyboardType: TextInputType.phone,
                    onTap: () {
                      setState(() {
                        _phoneEdit = true;
                      });
                    },
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
                    controller: _accountEdit ? _accountController : null,
                    initialValue:
                        _accountEdit ? null : widget.customer.accountNumber,
                    keyboardType: TextInputType.number,
                    onTap: () {
                      setState(() {
                        _accountEdit = true;
                      });
                    },
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
                    controller: _macEdit ? _macController : null,
                    initialValue: _macEdit ? null : widget.customer.macId,
                    onTap: () {
                      setState(() {
                        _macEdit = true;
                      });
                    },
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
                  FloatingActionButton.extended(
                    elevation: 0,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        widget.customer.name = _nameController.text == ''
                            ? widget.customer.name
                            : _nameController.text;
                        widget.customer.address = _addressController.text == ''
                            ? widget.customer.address
                            : _addressController.text;
                        widget.customer.phoneNumber =
                            _phoneController.text == ''
                                ? widget.customer.phoneNumber
                                : _phoneController.text;
                        widget.customer.accountNumber =
                            _accountController.text == ''
                                ? widget.customer.accountNumber
                                : _accountController.text;
                        widget.customer.macId = _macController.text == ''
                            ? widget.customer.macId
                            : _macController.text;
                        clearInputs();
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
    );
  }
}
