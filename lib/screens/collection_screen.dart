import 'package:cableTvBook/global/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/box_decoration.dart';

class CollectionScreen extends StatelessWidget {
  static const routeName = '/collectionScreen';

  Widget getTitleText(BuildContext context, String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: defaultBoxDecoration(context, true),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget valueText(double total, double paid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: 'Total amount to be collected : \t',
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                  text: '\u20B9 $total',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: 'Amount collected : \t',
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                  text: '\u20B9 $paid',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: 'Pending amount to be collected : \t',
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                  text: '\u20B9 ${total - paid}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Future<Map<int, double>> getMonthlyData() async {
    double total = 0;
    double paid = 0;
    for (int i = 0; i < customers.length; i++) {
      final data = await Firestore.instance
          .collection(
              'users/${operatorDetails.id}/areas/${customers[i].areaId}/customers/${customers[i].id}/${DateTime.now().year}')
          .where('code', isEqualTo: DateTime.now().month)
          .getDocuments();
      if (data.documents.isNotEmpty) {
        final recharge = Recharge.fromMap(data.documents.first.data);
        if (recharge.billPay != null && recharge.billPay) {
          total += double.parse(recharge.plan);
          paid += double.parse(recharge.plan);
        } else if (recharge.billPay != null && recharge.billPay)
          total += double.parse(recharge.plan);
        else
          total += customers[i].currentPlan;
      } else
        total += customers[i].currentPlan;
    }
    return {0: total, 1: paid};
  }

  Future<Map<int, double>> getYearlyData() async {
    double total = 0;
    double paid = 0;
    for (int i = 0; i < customers.length; i++) {
      final data = await Firestore.instance
          .collection(
              'users/${operatorDetails.id}/areas/${customers[i].areaId}/customers/${customers[i].id}/${DateTime.now().year}')
          .getDocuments();
      if (data.documents.isNotEmpty) {
        for (int i = 0; i < data.documents.length; i++) {
          final recharge = Recharge.fromMap(data.documents[i].data);
          if (recharge.billPay != null && recharge.billPay) {
            total += double.parse(recharge.plan);
            paid += double.parse(recharge.plan);
          } else if (recharge.billPay != null && !recharge.billPay)
            total += double.parse(recharge.plan);
        }
      }
    }
    return {0: total, 1: paid};
  }

  static List<Customer> customers;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Information'),
      ),
      body: FutureBuilder(
        future: getAllCustomers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            customers = snapshot.data;
            return ListView(
              padding: const EdgeInsets.all(30),
              physics: BouncingScrollPhysics(),
              children: [
                getTitleText(
                    context,
                    'This month : ' +
                        DateFormat('MMMM').format(DateTime.now())),
                FutureBuilder(
                  future: getMonthlyData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return valueText(snapshot.data[0], snapshot.data[1]);
                    }
                    return Center(
                      child: Container(
                        child: FadingText('Please wait ...'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                getTitleText(context,
                    'This year : ' + DateFormat('yyyy').format(DateTime.now())),
                FutureBuilder(
                  future: getYearlyData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return valueText(snapshot.data[0], snapshot.data[1]);
                    }
                    return Center(
                      child: Container(
                        child: FadingText('Please wait ...'),
                      ),
                    );
                  },
                ),
              ],
            );
          }
          return Center(
            child: Container(
              child: FadingText('Please wait ...'),
            ),
          );
        },
      ),
    );
  }
}
