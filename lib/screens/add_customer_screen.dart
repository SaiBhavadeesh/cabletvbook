import 'dart:io';

import 'package:cableTvBook/helpers/upload_customers_from_file.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:flutter/material.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

class AddCustomerScreen extends StatefulWidget {
  static const routeName = '/addCustomerScreen';

  const AddCustomerScreen({super.key});

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
  String? _selectedAreaId;
  double? _selectedPlan;
  File? _selectedImageFile;

  void _selectAreaField(String? value) {
    if (value != null) {
      setState(() {
        _selectedAreaId = value;
      });
    }
  }

  void _selectPlanField(double? value) {
    if (value != null) {
      setState(() {
        _selectedPlan = value;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    _macController.dispose();
    super.dispose();
  }

  void saveDetails() async {
    final op = operatorDetails;
    if (_formKey.currentState?.validate() == true &&
        _selectedAreaId != null &&
        _selectedPlan != null &&
        op != null) {
      _formKey.currentState?.save();
      final newCustomer = Customer(
        id: '',
        name: _nameController.text.trim(),
        phoneNumber: '+ 91 ${_phoneController.text.trim()}',
        address: _addressController.text.trim(),
        accountNumber: _accountController.text.trim(),
        macId: _macController.text.trim(),
        networkProviderId: op.id,
        areaId: _selectedAreaId!,
        expiryMonth: 0,
        currentPlan: _selectedPlan!,
        runningYear: DateTime.now().year,
        currentStatus: 'Inactive',
      );
      await DatabaseService.addNewCustomer(
        context,
        customer: newCustomer,
        file: _selectedImageFile,
      );
    } else if (_selectedPlan == null || _selectedAreaId == null) {
      String msg;
      if (_selectedAreaId == null && _selectedPlan == null) {
        msg = 'area and plan';
      } else if (_selectedAreaId == null) {
        msg = 'area';
      } else {
        msg = 'plan';
      }
      DefaultDialogBox.errorDialog(context,
          title: 'Alert', content: 'Please select $msg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (areas.isEmpty) {
      return const Center(
        child: Text(
          'No area to add a customer!\n\nPlease add an Area.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Stack(
        children: <Widget>[
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: <Widget>[
              const SizedBox(height: 45),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImageFile != null
                          ? FileImage(_selectedImageFile!)
                          : const AssetImage('assets/images/default_profile.jpg')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 5,
                      left: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () async {
                            final file =
                                await ImageGetter.getImageFromDevice(context);
                            if (file != null) {
                              setState(() {
                                _selectedImageFile = file;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _nameController,
                validator: nameValidator,
                decoration: inputDecoration(
                  icon: Icons.person,
                  label: 'Customer name',
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.text,
                validator: addressValidator,
                decoration: inputDecoration(
                  icon: Icons.location_on,
                  label: 'Address',
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: phoneValidator,
                decoration: inputDecoration(
                  icon: Icons.phone,
                  label: 'Phone number',
                  prefixText: '+91 ',
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                validator: defaultValidator,
                decoration: inputDecoration(
                  icon: Icons.badge,
                  label: 'Account number',
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _macController,
                validator: defaultValidator,
                decoration: inputDecoration(
                  icon: Icons.router,
                  label: 'MAC Id',
                ),
              ),
              const SizedBox(height: 10),
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
                      ...areas.map(
                        (area) {
                          return Row(
                            children: <Widget>[
                              Radio<String>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                activeColor: Theme.of(context).primaryColor,
                                value: area.id,
                                groupValue: _selectedAreaId,
                                onChanged: _selectAreaField,
                              ),
                              Text(area.areaName),
                            ],
                          );
                        },
                      ),
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
                      ...?op?.plans.map(
                        (plan) {
                          return Row(
                            children: <Widget>[
                              Radio<double>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                activeColor: Theme.of(context).primaryColor,
                                value: plan,
                                groupValue: _selectedPlan,
                                onChanged: _selectPlanField,
                              ),
                              Text('\u20B9 $plan'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              defaultbutton(
                context: context,
                function: saveDetails,
                title: 'Add customer',
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider(endIndent: 5)),
                  Text('OR', style: TextStyle(fontSize: 16)),
                  Expanded(child: Divider(indent: 5)),
                ],
              ),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Add customers from file (Bulk upload)!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              defaultbutton(
                context: context,
                function: () async =>
                    PickFile.pickFileAndAddCustomers(context),
                title: 'Pick file',
              ),
              const SizedBox(height: 20),
            ],
          ),
          Positioned(
            top: 0,
            left: 50,
            right: 50,
            child: Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: Theme.of(context).primaryColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(5, 5),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Text(
                'ADD NEW CUSTOMER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
