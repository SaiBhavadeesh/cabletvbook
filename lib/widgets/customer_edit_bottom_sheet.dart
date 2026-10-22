import 'package:flutter/material.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/theme/app_colors.dart';

class CustomerEditBottomSheet extends StatefulWidget {
  final Customer customer;
  const CustomerEditBottomSheet({super.key, required this.customer});

  @override
  _CustomerEditBottomSheetState createState() =>
      _CustomerEditBottomSheetState();
}

class _CustomerEditBottomSheetState extends State<CustomerEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _address;
  late String _phone;
  late String _account;
  late String _mac;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = widget.customer.name;
    _address = widget.customer.address;
    _phone = widget.customer.phoneNumber.length >= 5
        ? widget.customer.phoneNumber.substring(5).trim()
        : widget.customer.phoneNumber;
    _account = widget.customer.accountNumber;
    _mac = widget.customer.macId;
  }

  void _save() async {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();
      setState(() => _isSaving = true);
      try {
        Map<String, dynamic> data = {};
        if (widget.customer.name != _name) {
          data['name'] = _name;
        }
        if (widget.customer.address != _address) {
          data['adrs'] = _address;
        }
        if (widget.customer.phoneNumber != '+ 91 $_phone') {
          data['pn'] = '+ 91 $_phone';
        }
        if (widget.customer.accountNumber != _account) {
          data['accNo'] = _account;
        }
        if (widget.customer.macId != _mac) {
          data['macId'] = _mac;
        }
        await DatabaseService.updateCustomerData(
          context,
          data: data,
          customerId: widget.customer.id,
        );
        if (mounted) Navigator.of(context).pop();
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: const SizedBox.expand(),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.85,
                maxWidth: 600,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Subscriber Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: widget.customer.name,
                              validator: nameValidator,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline, size: 20),
                              ),
                              onSaved: (newValue) =>
                                  _name = newValue?.trim() ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _phone,
                              keyboardType: TextInputType.phone,
                              validator: phoneValidator,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixText: '+91 ',
                                prefixIcon: Icon(Icons.phone_outlined, size: 20),
                              ),
                              onSaved: (newValue) =>
                                  _phone = newValue?.trim() ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: widget.customer.address,
                              keyboardType: TextInputType.streetAddress,
                              validator: addressValidator,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                prefixIcon: Icon(Icons.home_outlined, size: 20),
                              ),
                              onSaved: (newValue) =>
                                  _address = newValue?.trim() ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: widget.customer.accountNumber,
                              keyboardType: TextInputType.number,
                              validator: defaultValidator,
                              decoration: const InputDecoration(
                                labelText: 'Account Number',
                                prefixIcon: Icon(Icons.badge_outlined, size: 20),
                              ),
                              onSaved: (newValue) =>
                                  _account = newValue?.trim() ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: widget.customer.macId,
                              validator: defaultValidator,
                              decoration: const InputDecoration(
                                labelText: 'MAC ID',
                                prefixIcon:
                                    Icon(Icons.router_outlined, size: 20),
                              ),
                              onSaved: (newValue) =>
                                  _mac = newValue?.trim() ?? '',
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: AppColors.primary,
                              ),
                              onPressed: _isSaving ? null : _save,
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
