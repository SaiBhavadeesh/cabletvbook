import 'package:flutter/material.dart';
import 'package:cableTvBook/services/database_services.dart';

class CustomerPlanList extends StatelessWidget {
  final String customerId;
  final String areaId;
  final String year;
  final String id;
  final String month;
  final String billDate;
  final String billAmount;
  final String status;
  final bool billPay;
  final String addInfo;
  final int unpaidBill;

  CustomerPlanList({
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
      builder: (context) => AlertDialog(
        title: Text('Payment'),
        content: Text('click yes , if bill paid!'),
        actions: [
          FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('no'),
              color: Theme.of(context).errorColor),
          FlatButton(
              onPressed: () async {
                await DatabaseService.billPaid(context,
                    customerId: customerId,
                    year: year,
                    rechargeId: id,
                    unpaidBillno: unpaidBill);
                Navigator.pop(context);
              },
              child: Text('yes'),
              color: Theme.of(context).primaryColor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
              onDoubleTap: billPay == null || billPay
                  ? null
                  : () => changeBillStatus(context),
              child: Container(
                alignment: Alignment.center,
                width: width * 0.2,
                child: Text(
                  billAmount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: billPay == null || billPay
                        ? null
                        : Theme.of(context).errorColor,
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
              child: status == 'Active' && billPay
                  ? Icon(
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
        if (month != 'Month') Divider(),
        if (addInfo != null)
          Text(addInfo, style: TextStyle(color: Theme.of(context).errorColor)),
        if (addInfo != null) Divider(),
      ],
    );
  }
}
