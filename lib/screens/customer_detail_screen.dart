import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/widgets/customer_plan_list.dart';
import 'package:cableTvBook/widgets/activate_bottom_sheet.dart';
import 'package:cableTvBook/widgets/customer_edit_bottom_sheet.dart';
import 'package:cableTvBook/theme/app_colors.dart';
import 'package:cableTvBook/theme/responsive.dart';

class CustomerDetailScreen extends StatefulWidget {
  static const routeName = '/customerDetailScreen';

  const CustomerDetailScreen({super.key});

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final moreInfoController = TextEditingController();
  late int _selectedYear;
  bool _isEdit = false;
  bool _init = true;
  File? _pickedImage;
  late Customer customer;
  List<Recharge> rechargeData = [];

  @override
  void dispose() {
    moreInfoController.dispose();
    super.dispose();
  }

  List<int> getAllYears(DateTime date, int runningYear) {
    List<int> years = [];
    final startyear = date.year;
    for (int i = startyear; i <= runningYear; i++) {
      years.add(i);
    }
    return years.isEmpty ? [DateTime.now().year] : years;
  }

  void onMoreInfo() {
    if (_isEdit && customer.tempInfo != null) {
      DatabaseService.updateCustomerData(
        context,
        data: {'tempInfo': null},
        customerId: customer.id,
      );
      moreInfoController.clear();
      customer.tempInfo = null;
    }
    setState(() {
      _isEdit = !_isEdit;
    });
  }

  void modalBottomSheet(BuildContext ctx, Customer data) {
    Navigator.of(ctx).push(PageRouteBuilder(
      pageBuilder: (context, _, __) =>
          CustomerEditBottomSheet(customer: data),
      opaque: false,
    ));
  }

  void _copyToClipboard(BuildContext ctx, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
        content: Text('$label copied to clipboard'),
      ),
    );
  }

  void _callCustomer() async {
    final cleanPhone = customer.phoneNumber.replaceAll(' ', '');
    final uri = Uri.parse("tel:$cleanPhone");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
      } catch (_) {}
    } else {
      Fluttertoast.showToast(msg: 'Could not launch dialer');
    }
  }

  void activateButton(BuildContext ctx) {
    Navigator.of(ctx).push(PageRouteBuilder(
      pageBuilder: (context, _, __) => ActivateBottomSheet(
        customerId: customer.id,
        areaId: customer.areaId,
        status: customer.currentStatus,
        year: customer.runningYear,
        plan: customer.currentPlan,
        unpaidNo: customer.noOfPendingBills,
      ),
      opaque: false,
    ));
  }

  void deactivateButton() async {
    if (customer.currentStatus != 'Active') {
      DefaultDialogBox.errorDialog(
        context,
        title: 'No Active Plan',
        content: 'Customer has no active plan to deactivate.',
      );
    } else {
      final uri = Uri.parse("https://partnerportal.actcorp.in/packages");
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Deactivation'),
          content: Text(
            'Mark ${customer.name}\'s service as deactivated?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await DatabaseService.deactivateCustomer(
                  context,
                  customerId: customer.id,
                  areaId: customer.areaId,
                  year: customer.runningYear.toString(),
                );
              },
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> deleteRecharge(
      BuildContext ctx, Recharge recharge, bool valid) async {
    if (valid &&
        customer.runningYear == _selectedYear &&
        recharge.billPay != null) {
      return showDialog(
        context: ctx,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Delete Recharge Record'),
          content: Text(
            'Are you sure you want to remove recharge record for ${DateFormat('MMMM yyyy').format(recharge.ymRec)}?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                String year = _selectedYear.toString();
                if (_selectedYear != customer.startDate.year) {
                  _selectedYear -= 1;
                }
                Navigator.pop(dialogCtx);
                final value = await DatabaseService.deleteRecharge(
                  context,
                  customerId: customer.id,
                  areaId: customer.areaId,
                  recharge: recharge,
                  unPaidNo: customer.noOfPendingBills,
                );
                if (mounted) {
                  setState(() {
                    if (!value &&
                        int.parse(year) != customer.startDate.year) {
                      _selectedYear = _selectedYear + 1;
                    }
                  });
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } else if (customer.runningYear == _selectedYear || !valid) {
      Fluttertoast.showToast(msg: 'Delete the most recent recharge first');
    }
  }

  Widget _buildProfileHeaderCard() {
    final isActive = customer.currentStatus == 'Active';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with camera tap
              GestureDetector(
                onTap: () async {
                  final picked =
                      await ImageGetter.getImageFromDevice(context);
                  if (picked != null) {
                    _pickedImage = picked;
                    await DatabaseService.updateCustomerPicture(context,
                        file: _pickedImage!, customerId: customer.id);
                    if (mounted) setState(() {});
                  }
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.transparent,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : getAvatarImageProvider(customer.profileImageUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Name, Status & Contacts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.successLight
                                : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            customer.currentStatus,
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.successDark
                                  : AppColors.errorDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _callCustomer,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_rounded,
                              size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            customer.phoneNumber,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            customer.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Metadata Grid (Account #, MAC ID, Start Date, Current Plan)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoBadge(
                label: 'Account #',
                value: customer.accountNumber,
                copyable: true,
              ),
              if (customer.macId.isNotEmpty)
                _buildInfoBadge(
                  label: 'MAC ID',
                  value: customer.macId,
                  copyable: true,
                ),
              _buildInfoBadge(
                label: 'Joined',
                value: DateFormat('dd MMM yyyy').format(customer.startDate),
                copyable: false,
              ),
              _buildInfoBadge(
                label: 'Current Plan',
                value: '\u20B9 ${customer.currentPlan}/mo',
                copyable: false,
                highlight: true,
              ),
            ],
          ),

          // Action Buttons Bar
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => activateButton(context),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Renew / Activate'),
                ),
              ),
              const SizedBox(width: 10),
              if (isActive)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onPressed: deactivateButton,
                  icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                  label: const Text('Deactivate'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required String label,
    required String value,
    required bool copyable,
    bool highlight = false,
  }) {
    return InkWell(
      onTap: copyable ? () => _copyToClipboard(context, value, label) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primaryContainer : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: highlight ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: highlight ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
            if (copyable) ...[
              const SizedBox(width: 4),
              const Icon(Icons.copy_rounded, size: 11, color: AppColors.textMuted),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notes_rounded,
                      size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text(
                    'Operator Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _isEdit ? Icons.close : Icons.edit_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                onPressed: onMoreInfo,
              ),
            ],
          ),
          if (_isEdit) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: moreInfoController,
                    decoration: const InputDecoration(
                      hintText: 'Add note (e.g., box model, payment arrangement)...',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    DatabaseService.updateCustomerData(
                      context,
                      data: {'tempInfo': moreInfoController.text.trim()},
                      customerId: customer.id,
                    );
                    customer.tempInfo = moreInfoController.text.trim();
                    setState(() => _isEdit = false);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                customer.tempInfo?.isNotEmpty == true
                    ? customer.tempInfo!
                    : 'No additional notes added for this subscriber.',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: customer.tempInfo?.isNotEmpty == true
                      ? FontStyle.normal
                      : FontStyle.italic,
                  color: customer.tempInfo?.isNotEmpty == true
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_init) {
      customer = ModalRoute.of(context)!.settings.arguments as Customer;
      _isEdit = customer.tempInfo != null;
      _selectedYear = customer.runningYear;
      _init = false;
    }
    final op = operatorDetails;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users/${op?.id}/customers')
          .doc(customer.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.data() != null) {
          customer = Customer.fromMap(
              snapshot.data!.data() as Map<String, dynamic>);
          final years = getAllYears(customer.startDate, customer.runningYear);
          moreInfoController.text = customer.tempInfo ?? '';

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                customer.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                // Year Filter Pill
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isDense: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 4,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary, size: 20),
                      value: _selectedYear,
                      items: years.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(
                            '$year',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && _selectedYear != value) {
                          setState(() {
                            _selectedYear = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit Subscriber',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => modalBottomSheet(context, customer),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: ResponsiveContainer(
              maxWidth: 900,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildProfileHeaderCard(),
                    _buildNotesCard(),

                    // Ledger Section Header
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedYear Billing History',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (customer.noOfPendingBills > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${customer.noOfPendingBills} pending bills',
                                style: const TextStyle(
                                  color: AppColors.warningDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Table Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: CustomerPlanList(),
                    ),

                    // Monthly Recharge List
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(
                              'users/${op?.id}/customers/${customer.id}/recharges')
                          .snapshots(),
                      builder: (context, rSnapshot) {
                        if (rSnapshot.hasData && rSnapshot.data != null) {
                          rechargeData = getCustomerYearlyRecharge(
                              rSnapshot.data!.docs, _selectedYear);
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 12,
                            itemBuilder: (context, index) {
                              final rec = rechargeData.firstWhere(
                                (element) => element.ymRec.month == index + 1,
                                orElse: () => Recharge(
                                  ymRec: DateTime(_selectedYear, index + 1),
                                  status: false,
                                  addInfo: null,
                                  billPay: null,
                                  date: null,
                                  id: '${index + 1}',
                                  plan: null,
                                ),
                              );
                              return GestureDetector(
                                onLongPress: () => deleteRecharge(
                                  context,
                                  rec,
                                  _selectedYear != customer.startDate.year ||
                                      index > 0,
                                ),
                                child: CustomerPlanList(
                                  customerId: customer.id,
                                  areaId: customer.areaId,
                                  id: rec.id,
                                  billPay: rec.billPay,
                                  year: _selectedYear.toString(),
                                  month: DateFormat('MMMM').format(
                                    DateTime(_selectedYear, rec.ymRec.month),
                                  ),
                                  billDate: rec.billPay == null
                                      ? ''
                                      : DateFormat('dd/MM/yyyy').format(
                                          rec.date ?? DateTime.now()),
                                  billAmount: rec.plan ?? '',
                                  status: rec.status ? 'Active' : 'Inactive',
                                  addInfo: rec.addInfo,
                                  unpaidBill: customer.noOfPendingBills,
                                ),
                              );
                            },
                          );
                        }
                        return Container(
                          alignment: Alignment.center,
                          height: 180,
                          child: FadingText('Loading billing records...'),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Subscriber Details'),
            ),
            body: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }
      },
    );
  }
}
