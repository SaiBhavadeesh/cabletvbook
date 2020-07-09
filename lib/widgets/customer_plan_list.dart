import 'package:flutter/material.dart';

class CustomerPlanList extends StatefulWidget {
  final String month;
  final String billDate;
  final String billAmount;
  final String status;

  CustomerPlanList({
    this.month = 'Month',
    this.billDate = 'Date',
    this.billAmount = 'Amount',
    this.status = 'Status',
  });

  @override
  _CustomerPlanListState createState() => _CustomerPlanListState();
}

class _CustomerPlanListState extends State<CustomerPlanList> {
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
              width: width * 0.18,
              child: Text(
                widget.month,
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
              width: width * 0.18,
              child: Text(
                widget.billDate,
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
              width: width * 0.18,
              child: Text(
                widget.billAmount,
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
              width: width * 0.35,
              height: width * 0.05,
              child: widget.status == 'Completed'
                  ? Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  : Text(
                      widget.status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.045,
                      ),
                    ),
            ),
          ],
        ),
        if (widget.month != 'Month') Divider(),
      ],
    );
  }
}
