import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';
import 'package:cableTvBook/widgets/app_logo.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signupScreen';

  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reterPasswordController = TextEditingController();
  bool _accepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late TapGestureRecognizer _privacyPolicy;
  late TapGestureRecognizer _termsAndConditions;

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
    _emailController.dispose();
    _passwordController.dispose();
    _reterPasswordController.dispose();
    _privacyPolicy.dispose();
    _termsAndConditions.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true && _accepted) {
      _formKey.currentState?.save();
      Navigator.of(context).pushNamed(
        RegisterScreen.routeName,
        arguments: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text
        },
      );
    } else if (!_accepted) {
      Fluttertoast.showToast(
        msg: 'Please agree to Privacy Policy and Terms to proceed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
            maxWidth: 460,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16),

                    // Brand Logo & Heading
                    Center(
                      child: Column(
                        children: [
                          const AppLogo(size: 72, borderRadius: 18),
                          const SizedBox(height: 16),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Step 1 of 2: Operator Credentials',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Signup Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.cardBorder, width: 1),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          TextFormField(
                            validator: emailValidator,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'operator@example.com',
                              prefixIcon:
                                  Icon(Icons.email_outlined, size: 20),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Password
                          TextFormField(
                            validator: (value) =>
                                passwordValidator(value, false),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Min 8 chars with 1 Cap, 1 Small, 1 Num & 1 Spl',
                              prefixIcon: const Icon(Icons.lock_outline_rounded,
                                  size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Re-enter Password
                          TextFormField(
                            controller: _reterPasswordController,
                            validator: (value) => reCheckValidator(
                                value, _passwordController.text),
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded,
                                  size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Terms agreement checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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

                          const SizedBox(height: 20),

                          // Next Button
                          FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: AppColors.primary,
                            ),
                            onPressed: _submit,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue to Profile',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Already have account? Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Already registered? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed(SigninScreen.routeName),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
