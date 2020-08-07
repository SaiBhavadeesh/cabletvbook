import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/widgets/verify_phone_popup.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/registerScreen';
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _planController = TextEditingController();
  final _phoneController = TextEditingController();
  final _networkController = TextEditingController();
  Map<String, dynamic> routeArguments;

  @override
  Widget build(BuildContext context) {
    routeArguments = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup your Network'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(8),
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              decoration: defaultBoxDecoration(context, true),
              child: Text(
                'Add your primary details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextFormField(
              controller: _nameController,
              validator: nameValidator,
              decoration: inputDecoration(
                  label: 'Username', icon: FlutterIcons.ios_person_ion),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _networkController,
              validator: (value) => nameValidator(value, maxLength: 30),
              decoration: inputDecoration(
                  label: 'Network name', icon: Icons.business_center),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              validator: phoneValidator,
              keyboardType: TextInputType.phone,
              decoration: inputDecoration(
                  label: 'Phone number', icon: Icons.phone, prefixText: '+91 '),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: routeArguments['email'],
              enabled: false,
              decoration: inputDecoration(label: 'E-Mail', icon: Icons.email),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              decoration: defaultBoxDecoration(context, true),
              child: Text(
                'Add your default area and plan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextFormField(
              controller: _areaController,
              maxLength: 10,
              validator: (value) => nameValidator(value, maxLength: 10),
              decoration: inputDecoration(
                  label: 'Default area', icon: Icons.add_location),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _planController,
              validator: planValidator,
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
                  label: 'Default plan', icon: FlutterIcons.currency_inr_mco),
            ),
            SizedBox(height: 20),
            defaultbutton(
                context: context,
                function: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    operatorDetails = Operator(
                        id: null,
                        name: _nameController.text,
                        email: routeArguments['email'],
                        password: routeArguments['password'],
                        networkName: _networkController.text,
                        phoneNumber: '+ 91 ' + _phoneController.text,
                        areas: [AreaData(areaName: _areaController.text)],
                        plans: [double.parse(_planController.text)],
                        startDate: null);
                    Authentication.verifyPhoneNumberAndRegister(
                        context: context,
                        phoneNumber: operatorDetails.phoneNumber,
                        email: operatorDetails.email,
                        password: operatorDetails.password);
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, _, __) => VerifyPhonePopup(),
                      opaque: false,
                    ));
                  }
                },
                title: 'Submit'),
          ],
        ),
      ),
    );
  }
}
