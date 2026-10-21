import 'package:flutter/material.dart';
import 'package:cableTvBook/services/database_services.dart';

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
  });

  Future<void> changeBillStatus(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment'),
        content: const Text('Click yes, if bill paid!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('no'),
          ),
          TextButton(
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
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).primaryColor,
            ),
            child: const Text('yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isPaid = billPay ?? false;
    final isErrorColor = !isPaid;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: width * 0.2,
              child: Text(
                month,
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width * 0.045,
                ),
              ),
            ),
            Container(
              height: width * 0.05,
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            Container(
              alignment: Alignment.center,
              width: width * 0.22,
              child: Text(
                billDate,
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width * 0.045,
                ),
              ),
            ),
            Container(
              height: width * 0.05,
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            GestureDetector(
              onDoubleTap: isPaid ? null : () => changeBillStatus(context),
              child: Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: Text(
                  billAmount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isErrorColor
                        ? Theme.of(context).colorScheme.error
                        : null,
                    fontSize: width * 0.045,
                  ),
                ),
              ),
            ),
            Container(
              height: width * 0.05,
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            Container(
              alignment: Alignment.center,
              width: width * 0.23,
              height: width * 0.05,
              child: status == 'Active' && isPaid
                  ? const Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  : Text(
                      status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.045,
                      ),
                    ),
            ),
          ],
        ),
        if (month != 'Month') const Divider(),
        if (addInfo != null)
          Text(
            addInfo!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const Divider(),
      ],
    );
  }
}
