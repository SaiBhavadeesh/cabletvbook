import 'package:flutter/material.dart';

class CustomerPlanList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: width * 0.18,
          child: Text(
            month,
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
          width: width * 0.18,
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
          width: width * 0.35,
          height: width * 0.05,
          child: FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.arrow_drop_down),
            label: Text(status),
          ),
        ),
      ],
    );
  }
}
