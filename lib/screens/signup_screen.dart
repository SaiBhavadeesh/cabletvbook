import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signupScreen';
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reterPasswordController = TextEditingController();
  bool _accepted = false;
  TapGestureRecognizer _privacyPolicy;
  TapGestureRecognizer _termsAndConditions;

  Widget getTextWidget(String data, double size, Color color, bool isBold) {
    return Text(
      data,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        letterSpacing: 0.5,
      ),
    );
  }

  void _handlePrivacyPolicy() async {
    final url = "https://sites.google.com/view/srinivasasoftwares-privacy";
    if (await canLaunch(url)) {
      try {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          enableJavaScript: true,
        );
      } catch (_) {}
    } else {
      Fluttertoast.showToast(
          msg: 'Could not process your request, Please try again');
    }
  }

  void _handleTermsAndConditions() async {
    final url = "https://sites.google.com/view/srinivasasoftwares-terms";
    if (await canLaunch(url)) {
      try {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          enableJavaScript: true,
        );
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              height: size.height,
              width: size.width,
              decoration: pageDecoration(context),
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: <Widget>[
                    SizedBox(height: top * 1.5),
                    getTextWidget('Register', 28, Colors.white, true),
                    Divider(
                        thickness: 2,
                        color: Colors.black,
                        indent: 0,
                        endIndent: size.width * 0.575),
                    SizedBox(height: top),
                    getTextWidget('E-Mail', 16, Colors.white, false),
                    SizedBox(height: top * 0.25),
                    TextFormField(
                      validator: emailValidator,
                      controller: _emailController,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                          filled: true,
                          hintColor: Colors.white,
                          filledColor:
                              Theme.of(context).primaryColor.withRed(100),
                          hint: 'email',
                          icon: Icons.email,
                          iconColor: Colors.white),
                    ),
                    SizedBox(height: top * 0.5),
                    getTextWidget('Password', 16, Colors.white, false),
                    SizedBox(height: top * 0.25),
                    TextFormField(
                      validator: (value) => passwordValidator(value, true),
                      controller: _passwordController,
                      obscureText: true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                          filled: true,
                          hintColor: Colors.white,
                          filledColor:
                              Theme.of(context).primaryColor.withRed(100),
                          hint: 'password',
                          icon: FlutterIcons.key_mco,
                          iconColor: Colors.white),
                    ),
                    SizedBox(height: top * 0.5),
                    getTextWidget('Re-enter password', 16, Colors.white, false),
                    SizedBox(height: top * 0.25),
                    TextFormField(
                      controller: _reterPasswordController,
                      validator: (value) => reCheckValidator(
                          value, _reterPasswordController.text),
                      obscureText: true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                          filled: true,
                          hintColor: Colors.white,
                          filledColor:
                              Theme.of(context).primaryColor.withRed(100),
                          hint: 're-enter password',
                          icon: FlutterIcons.key_mco,
                          iconColor: Colors.white),
                    ),
                    SizedBox(height: top * 1.5),
                    FittedBox(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              checkColor: Colors.green[900],
                              value: _accepted,
                              onChanged: (value) {
                                setState(() {
                                  _accepted = !_accepted;
                                });
                              },
                            ),
                            RichText(
                                text: TextSpan(
                                    text: 'Accept ',
                                    children: [
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600),
                                        recognizer: _privacyPolicy,
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600),
                                          recognizer: _termsAndConditions),
                                    ],
                                    style: TextStyle(color: Colors.black)),
                                textAlign: TextAlign.center),
                            SizedBox(width: 10)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: top * 1.5),
                    Align(
                      child: FloatingActionButton.extended(
                        heroTag: 'register',
                        onPressed: () {
                          if (_formKey.currentState.validate() && _accepted) {
                            _formKey.currentState.save();
                            Navigator.of(context).pushNamed(
                                RegisterScreen.routeName,
                                arguments: {
                                  'email': _emailController.text,
                                  'password': _passwordController.text
                                });
                          } else if (!_accepted)
                            Fluttertoast.showToast(
                                msg:
                                    'Please accept privacy policy and terms & conditions');
                        },
                        label: getTextWidget('${'\t' * 8}Register${'\t' * 8}',
                            20, Theme.of(context).primaryColor, true),
                      ),
                    ),
                    SizedBox(height: top * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        getTextWidget('Already have an account?\t', 18,
                            Colors.black, false),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed(SigninScreen.routeName),
                          child: getTextWidget('Sign In', 18,
                              Theme.of(context).errorColor, true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
