import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/widgets/verify_phone_popup.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

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
    final uri = Uri.parse(
        "https://sites.google.com/view/srinivasasoftwares-privacy");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    } else {
      Fluttertoast.showToast(msg: 'Could not open privacy policy');
    }
  }

  void _handleTermsAndConditions() async {
    final uri = Uri.parse(
        "https://sites.google.com/view/srinivasasoftwares-terms");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    } else {
      Fluttertoast.showToast(msg: 'Could not open terms & conditions');
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _submit(String email, String? password) {
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
    } else if (!_accepted && isGoogleUser) {
      Fluttertoast.showToast(
        msg: 'Please accept privacy policy and terms to continue',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = routeArguments?['email'] as String? ?? '';
    final password = routeArguments?['password'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Setup Your Network',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              // Section 1: Personal / Profile Details
              _buildSectionCard(
                title: 'Profile Details',
                icon: Icons.person_outline_rounded,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: nameValidator,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Operator / Owner Name',
                      hintText: 'e.g. Ramesh Kumar',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _networkController,
                    validator: (value) => nameValidator(value, maxLength: 30),
                    decoration: const InputDecoration(
                      labelText: 'Cable Network Name',
                      hintText: 'e.g. Sri Venkateswara Cable Vision',
                      prefixIcon: Icon(Icons.business_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    validator: phoneValidator,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Primary Phone Number',
                      hintText: '9876543210',
                      prefixText: '+91 ',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Account Email',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                ],
              ),

              // Section 2: Default Area & Plan
              _buildSectionCard(
                title: 'Default Territory & Plan',
                icon: Icons.tune_rounded,
                children: [
                  TextFormField(
                    controller: _areaController,
                    maxLength: 15,
                    validator: (value) => nameValidator(value, maxLength: 15),
                    decoration: const InputDecoration(
                      labelText: 'First Coverage Area',
                      hintText: 'e.g. Sector 1, Main Bazaar',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _planController,
                    validator: planValidator,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Default Monthly Plan',
                      hintText: '350',
                      prefixText: '\u20B9 ',
                      prefixIcon:
                          Icon(Icons.receipt_long_outlined, size: 20),
                    ),
                  ),
                ],
              ),

              if (isGoogleUser) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _accepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _privacyPolicy,
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _termsAndConditions,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () => _submit(email, password),
                child: const Text(
                  'Complete Registration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
