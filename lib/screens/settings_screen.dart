import 'package:flutter/material.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/widgets/verify_phone_popup.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settingsScreen';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<dynamic> _showChangeDialog({
    required String title,
    required FormFieldValidator<String> validator,
    required IconData icon,
    TextInputType? textInputType,
    String? prefix,
    required Future<void> Function(String value) onSaved,
  }) {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
              onPressed: () async {
                if (formKey.currentState?.validate() == true) {
                  formKey.currentState?.save();
                  await onSaved(textController.text.trim());
                }
              },
              child: const Text(
                'save',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      textController.dispose();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Container(
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
    );
  }

  Widget _buildActionItem(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: onTap,
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
    final hasPasswordAuth = user?.providerData
            .any((element) => element.providerId == 'password') ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
      ),
      body: ListView(
        children: <Widget>[
          _buildSectionHeader('Account Settings'),
          if (user != null && !user.emailVerified)
            _buildActionItem(
              'Verify your email',
              onTap: () async =>
                  await Authentication.sendEmailVerificationMail(context),
            ),
          if (hasPasswordAuth)
            _buildActionItem(
              'Change Email',
              onTap: () => _showChangeDialog(
                title: 'Change Email !',
                validator: emailValidator,
                icon: Icons.email,
                textInputType: TextInputType.emailAddress,
                onSaved: (value) async {
                  await Authentication.changeEmailAddress(context,
                      email: value);
                },
              ),
            ),
          _buildActionItem(
            'Change Phone number',
            onTap: () => _showChangeDialog(
              title: 'Change Phone number !',
              validator: phoneValidator,
              icon: Icons.phone,
              textInputType: TextInputType.phone,
              prefix: '+91 ',
              onSaved: (value) async {
                final formattedPhone = '+91$value';
                await Authentication.changePhoneNumber(
                  context,
                  phoneNumber: formattedPhone,
                );
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => VerifyPhonePopup(
                        isUpdate: true,
                        phoneNumber: formattedPhone,
                      ),
                      opaque: false,
                    ),
                  );
                }
              },
            ),
          ),
          if (hasPasswordAuth) ...[
            _buildSectionHeader('Privacy Settings'),
            _buildActionItem(
              'Change Password',
              onTap: () => _showChangeDialog(
                title: 'Change password !',
                validator: (value) => passwordValidator(value, false),
                icon: Icons.vpn_key,
                onSaved: (value) async {
                  await Authentication.changePassword(context, password: value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
