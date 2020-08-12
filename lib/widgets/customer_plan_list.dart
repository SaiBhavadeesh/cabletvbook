import 'package:flutter/material.dart';

class CustomerPlanList extends StatelessWidget {
  final String month;
  final String billDate;
  final String billAmount;
  final String status;
  final String addInfo;

  CustomerPlanList({
    this.month = 'Month',
    this.billDate = 'Date',
    this.billAmount = 'Amount',
    this.status = 'Status',
    this.addInfo,
  });

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
              width: width * 0.2,
              child: Text(
                billDate,
                textAlign: TextAlign.center,
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
              width: width * 0.2,
              child: Text(
                billAmount,
                textAlign: TextAlign.center,
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
              width: width * 0.25,
              height: width * 0.05,
              child: status == 'Completed'
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
