import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cableTvBook/widgets/app_svg_icon.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:cableTvBook/theme/app_colors.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final int index;
  final VoidCallback? onCustomerDeleted;

  const CustomerTile({
    super.key,
    required this.customer,
    required this.index,
    this.onCustomerDeleted,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).pushNamed(
      CustomerDetailScreen.routeName,
      arguments: customer,
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
        content: Text('$label copied to clipboard'),
      ),
    );
  }

  void _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri);
      } catch (_) {}
    } else {
      Fluttertoast.showToast(msg: 'Could not launch dialer');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customer.name}? All subscription and recharge history for this account will be removed.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final area = areas.firstWhere(
                  (element) => element.id == customer.areaId,
                );
                await DatabaseService.deleteCustomer(
                  context,
                  areaId: area.id,
                  customerId: customer.id,
                  isActive: customer.currentStatus == 'Active',
                  totalCount: area.totalAccounts,
                  otherCount: customer.currentStatus == 'Active'
                      ? area.activeAccounts
                      : area.inActiveAccounts,
                );
                onCustomerDeleted?.call();
              } catch (_) {}
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = customer.currentStatus == 'Active';
    final hasPending = customer.noOfPendingBills > 0;

    return Container(
      key: ValueKey(customer.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Avatar with status ring
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        getAvatarImageProvider(customer.profileImageUrl),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Customer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Name & Status Pill
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.5,
                              letterSpacing: -0.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
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
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Phone row with tap to call, plan amount & due badges
                    if (customer.phoneNumber.isNotEmpty)
                      Row(
                        children: [
                          const AppSvgIcon(
                            AppSvgIconType.call,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customer.phoneNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (customer.currentPlan > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '\u20B9${customer.currentPlan.toInt()}/mo',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          if (hasPending)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${customer.noOfPendingBills} due',
                                style: const TextStyle(
                                  color: AppColors.warningDark,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),

                    const SizedBox(height: 7),

                    // Identifiers row (Account & MAC ID)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard(
                            context,
                            customer.accountNumber,
                            'Account #',
                          ),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Acc: ',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  customer.accountNumber,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const AppSvgIcon(
                                  AppSvgIconType.copy,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (customer.macId.isNotEmpty)
                          InkWell(
                            onTap: () => _copyToClipboard(
                              context,
                              customer.macId,
                              'MAC ID',
                            ),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'MAC: ',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    customer.macId,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const AppSvgIcon(
                                    AppSvgIconType.copy,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const AppSvgIcon(
                      AppSvgIconType.call,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    tooltip: 'Call Subscriber',
                    onPressed: () => _makePhoneCall(customer.phoneNumber),
                  ),
                  PopupMenuButton<String>(
                    icon: const AppSvgIcon(
                      AppSvgIconType.moreVertical,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (val) async {
                      if (val == 'details') {
                        _navigateToDetail(context);
                      } else if (val == 'deactivate') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            title: const Text('Deactivate Customer?'),
                            content: Text(
                              'Are you sure you want to deactivate ${customer.name}? Account status will be set to Inactive.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.warningDark),
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
                      } else if (val == 'activate') {
                        _navigateToDetail(context);
                      } else if (val == 'delete') {
                        _confirmDelete(context);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      if (isActive)
                        const PopupMenuItem(
                          value: 'deactivate',
                          child: Row(
                            children: [
                              Icon(Icons.pause_circle_outline_rounded,
                                  size: 18, color: AppColors.warningDark),
                              SizedBox(width: 8),
                              Text('Deactivate Account'),
                            ],
                          ),
                        )
                      else
                        const PopupMenuItem(
                          value: 'activate',
                          child: Row(
                            children: [
                              Icon(Icons.bolt_rounded,
                                  size: 18, color: AppColors.success),
                              SizedBox(width: 8),
                              Text('Activate / Renew'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete Account',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
