import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/theme/app_colors.dart';

class ActivateBottomSheet extends StatefulWidget {
  final String customerId;
  final String areaId;
  final int year;
  final String status;
  final double plan;
  final int unpaidNo;

  const ActivateBottomSheet({
    super.key,
    required this.customerId,
    required this.areaId,
    required this.status,
    required this.year,
    required this.plan,
    required this.unpaidNo,
  });

  @override
  _ActivateBottomSheetState createState() => _ActivateBottomSheetState();
}

class _ActivateBottomSheetState extends State<ActivateBottomSheet> {
  late double _selectedPlan;
  bool _billPaid = true;
  bool _launchPortal = false;
  int _selectedTerm = 1;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.plan;
  }

  void _recharge() async {
    final uri = Uri.parse("https://partnerportal.actcorp.in/packages");
    if (_launchPortal) {
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      } else {
        Fluttertoast.showToast(msg: 'Could not open partner portal');
      }
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Activation'),
        content: Text(
          'Activate \u20B9 $_selectedPlan plan for $_selectedTerm month${_selectedTerm > 1 ? 's' : ''} (${_billPaid ? 'Paid' : 'Unpaid'})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService.rechargeCustomer(
                context,
                customerId: widget.customerId,
                areaId: widget.areaId,
                status: widget.status,
                plan: _selectedPlan,
                term: _selectedTerm,
                billPay: _billPaid,
                unPaidNo: widget.unpaidNo,
              );
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opPlans = operatorDetails?.plans ?? [];

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
                maxWidth: 550,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
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
                          'Activate / Renew Plan',
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

                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text(
                          'Select Monthly Plan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: opPlans.map((plan) {
                            final isSelected = _selectedPlan == plan;
                            return ChoiceChip(
                              label: Text(
                                '\u20B9 $plan / mo',
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
                                if (selected) {
                                  setState(() => _selectedPlan = plan);
                                }
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Term Duration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Duration (Months)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(1, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedTerm,
                                  isDense: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 4,
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primary,
                                      size: 20),
                                  items: List.generate(
                                    12,
                                    (index) => DropdownMenuItem(
                                      value: index + 1,
                                      child: Text(
                                        '${index + 1} Month${index == 0 ? '' : 's'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedTerm = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(),

                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: const Text(
                            'Mark as Paid',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Payment collected upfront from subscriber',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _billPaid,
                          onChanged: (val) =>
                              setState(() => _billPaid = val ?? false),
                        ),

                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          title: const Text(
                            'Open ISP / Partner Portal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Launch ACT / Network portal to submit provisioning',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _launchPortal,
                          onChanged: (val) =>
                              setState(() => _launchPortal = val ?? false),
                        ),

                        const SizedBox(height: 20),

                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: AppColors.success,
                          ),
                          onPressed: _recharge,
                          child: Text(
                            'Recharge (\u20B9 ${(_selectedPlan * _selectedTerm).toStringAsFixed(0)})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
