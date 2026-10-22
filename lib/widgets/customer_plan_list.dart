import 'package:flutter/material.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/theme/app_colors.dart';

class CustomerPlanList extends StatelessWidget {
  final String? customerId;
  final String? areaId;
  final String? year;
  final String? id;
  final String month;
  final String billDate;
  final String billAmount;
  final String status;
  final bool? billPay;
  final String? addInfo;
  final int? unpaidBill;
  final VoidCallback? onDeleteRecharge;

  const CustomerPlanList({
    super.key,
    this.customerId,
    this.areaId,
    this.year,
    this.id,
    this.month = 'Month',
    this.billDate = 'Date',
    this.billAmount = 'Amount',
    this.status = 'Status',
    this.billPay,
    this.addInfo,
    this.unpaidBill,
    this.onDeleteRecharge,
  });

  Future<void> changeBillStatus(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Bill Payment'),
        content: Text(
          'Mark bill of \u20B9 $billAmount for $month $year as PAID?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              if (customerId != null && year != null && id != null) {
                await DatabaseService.billPaid(
                  context,
                  customerId: customerId!,
                  year: year!,
                  rechargeId: id!,
                  unpaidBillno: unpaidBill ?? 0,
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Mark Paid'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHeader = month == 'Month';
    final isPaid = billPay ?? false;
    final hasRecharge = billAmount.isNotEmpty && billAmount != '0';

    if (isHeader) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'MONTH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'DATE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'AMOUNT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                'PAYMENT',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPaid
              ? AppColors.cardBorder
              : (hasRecharge ? AppColors.warning.withValues(alpha: 0.4) : AppColors.cardBorder),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Month
              Expanded(
                flex: 3,
                child: Text(
                  month,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Date
              Expanded(
                flex: 3,
                child: Text(
                  billDate.isEmpty ? '—' : billDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // Amount
              Expanded(
                flex: 3,
                child: Text(
                  hasRecharge ? '\u20B9 $billAmount' : '—',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isPaid
                        ? AppColors.textPrimary
                        : (hasRecharge ? AppColors.warningDark : AppColors.textMuted),
                  ),
                ),
              ),

              // Payment Action / Status Pill
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: hasRecharge
                      ? (isPaid
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      size: 13, color: AppColors.successDark),
                                  SizedBox(width: 4),
                                  Text(
                                    'Paid',
                                    style: TextStyle(
                                      color: AppColors.successDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () => changeBillStatus(context),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.warning, width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.payment_rounded,
                                        size: 13, color: AppColors.warningDark),
                                    SizedBox(width: 4),
                                    Text(
                                      'Pay Now',
                                      style: TextStyle(
                                        color: AppColors.warningDark,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                      : const Text(
                          'No plan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
              ),
            ],
          ),

          if (addInfo != null && addInfo!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Note: $addInfo',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
