import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';

  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImageFile;

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  void _showEditDialog({
    required String title,
    required String initialValue,
    required FormFieldValidator<String> validator,
    required String fieldKey,
  }) {
    final formKey = GlobalKey<FormState>();
    String value = initialValue;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: initialValue,
            validator: validator,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter new value',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSaved: (val) {
              if (val != null) value = val.trim();
            },
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
                await DatabaseService.updateData(context,
                    data: {fieldKey: value});
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddPlanDialog() {
    final formKey = GlobalKey<FormState>();
    final planController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text('Add Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a monthly subscription plan amount (max 16 plans).',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: planController,
                validator: planValidator,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  prefixText: '\u20B9 ',
                  hintText: 'e.g. 350',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() == true) {
                formKey.currentState?.save();
                final list = List<double>.from(operatorDetails?.plans ?? [])
                  ..add(double.parse(planController.text.trim()));
                await DatabaseService.updateData(
                  context,
                  data: {'plans': list},
                );
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (mounted) setState(() {});
              }
            },
            child: const Text('Add Plan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (op == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Profile not loaded')),
      );
    }

    ImageProvider avatarImage;
    if (_selectedImageFile != null) {
      avatarImage = FileImage(_selectedImageFile!);
    } else {
      avatarImage = getAvatarImageProvider(op.profileImageLink);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Profile Photo Card
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.transparent,
                        backgroundImage: avatarImage,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              final file =
                                  await ImageGetter.getImageFromDevice(context);
                              if (file != null) {
                                _selectedImageFile = file;
                                await DatabaseService.uploadProfilePicture(
                                  context,
                                  file: file,
                                );
                                if (mounted) setState(() {});
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.camera_alt_rounded,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Business Info Card
              _buildSectionCard(
                title: 'Business & Network Identity',
                icon: Icons.business_rounded,
                children: [
                  _buildDetailRow(
                    label: 'Operator / Owner Name',
                    value: op.name,
                    onEdit: () => _showEditDialog(
                      title: 'Edit Owner Name',
                      initialValue: op.name,
                      validator: nameValidator,
                      fieldKey: 'name',
                    ),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Cable Network Name',
                    value: op.networkName,
                    onEdit: () => _showEditDialog(
                      title: 'Edit Network Name',
                      initialValue: op.networkName,
                      validator: (v) => nameValidator(v, maxLength: 40),
                      fieldKey: 'nn',
                    ),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Registered Phone',
                    value: op.phoneNumber,
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    label: 'Account Email',
                    value: op.email,
                  ),
                ],
              ),

              // Coverage Areas
              _buildSectionCard(
                title: 'Coverage Areas (${areas.length})',
                icon: Icons.location_on_rounded,
                children: [
                  if (areas.isEmpty)
                    const Text(
                      'No coverage areas added yet.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: areas.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                a.areaName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),

              // Subscription Plans
              _buildSectionCard(
                title: 'Subscription Plans',
                icon: Icons.receipt_long_rounded,
                trailing: op.plans.length < 16
                    ? TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _showAddPlanDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Plan'),
                      )
                    : null,
                children: [
                  if (op.plans.isEmpty)
                    const Text(
                      'No subscription plans created yet. Tap "Add Plan" above to create plans for your subscribers.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: op.plans.map((plan) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            '\u20B9 $plan / mo',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
