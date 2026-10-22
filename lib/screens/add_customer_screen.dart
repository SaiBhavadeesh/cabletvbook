import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cableTvBook/helpers/upload_customers_from_file.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

class AddCustomerScreen extends StatefulWidget {
  static const routeName = '/addCustomerScreen';

  const AddCustomerScreen({super.key});

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  final _macController = TextEditingController();
  String? _selectedAreaId;
  double? _selectedPlan;
  File? _selectedImageFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    _macController.dispose();
    super.dispose();
  }

  void saveDetails() async {
    final op = operatorDetails;
    if (_formKey.currentState?.validate() == true &&
        _selectedAreaId != null &&
        _selectedPlan != null &&
        op != null) {
      _formKey.currentState?.save();
      setState(() => _isSaving = true);
      try {
        final newCustomer = Customer(
          id: '',
          name: _nameController.text.trim(),
          phoneNumber: '+ 91 ${_phoneController.text.trim()}',
          address: _addressController.text.trim(),
          accountNumber: _accountController.text.trim(),
          macId: _macController.text.trim(),
          networkProviderId: op.id,
          areaId: _selectedAreaId!,
          expiryMonth: 0,
          currentPlan: _selectedPlan!,
          runningYear: DateTime.now().year,
          currentStatus: 'Inactive',
        );
        await DatabaseService.addNewCustomer(
          context,
          customer: newCustomer,
          file: _selectedImageFile,
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else if (_selectedPlan == null || _selectedAreaId == null) {
      String msg;
      if (_selectedAreaId == null && _selectedPlan == null) {
        msg = 'both Area and Plan';
      } else if (_selectedAreaId == null) {
        msg = 'an Area';
      } else {
        msg = 'a Subscription Plan';
      }
      DefaultDialogBox.errorDialog(
        context,
        title: 'Missing Selection',
        content: 'Please select $msg to continue.',
      );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (areas.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.warningLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    size: 48,
                    color: AppColors.warningDark,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Areas Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please create an Area on the Areas dashboard before registering subscribers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final availablePlans = op?.plans ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveContainer(
        maxWidth: 800,
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: <Widget>[
              // Avatar Picker Card
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        backgroundImage: _selectedImageFile != null
                            ? FileImage(_selectedImageFile!)
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider,
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
                                setState(() {
                                  _selectedImageFile = file;
                                });
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Section 1: Subscriber Identity
              _buildSectionCard(
                title: 'Subscriber Information',
                icon: Icons.person_outline_rounded,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: nameValidator,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. Ramesh Kumar',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: phoneValidator,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixText: '+91 ',
                      hintText: '9876543210',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    validator: addressValidator,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Installation Address',
                      hintText: 'House/Flat #, Street, Landmark',
                      prefixIcon: Icon(Icons.home_outlined, size: 20),
                    ),
                  ),
                ],
              ),

              // Section 2: Technical Identifiers
              _buildSectionCard(
                title: 'Hardware & Account Identifiers',
                icon: Icons.router_outlined,
                children: [
                  TextFormField(
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    validator: defaultValidator,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      hintText: 'e.g. 10042',
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _macController,
                    validator: defaultValidator,
                    decoration: const InputDecoration(
                      labelText: 'MAC ID / Set-top Box #',
                      hintText: 'e.g. AA:BB:CC:DD:EE:FF',
                      prefixIcon: Icon(Icons.fingerprint_rounded, size: 20),
                    ),
                  ),
                ],
              ),

              // Section 3: Subscription Assignment
              _buildSectionCard(
                title: 'Coverage Area & Plan',
                icon: Icons.tune_rounded,
                children: [
                  const Text(
                    'Select Area',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAreaId,
                    hint: const Text('Choose coverage area...'),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary, size: 22),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 4,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items: areas.map((area) {
                      return DropdownMenuItem<String>(
                        value: area.id,
                        child: Text(area.areaName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedAreaId = val);
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Monthly Plan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (availablePlans.isEmpty)
                    const Text(
                      'No plans configured in Settings. Please add plans in operator settings.',
                      style: TextStyle(color: AppColors.warningDark, fontSize: 13),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availablePlans.map((plan) {
                        final isSelected = _selectedPlan == plan;
                        return ChoiceChip(
                          label: Text(
                            '\u20B9 $plan/mo',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPlan = selected ? plan : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),

              // Submit Button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _isSaving ? null : saveDetails,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_rounded),
                label: Text(
                  _isSaving ? 'Registering...' : 'Register Customer',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Divider with OR
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // Bulk Import Option
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async =>
                    PickFile.pickFileAndAddCustomers(context),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Bulk Upload Subscribers (Excel / CSV)'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
