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
    return showDialog(
      context: context,
      builder: (ctx) => _ChangeValueDialog(
        title: title,
        validator: validator,
        icon: icon,
        textInputType: textInputType,
        prefix: prefix,
        onSaved: onSaved,
      ),
    );
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

            _buildSectionHeader('Account Actions'),
            Card(
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.pause_circle_outline_rounded,
                    iconColor: AppColors.warningDark,
                    title: 'Deactivate Account',
                    subtitle: 'Temporarily pause your operator account and services',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          title: const Text('Deactivate Account?'),
                          content: const Text(
                            'Your business profile and active services will be paused and you will be signed out. You can log back in at any time to reactivate.',
                            style: TextStyle(fontSize: 14),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.warningDark),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Authentication.deactivateOperatorAccount(context);
                              },
                              child: const Text('Deactivate'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.delete_forever_rounded,
                    iconColor: AppColors.error,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your account and subscriber data',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          title: const Text(
                            'Delete Account Permanently?',
                            style: TextStyle(color: AppColors.error),
                          ),
                          content: const Text(
                            'Warning: This action is permanent and cannot be undone. All your areas, subscribers, and transaction ledgers will be permanently deleted.',
                            style: TextStyle(fontSize: 14),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Authentication.deleteOperatorAccount(context);
                              },
                              child: const Text('Delete Permanently'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

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

class _ChangeValueDialog extends StatefulWidget {
  final String title;
  final FormFieldValidator<String> validator;
  final IconData icon;
  final TextInputType? textInputType;
  final String? prefix;
  final Future<void> Function(String value) onSaved;

  const _ChangeValueDialog({
    required this.title,
    required this.validator,
    required this.icon,
    this.textInputType,
    this.prefix,
    required this.onSaved,
  });

  @override
  State<_ChangeValueDialog> createState() => _ChangeValueDialogState();
}

class _ChangeValueDialogState extends State<_ChangeValueDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextFormField(
          controller: _controller,
          validator: widget.validator,
          keyboardType: widget.textInputType,
          autofocus: true,
          obscureText: widget.icon == Icons.vpn_key,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, size: 20),
            prefixText: widget.prefix,
            hintText: widget.icon == Icons.vpn_key
                ? 'Min 8 chars (1 cap, 1 small, 1 num, 1 spl)'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_formKey.currentState?.validate() == true) {
                      _formKey.currentState?.save();
                      setState(() => _isLoading = true);
                      try {
                        await widget.onSaved(_controller.text.trim());
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    }
                  },
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
