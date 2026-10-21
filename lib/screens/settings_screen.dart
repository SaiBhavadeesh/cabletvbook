import 'package:flutter/material.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/widgets/verify_phone_popup.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settingsScreen';

  const SettingsScreen({super.key});

  Future<dynamic> getChangeDialog(
    BuildContext context, {
    required String title,
    required FormFieldValidator<String> validator,
    required IconData icon,
    TextInputType? textInputType,
    String? prefix,
    required VoidCallback onSaved,
    required TextEditingController textController,
    required GlobalKey<FormState> formKey,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => Form(
        key: formKey,
        child: AlertDialog(
          title: Text(title),
          content: TextFormField(
            controller: textController,
            validator: validator,
            keyboardType: textInputType,
            decoration: inputDecoration(icon: icon, prefixText: prefix),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(ctx).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: onSaved,
              child: const Text(
                'save',
                style: TextStyle(fontSize: 18),
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
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget getdetailText(BuildContext context, String text,
      {VoidCallback? function}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: function,
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(color: Colors.transparent),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = firebaseUser;
    final op = operatorDetails;
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getTitle(context, 'Account Settings'),
          if (user != null && !user.emailVerified)
            getdetailText(
              context,
              'Verify your email',
              function: () async =>
                  await Authentication.sendEmailVerificationMail(context),
            ),
          if (op?.password != null)
            getdetailText(
              context,
              'Change Email',
              function: () => getChangeDialog(
                context,
                title: 'Change Email !',
                validator: emailValidator,
                icon: Icons.email,
                textInputType: TextInputType.emailAddress,
                textController: textController,
                formKey: formKey,
                onSaved: () async {
                  if (formKey.currentState?.validate() == true) {
                    formKey.currentState?.save();
                    await Authentication.changeEmailAddress(context,
                        email: textController.text.trim());
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
              textController: textController,
              formKey: formKey,
              onSaved: () {
                if (formKey.currentState?.validate() == true) {
                  formKey.currentState?.save();
                  Authentication.changePhoneNumber(context,
                      phoneNumber: '+ 91 ${textController.text.trim()}');
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => VerifyPhonePopup(
                        isUpdate: true,
                        phoneNumber: '+ 91 ${textController.text.trim()}',
                      ),
                      opaque: false,
                    ),
                  );
                }
              },
            ),
          ),
          if (op?.password != null)
            getTitle(context, 'Privacy Settings'),
          if (op?.password != null)
            getdetailText(
              context,
              'Change Password',
              function: () => getChangeDialog(
                context,
                title: 'Change password !',
                validator: (value) => passwordValidator(value, false),
                icon: Icons.vpn_key,
                textController: textController,
                formKey: formKey,
                onSaved: () async {
                  if (formKey.currentState?.validate() == true) {
                    formKey.currentState?.save();
                    await Authentication.changePassword(context,
                        password: textController.text);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
