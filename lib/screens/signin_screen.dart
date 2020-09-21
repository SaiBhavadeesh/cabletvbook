import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/screens/signup_screen.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/services/authentication.dart';

class SigninScreen extends StatefulWidget {
  static const routeName = 'loginRegisterScreen';
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
              width: size.width,
              height: size.height,
              decoration: pageDecoration(context),
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: <Widget>[
                    SizedBox(height: top * 1.5),
                    getTextWidget('Sign In', 28, Colors.white, true),
                    Divider(
                        thickness: 2,
                        color: Colors.black,
                        indent: 0,
                        endIndent: size.width * 0.625),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: getTextWidget(
                          'Forgot password?', 14, Colors.black, false),
                    ),
                    SizedBox(height: top),
                    Align(
                      child: FloatingActionButton.extended(
                        heroTag: 'login',
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            Authentication.signinWithEmailAndPassword(context,
                                email: _emailController.text.trim(),
                                password: _passwordController.text);
                          }
                        },
                        label: getTextWidget('${'\t' * 7}Sign In${'\t' * 7}',
                            20, Theme.of(context).primaryColor, true),
                      ),
                    ),
                    SizedBox(height: top),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Divider(color: Colors.white, indent: 32)),
                        getTextWidget('OR', 16, Colors.white, true),
                        Expanded(
                            child: Divider(color: Colors.white, endIndent: 32)),
                      ],
                    ),
                    SizedBox(height: top * 0.5),
                    Align(
                        child: getTextWidget(
                            'Sign In with', 18, Colors.white, true)),
                    SizedBox(height: top * 0.5),
                    Align(
                      child: FloatingActionButton.extended(
                          heroTag: 'google',
                          onPressed: () =>
                              Authentication.signinWithGoogle(context),
                          icon: SizedBox(
                              height: 25,
                              child: Image.asset('assets/images/google.png')),
                          label: getTextWidget('${'\t' * 4}GOOGLE${'\t' * 10}',
                              16, Colors.blue, true)),
                    ),
                    SizedBox(height: top * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        getTextWidget('Don\'t have an account?\t', 18,
                            Colors.black, false),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed(SignupScreen.routeName),
                          child: getTextWidget('Register', 18,
                              Theme.of(context).errorColor, true),
                        ),
                      ],
                    ),
                    SizedBox(height: top*2),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600),
                              recognizer: _privacyPolicy,
                            ),
                            TextSpan(text: '  and  '),
                            TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600),
                                recognizer: _termsAndConditions),
                          ], style: TextStyle(color: Colors.black)),
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(height: top),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
