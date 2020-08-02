import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:validators/validators.dart' as validator;

class LoginRegisterScreen extends StatefulWidget {
  static const routeName = 'loginRegisterScreen';
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLogin = true;

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

  InputDecoration defaultInputDecoration(
      {@required IconData icon,
      String hint,
      // ignore: avoid_init_to_null
      String prefixText = null}) {
    return InputDecoration(
      fillColor: Theme.of(context).primaryColor.withRed(100),
      filled: true,
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: Icon(icon, color: Colors.white),
      contentPadding: const EdgeInsets.all(8),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
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
            child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: size.width,
              height: size.height,
              decoration: pageDecoration(context),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: top * 2),
                        Align(
                            child: AnimatedCrossFade(
                          duration: Duration(milliseconds: 500),
                          crossFadeState: _isLogin
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild:
                              getTextWidget('Sign In', 28, Colors.white, true),
                          secondChild:
                              getTextWidget('Register', 28, Colors.white, true),
                        )),
                        SizedBox(height: top),
                        getTextWidget('E-Mail', 16, Colors.white, false),
                        SizedBox(height: top * 0.25),
                        TextFormField(
                          validator: (value) {
                            if (validator.isEmail(value)) return null;
                            return 'please enter valid email !';
                          },
                          controller: _emailController,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.emailAddress,
                          decoration: defaultInputDecoration(
                              icon: Icons.email, hint: 'example@gmail.com'),
                        ),
                        SizedBox(height: top * 0.5),
                        getTextWidget('Password', 16, Colors.white, false),
                        SizedBox(height: top * 0.25),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          cursorColor: Colors.black,
                          decoration: defaultInputDecoration(
                              icon: FlutterIcons.key_mco, hint: 'password'),
                        ),
                        AnimatedCrossFade(
                          duration: Duration(milliseconds: 500),
                          crossFadeState: _isLogin
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Column(
                            children: <Widget>[
                              SizedBox(height: top * 0.5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: getTextWidget('Forgot password?', 14,
                                    Colors.black, false),
                              ),
                              SizedBox(height: top),
                              FloatingActionButton.extended(
                                onPressed: () {},
                                label: getTextWidget(
                                    '${'\t' * 8}Log In${'\t' * 8}',
                                    20,
                                    Theme.of(context).primaryColor,
                                    true),
                              ),
                              SizedBox(height: top),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Divider(
                                          color: Colors.white, indent: 32)),
                                  getTextWidget('OR', 16, Colors.white, true),
                                  Expanded(
                                      child: Divider(
                                          color: Colors.white, endIndent: 32)),
                                ],
                              ),
                              SizedBox(height: top * 0.5),
                              getTextWidget(
                                  'Sign In with', 18, Colors.white, true),
                              SizedBox(height: top * 0.5),
                              FloatingActionButton.extended(
                                  onPressed: () {},
                                  icon: SizedBox(
                                      height: 25,
                                      child: Image.asset(
                                          'assets/images/google.png')),
                                  label: getTextWidget(
                                      '${'\t' * 4}GOOGLE${'\t' * 10}',
                                      16,
                                      Colors.blue,
                                      true)),
                              SizedBox(height: top * 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  getTextWidget('Don\'t have an account?\t', 18,
                                      Colors.black, false),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: getTextWidget(
                                        'Register', 18, Colors.red, true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: top * 0.5),
                              getTextWidget(
                                  'Re-enter password', 16, Colors.white, false),
                              SizedBox(height: top * 0.25),
                              TextFormField(
                                obscureText: true,
                                cursorColor: Colors.black,
                                decoration: defaultInputDecoration(
                                    icon: FlutterIcons.key_mco,
                                    hint: 'Re-enter password'),
                              ),
                              SizedBox(height: top * 0.5),
                              getTextWidget(
                                  'Phone number', 16, Colors.white, false),
                              SizedBox(height: top * 0.25),
                              TextFormField(
                                validator: (value) {
                                  if (!validator.isNumeric(value))
                                    return 'please enter valid number!';
                                  if (value.length != 10)
                                    return 'Please enter valid number!';
                                  return null;
                                },
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                cursorColor: Colors.black,
                                decoration: defaultInputDecoration(
                                    icon: Icons.phone, hint: 'phone number',prefixText: '+91 '),
                              ),
                              SizedBox(height: top),
                              Align(
                                child: FloatingActionButton.extended(
                                  onPressed: () {},
                                  label: getTextWidget(
                                      '${'\t' * 8}Register${'\t' * 8}',
                                      20,
                                      Theme.of(context).primaryColor,
                                      true),
                                ),
                              ),
                              SizedBox(height: top * 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  getTextWidget('Already have an account?\t',
                                      18, Colors.black, false),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: getTextWidget(
                                        'Sign In', 18, Colors.red, true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: top),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
