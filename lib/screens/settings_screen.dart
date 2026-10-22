import 'package:flutter/material.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/services/authentication.dart';
import 'package:cableTvBook/widgets/verify_phone_popup.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: textController,
            validator: validator,
            keyboardType: textInputType,
            autofocus: true,
            obscureText: icon == Icons.vpn_key,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              prefixText: prefix,
              hintText: icon == Icons.vpn_key
                  ? 'Min 8 chars (1 cap, 1 small, 1 num, 1 spl)'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState?.validate() == true) {
                  formKey.currentState?.save();
                  await onSaved(textController.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ).then((_) {
      textController.dispose();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = firebaseUser;
    final hasPasswordAuth = user?.providerData
            .any((element) => element.providerId == 'password') ??
        false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: <Widget>[
            _buildSectionHeader('Account & Security'),
            Card(
              child: Column(
                children: [
                  if (user != null && !user.emailVerified) ...[
                    _buildSettingsTile(
                      icon: Icons.mark_email_unread_rounded,
                      iconColor: AppColors.warningDark,
                      title: 'Verify Email Address',
                      subtitle: 'Tap to send verification link',
                      onTap: () async =>
                          await Authentication.sendEmailVerificationMail(context),
                    ),
                    const Divider(height: 1),
                  ],
                  if (hasPasswordAuth) ...[
                    _buildSettingsTile(
                      icon: Icons.alternate_email_rounded,
                      title: 'Change Email',
                      subtitle: user?.email,
                      onTap: () => _showChangeDialog(
                        title: 'Change Email Address',
                        validator: emailValidator,
                        icon: Icons.email,
                        textInputType: TextInputType.emailAddress,
                        onSaved: (value) async {
                          await Authentication.changeEmailAddress(context,
                              email: value);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  _buildSettingsTile(
                    icon: Icons.phone_android_rounded,
                    title: 'Update Phone Number',
                    subtitle: operatorDetails?.phoneNumber,
                    onTap: () => _showChangeDialog(
                      title: 'Update Phone Number',
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
                ],
              ),
            ),

            if (hasPasswordAuth) ...[
              _buildSectionHeader('Privacy & Credentials'),
              Card(
                child: _buildSettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Account Password',
                  subtitle: 'Update your login password',
                  onTap: () => _showChangeDialog(
                    title: 'Change Password',
                    validator: (value) => passwordValidator(value, false),
                    icon: Icons.vpn_key,
                    onSaved: (value) async {
                      await Authentication.changePassword(context,
                          password: value);
                    },
                  ),
                ),
              ),
            ],

            _buildSectionHeader('About'),
            Card(
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: '1.0.0+1',
                    trailing: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
