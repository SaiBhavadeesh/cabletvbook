import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

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
                    Align(
                      child: FloatingActionButton.extended(
                        heroTag: 'register',
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            Navigator.of(context)
                                .pushNamed(RegisterScreen.routeName);
                          }
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
