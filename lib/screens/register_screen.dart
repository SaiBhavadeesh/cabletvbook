import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/widgets/verify_phone_popup.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/registerScreen';

  const RegisterScreen({super.key});

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
  bool _accepted = false;
  late TapGestureRecognizer _privacyPolicy;
  late TapGestureRecognizer _termsAndConditions;
  Map<String, dynamic>? routeArguments;

  void _handlePrivacyPolicy() async {
    final uri = Uri.parse("https://sites.google.com/view/srinivasasoftwares-privacy");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    } else {
      Fluttertoast.showToast(
          msg: 'Could not process your request, Please try again');
    }
  }

  void _handleTermsAndConditions() async {
    final uri = Uri.parse("https://sites.google.com/view/srinivasasoftwares-terms");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    } else {
      Fluttertoast.showToast(
          msg: 'Could not process your request, Please try again');
    }
  }

  @override
  void initState() {
    super.initState();
    _privacyPolicy = TapGestureRecognizer()..onTap = _handlePrivacyPolicy;
    _termsAndConditions = TapGestureRecognizer()
      ..onTap = _handleTermsAndConditions;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _planController.dispose();
    _phoneController.dispose();
    _networkController.dispose();
    _privacyPolicy.dispose();
    _termsAndConditions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = routeArguments?['email'] as String? ?? '';
    final password = routeArguments?['password'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup your Network'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: defaultBoxDecoration(context, true),
              child: const Text(
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
                label: 'Username',
                icon: Icons.person,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _networkController,
              validator: (value) => nameValidator(value, maxLength: 30),
              decoration: inputDecoration(
                label: 'Network name',
                icon: Icons.business_center,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              validator: phoneValidator,
              keyboardType: TextInputType.phone,
              decoration: inputDecoration(
                label: 'Phone number',
                icon: Icons.phone,
                prefixText: '+91 ',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: email,
              enabled: false,
              decoration: inputDecoration(label: 'E-Mail', icon: Icons.email),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: defaultBoxDecoration(context, true),
              child: const Text(
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
                label: 'Default area',
                icon: Icons.add_location,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _planController,
              validator: planValidator,
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
                label: 'Default plan',
                icon: Icons.currency_rupee,
              ),
            ),
            if (isGoogleUser)
              FittedBox(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.green[900],
                        value: _accepted,
                        onChanged: (value) {
                          setState(() {
                            _accepted = value ?? false;
                          });
                        },
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Accept ',
                          children: [
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _privacyPolicy,
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _termsAndConditions,
                            ),
                          ],
                          style: const TextStyle(color: Colors.black),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            defaultbutton(
              context: context,
              function: () {
                if (_formKey.currentState?.validate() == true &&
                    (!isGoogleUser || _accepted)) {
                  _formKey.currentState?.save();
                  operatorDetails = Operator(
                    id: '',
                    name: _nameController.text.trim(),
                    email: email,
                    networkName: _networkController.text.trim(),
                    phoneNumber: '+91${_phoneController.text.trim()}',
                    plans: [double.parse(_planController.text.trim())],
                  );
                  areas = [AreaData(areaName: _areaController.text.trim())];
                  Authentication.verifyPhoneNumberAndRegister(
                    context: context,
                    phoneNumber: operatorDetails!.phoneNumber,
                    email: operatorDetails!.email,
                    password: password,
                  );
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => VerifyPhonePopup(
                        password: password,
                      ),
                      opaque: false,
                    ),
                  );
                } else if (!_accepted) {
                  Fluttertoast.showToast(
                      msg:
                          'Please accept privacy policy and terms & conditions');
                }
              },
              title: 'Submit',
            ),
          ],
        ),
      ),
    );
  }
}
