import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/widgets/verify_phone_popup.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settingsScreen';

  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static Size size;

  Future<dynamic> getChangeDialog(BuildContext context,
      {@required String title,
      @required Function validator,
      @required IconData icon,
      TextInputType textInputType,
      String prefix,
      @required Function onSaved}) {
    return showDialog(
      context: context,
      builder: (context) => Form(
        key: _formKey,
        child: AlertDialog(
          title: Text(title),
          content: TextFormField(
            controller: _textController,
            validator: validator,
            keyboardType: textInputType,
            decoration: inputDecoration(icon: icon, prefixText: prefix),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel',
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
            FlatButton(
              color: Theme.of(context).primaryColor,
              onPressed: onSaved,
              child: Text(
                'save',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTitle(BuildContext context, String title) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget getdetailText(BuildContext context, String text, {Function function}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: function,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Divider(color: Colors.transparent),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('General Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getTitle(context, 'Account Settings'),
          if (!firebaseUser.emailVerified)
            getdetailText(context, 'Verify your email',
                function: () async =>
                    await Authentication.sendEmailVerificationMail(context)),
          if (operatorDetails.password != null)
            getdetailText(
              context,
              'Change Email',
              function: () => getChangeDialog(
                context,
                title: 'Change Email !',
                validator: emailValidator,
                icon: Icons.email,
                textInputType: TextInputType.emailAddress,
                onSaved: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    await Authentication.changeEmailAddress(context,
                        email: _textController.text);
                  }
                },
              ),
            ),
          getdetailText(
            context,
            'Change Phone number',
            function: () => getChangeDialog(
              context,
              title: 'Change Phone number !',
              validator: phoneValidator,
              icon: Icons.phone,
              textInputType: TextInputType.phone,
              prefix: '+91 ',
              onSaved: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Authentication.changePhoneNumber(context,
                      phoneNumber: '+ 91 ' + _textController.text);
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => VerifyPhonePopup(
                        isUpdate: true,
                        phoneNumber: '+ 91 ' + _textController.text,
                      ),
                      opaque: false,
                    ),
                  );
                }
              },
            ),
          ),
          if (operatorDetails.password != null)
            getTitle(context, 'Privacy Settings'),
          // getdetailText(context, 'Change Security pin',
          //     function: () => getChangeDialog(context,
          //         title: 'Currently unavailable',
          //         validator: null,
          //         icon: null,
          //         onSaved: null)),
          if (operatorDetails.password != null)
            getdetailText(
              context,
              'Change Password',
              function: () => getChangeDialog(
                context,
                title: 'Change password !',
                validator: (value) => passwordValidator(value, false),
                icon: FlutterIcons.vpn_key_mdi,
                onSaved: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    await Authentication.changePassword(context,
                        password: _textController.text);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
